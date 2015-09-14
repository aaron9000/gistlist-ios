//
//  GistListLogic.m
//  ios-base
//
//  Created by Aaron Geisler on 3/12/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <CocoaLumberjack.h>
#import <SVProgressHUD.h>
#import <ObjectiveSugar.h>
#import "NSObject+Blocks.h"
#import "AppService.h"
#import "GithubService.h"
#import "LocalStorage.h"
#import "KeychainStorage.h"
#import "Notifications.h"
#import "Errors.h"
#import "DialogHelper.h"

@implementation AppService

#pragma mark - State

static TaskList* _taskList;
static OCTGist* _gistToEdit;
static NSString* _userImageUrl;
static NSString* _username;
static BOOL _performedInitialSync;
static BOOL _performAdditionalUpdate;
static BOOL _updateInProgress;
static NSInteger _pendingStars;

#pragma mark - Getters

+ (Task*) taskAtIndex:(NSInteger) index{
    NSMutableArray* tasks = _taskList.tasks;
    return index >= tasks.count ? nil : tasks[index];
}

+ (NSString*) taskDescriptionAtIndex:(NSInteger) index{
    return [self taskAtIndex:index].taskDescription;
}

+ (BOOL) taskIsCompleteAtIndex:(NSInteger) index{
    return [self taskAtIndex:index].completed;
}

+ (NSInteger) taskCount{
    return _taskList.tasks.count;
}

+ (NSURL*) gistUrl{
    return _gistToEdit.HTMLURL ? : [NSURL URLWithString:@"http://gist.github.com/"];
}

+ (NSString*) userImageUrl{
    return _userImageUrl ? : @"";
}

+ (NSString*) username{
    return [self userIsAuthenticated] ? _username : @"GistList";
}

#pragma mark - Stars

+ (NSInteger) pendingStars{
    return _pendingStars;
}

+ (void) incrementStars:(NSInteger) number{
    NSInteger newStars = [KeychainStorage stars] + number;
    [KeychainStorage setStars:newStars];
    _pendingStars = number;
}

+ (void) attemptShowStarAward{
    if (_pendingStars == 0){
        return;
    }
    [NSObject performBlock:^{
        [DialogHelper showTaskCompletionToast:_pendingStars];
        _pendingStars = 0;
    } afterDelay:0.3f];
}

#pragma mark - Sessions

+ (void) start{
    _taskList = [LocalStorage localData].taskList;
}

+ (void) signOut{
    [GithubService invalidateCachedLogin];
}

+ (BOOL) performedInitialSync{
    return _performedInitialSync;
}

+ (BOOL) hasStoredCreds{
    NSString* savedToken = [KeychainStorage token];
    NSString* savedUserLogin = [KeychainStorage userLogin];
    return (savedToken.length > 0 && savedUserLogin.length > 0);
}

+ (BOOL) userIsAuthenticated{
    return [GithubService userIsAuthenticated];
}

+ (RACSignal*) startOfflineSession{
    [GithubService invalidateCachedLogin];
    return [self sync:NO];
}

+ (RACSignal*) startSessionAndSyncWithStoredCreds{
    if ([GithubService authenticateWithStoredCredentials]){
        return [RACSignal zip:@[[self cacheUserMetadata], [self sync:YES]]];
    }else{
        DDLogError(@"failed to auth with stored credentials");
        return [RACSignal error:Errors.authFailure];
    }
}

+ (RACSignal*) startSessionAndSyncWithUsername:(NSString*) user password:(NSString*) password auth:(NSString*) auth{
    return [[[GithubService authenticateUsername:user withPassword:password withAuth:auth] flattenMap:^(id x) {
        return [RACSignal zip:@[[self sync:YES], [self cacheUserMetadata]]];
    }] doError:^(NSError *error) {
        DDLogError(@"auth failure:\n %@", error);
        [GithubService invalidateCachedLogin];
    }];
}

#pragma mark - Synchronization

+ (RACSignal*) attemptSync {
    return _performedInitialSync ? [self sync:[GithubService userIsAuthenticated]] : [RACSignal return:@{}];
}

+ (RACSignal*) sync:(BOOL) online{
    return [[(online ? [self onlineSync] : [self offlineSync]) doNext:^(id x) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGLEventSyncComplete object:nil];
        [self attemptShowStarAward];
        _performedInitialSync = YES;
    }] doError:^(NSError *error) {
        DDLogError(@"sync failure:\n %@", error);
    }];
}

#pragma mark - Data Flow Helpers

+ (NSDate*) twelveAMToday{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    date = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:date]];
    return date;
}

+ (NSDate*) oneWeekAgo{
    return [[NSDate date] dateByAddingTimeInterval:-60.0f * 60.0f * 24.0f * 7.0f];
}

#pragma mark - Data Flow - Online

+ (RACSignal*) cacheUserMetadata{
    return [[[GithubService retrieveUserInfo] doNext:^(OCTUser* userInfo) {
        _userImageUrl = userInfo.avatarURL.absoluteString;
        _username = userInfo.name;
    }] doError:^(NSError *error) {
        DDLogError(@"cacheUserMetadata: error:\n %@", error);
    }];
}

+ (RACSignal*) onlineSync{
    if (![self userIsAuthenticated]){
        return [RACSignal error:Errors.notAuthenticated];
    }
    
    RACSignal* retrieve = [GithubService retrieveGistsSince:[self oneWeekAgo]];
    return [[retrieve flattenMap:^(NSMutableArray* gists) {
        return [self synchronizeClientWithRemoteGist:[gists first]];
    }] doError:^(NSError *error) {
        DDLogError(@"failed to retrieve gists:\n %@", error);
    }];
}

+ (RACSignal*) synchronizeClientWithRemoteGist:(OCTGist*) mostRecentRemoteGist{

    // Reference dates
    NSDate* twelveAMToday = [self twelveAMToday];
    NSDate* lastLocalUpdate = [_taskList lastUpdated];
    NSDate* remoteGistDate = [mostRecentRemoteGist creationDate];
    BOOL remoteOlderThan24Hours = [twelveAMToday compare:remoteGistDate] == NSOrderedDescending;
    BOOL localOlderThan24Hours = [twelveAMToday compare:lastLocalUpdate] == NSOrderedDescending;
    
    // We dont have a "last updated" field on OCTGist for some reason, so we attempt to pull back gists more recent than the last local update
    return [[GithubService retrieveGistsSince:lastLocalUpdate] flattenMap:^(NSMutableArray *gistsSinceLastLocalUpdate) {
        OCTGist* gistMoreRecentThanLocal = [gistsSinceLastLocalUpdate firstObject];
        if (gistMoreRecentThanLocal){
            // found a gist more recent than local tasklist
            if (remoteOlderThan24Hours){
                // Remote gist is most recent, but older than 24 hours
                return [self createTodaysGistAndConsumeGist:gistMoreRecentThanLocal isNewDay:YES];
            }else{
                // Remote gist is most recent, and good to use
                return [self recycleAndConsumeGist:gistMoreRecentThanLocal];
            }
        }else{
            // found no gists more recent than local tasklist
            if (mostRecentRemoteGist){
                if (remoteOlderThan24Hours){
                    // remote gist is older than 24 hours, create today's gist with local copy
                    return [self createTodaysGistAndConsumeTaskList:_taskList isNewDay:YES];
                }else{
                    // remote gist is still valid, update with more recent local data
                    return [self recycleGist:mostRecentRemoteGist andConsumeTaskList:_taskList];
                }
            }else{
                // Local gist is most recent or found none on github, create today's gist with local copy
                return [self createTodaysGistAndConsumeTaskList:_taskList isNewDay:localOlderThan24Hours];
            }
        }
    }];
}

+ (RACSignal*) recycleGist:(OCTGist*)gist andConsumeTaskList:(TaskList*) tasklist{
    _gistToEdit = gist;
    _taskList = tasklist;
    return [[[GithubService updateGist:_gistToEdit withContent:[tasklist contentForTasks] username:_username]
              doNext:^(OCTGist *updatedGist) {
                  _gistToEdit = updatedGist;
              }]
             doError:^(NSError *error) {
                 DDLogError(@"update gist: error:\n %@", error);
             }];
}

+ (RACSignal*) recycleAndConsumeGist:(OCTGist*) remoteCopy{
    _gistToEdit = remoteCopy;
    OCTGistFile* file = [[remoteCopy.files allValues] firstObject];
    return [[[GithubService retrieveGistWithRawUrl:file.rawURL]
                              doNext:^(NSString *gistContent) {
                                  _taskList = [TaskList taskListForContent:gistContent];
                              }] doError:^(NSError *error) {
                                  DDLogError(@"recycleAndConsumeGist: failure: \n%@", error);
                              }];
}

+ (RACSignal*) createTodaysGistAndConsumeGist:(OCTGist*) remoteCopy isNewDay:(BOOL) isNewDay{
    OCTGistFile* file = [[remoteCopy.files allValues] firstObject];
    return [[[GithubService retrieveGistWithRawUrl:file.rawURL]
                flattenMap:^(NSString *gistContent) {
                    TaskList* taskList = [TaskList taskListForContent:gistContent];
                    return [self createTodaysGistAndConsumeTaskList:taskList isNewDay:isNewDay];
                }] doError:^(NSError *error) {
                    DDLogError(@"createTodaysGistAndConsumeGist: failure: \n%@", error);
                }];
}

+ (RACSignal*) createTodaysGistAndConsumeTaskList:(TaskList*) taskList isNewDay:(BOOL) isNewDay{
    if (isNewDay){
        [self incrementStars:taskList.completedTaskCount];
        _taskList = [TaskList newTaskListFromOldTaskList:taskList];
    }else{
        _taskList = taskList;
    }
    NSString* gistContent = [_taskList contentForTasks];
    return [[[GithubService createGistWithContent:gistContent username:_username]
            doNext:^(OCTGist *createdGist) {
                _gistToEdit = createdGist;
            }] doError:^(NSError *error) {
                DDLogError(@"createTodaysGistAndConsumeTaskList: failure: \n%@", error);
            }];
}

#pragma mark - Data Flow - Offline

+ (RACSignal*) offlineSync{
    LocalData* localData = [LocalStorage localData];
    TaskList* savedTaskList = localData.taskList;
    BOOL olderThan24Hours = [[self twelveAMToday] compare:savedTaskList.lastUpdated] == NSOrderedDescending;
    if (olderThan24Hours){
        [self incrementStars:savedTaskList.completedTaskCount];
        _taskList = [TaskList newTaskListFromOldTaskList:savedTaskList];
    }else{
        _taskList = savedTaskList ? : [TaskList taskListForContent:@""];
    }
    localData.taskList = _taskList;
    [LocalStorage setLocalData:localData];
    return [RACSignal return: nil];
}

#pragma mark - Task Management

+ (RACSignal*) createViralGist{
    return [GithubService createViralGist];
}

+ (RACSignal*) persistTaskList{
    
    // Do nothing if our list matches what's on disk
    LocalData* localData = [LocalStorage localData];
    if ([localData.taskList isEqualToList:_taskList]){
        return [RACSignal return:nil];
    }
    
    // Save locally
    _taskList.lastUpdated = [NSDate date];
    localData.taskList = _taskList;
    [LocalStorage setLocalData:localData];
    
    // Make sure we can make network calls
    if (_performedInitialSync == NO){
        return [RACSignal error:Errors.hasNotPerformedInitialSync];
    }
    if ([GithubService userIsAuthenticated] == NO){
        return [RACSignal error:Errors.notAuthenticated];
    }
    if (_gistToEdit == nil){
        return [RACSignal error:Errors.dataError];
    }
    if (_updateInProgress){
        _performAdditionalUpdate = YES;
        return [RACSignal error:Errors.updateInProgress];
    }
    
    // Make update call
    _updateInProgress = YES;
    return [[[[GithubService updateGist:_gistToEdit withContent:[_taskList contentForTasks] username:_username]
             doNext:^(OCTGist *updatedGist) {
                 _gistToEdit = updatedGist;
             }]
            doError:^(NSError *error) {
                DDLogError(@"update gist: error:\n %@", error);
            }]
            doCompleted:^{
                _updateInProgress = NO;
                if (!_performAdditionalUpdate){
                    _performAdditionalUpdate = NO;
                    [self persistTaskList];
                }
            }];
}

+ (RACSignal*) updateTask:(NSInteger) index withText:(NSString*) newText{
    [_taskList taskAtIndex:index].taskDescription = newText;
    return [self persistTaskList];
}

+ (RACSignal*) deleteTask:(NSInteger) index{
    [_taskList removeTaskAtIndex:index];
    return [self persistTaskList];
}

+ (RACSignal*) toggleTask:(NSInteger) index{
    Task* task = [_taskList taskAtIndex:index];
    task.completed = !task.completed;
    return [self persistTaskList];
}

+ (RACSignal*) addNewTaskWithText:(NSString*) text{
    [_taskList addTask:[Task taskWithDescription:text isCompleted:NO]];
    return [self persistTaskList];
}

@end
