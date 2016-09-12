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
#import "AppService.h"
#import "GithubService.h"
#import "AppState.h"
#import "Config.h"
#import "Errors.h"
#import "Helpers.h"
#import "Extensions.h"

@implementation AppService

static BOOL _performAdditionalUpdate;
static BOOL _updateInProgress;

#pragma mark - Sync Helpers

+ (RACSignal*) sync:(BOOL) online{
    RACSignal* sync = online ? [self onlineSync] : [self offlineSync];
    return [[sync flattenMap:^(id x) {
        NSInteger pendingCompletedTasks = AppState.pendingCompletedTasks;
        [[NSNotificationCenter defaultCenter] postNotificationName:kGLEventSyncComplete object:nil];
        [AppState setPerformedInitialSync:YES];
        [AppState setPendingCompletedTasks:0];
        return [RACSignal return:@(pendingCompletedTasks)];
    }] doError:^(NSError *error) {
        DDLogError(@"sync failure:\n %@", error);
    }];
}

#pragma mark - Online sync helpers

+ (RACSignal*) cacheUserMetadata{
    return [[[GithubService retrieveUserMetadata] doNext:^(OCTUser* userInfo) {
        [AppState setUserName:userInfo.name andUserImageUrl:userInfo.avatarURL.absoluteString];
    }] doError:^(NSError *error) {
        DDLogError(@"cacheUserMetadata: error:\n %@", error);
    }];
}

+ (RACSignal*) onlineSync{
    if (!AppState.userIsAuthenticated){
        return [RACSignal error:Errors.notAuthenticated];
    }
    
#warning this seems kind of redundant
    RACSignal* retrieve = [GithubService retrieveGistsSince:DateHelper.oneWeekAgo];
    return [[retrieve flattenMap:^(NSMutableArray* gists) {
        return [self syncClientWithRemoteGist:gists.first];
    }] doError:^(NSError *error) {
        DDLogError(@"failed to retrieve gists:\n %@", error);
    }];
}

+ (RACSignal*) syncClientWithRemoteGist:(OCTGist*) mostRecentRemoteGist{

    // Locals
    TaskList* localTaskList = AppState.taskList;
    NSDate* localLastUpdated = localTaskList.lastUpdated;
    NSDate* remoteLastUpdated = mostRecentRemoteGist.creationDate;
    BOOL remoteOlderThan24Hours = [DateHelper isOlderThan24Hours:remoteLastUpdated];
    BOOL localOlderThan24Hours = [DateHelper isOlderThan24Hours:localLastUpdated];
    
    // We dont have a "last updated" field on OCTGist for some reason, so we attempt to pull back gists more recent than the last local update
    return [[GithubService retrieveGistsSince:localLastUpdated] flattenMap:^(NSMutableArray *gistsSinceLastLocalUpdate) {
        
        // Gist: new or reuse
        // TaskList: remote gist, local
        
        OCTGist* remoteGistMoreRecentThanLocal = gistsSinceLastLocalUpdate.firstObject;
        if (remoteGistMoreRecentThanLocal){
            // found a gist more recent than local tasklist
            if (remoteOlderThan24Hours){
                // Remote gist is most recent, but older than 24 hours
                return [self createTodaysGistAndConsumeGist:remoteGistMoreRecentThanLocal isNewDay:YES];
            }else{
                // Remote gist is most recent, and good to use
                return [self recycleAndConsumeGist:remoteGistMoreRecentThanLocal];
            }
        }else{
            // found no gists more recent than local tasklist
            if (mostRecentRemoteGist){
                if (remoteOlderThan24Hours){
                    // remote gist is older than 24 hours, create today's gist with local copy
                    return [self createTodaysGistAndConsumeTaskList:localTaskList isNewDay:YES];
                }else{
                    // remote gist is still valid, update with more recent local data
                    return [self recycleGist:mostRecentRemoteGist andConsumeTaskList:localTaskList];
                }
            }else{
                // Local gist is most recent or found none on github, create today's gist with local copy
                return [self createTodaysGistAndConsumeTaskList:localTaskList isNewDay:localOlderThan24Hours];
            }
        }
    }];
}

+ (RACSignal*) recycleGist:(OCTGist*)gist andConsumeTaskList:(TaskList*) tasklist{
//    [AppState setGistToEdit:gist]; Do we need this?
    
    [AppState setTaskList:tasklist];
    NSString* username = AppState.username;
    NSString* content = tasklist.contentForTasks;
    return [[[GithubService updateGist:gist withContent:content username:username]
              doNext:^(OCTGist *updatedGist) {
                  [AppState setGistToEdit:updatedGist];
              }]
             doError:^(NSError *error) {
                 DDLogError(@"update gist: error:\n %@", error);
             }];
}

+ (RACSignal*) recycleAndConsumeGist:(OCTGist*) remoteCopy{
    [AppState setGistToEdit:remoteCopy];
    OCTGistFile* file = remoteCopy.files.allValues.firstObject;
    return [[[GithubService retrieveGistWithRawUrl:file.rawURL]
                              doNext:^(NSString *gistContent) {
                                  [AppState setTaskList:[TaskList taskListForContent:gistContent]];
                              }] doError:^(NSError *error) {
                                  DDLogError(@"recycleAndConsumeGist: failure: \n%@", error);
                              }];
}

+ (RACSignal*) createTodaysGistAndConsumeGist:(OCTGist*) remoteCopy isNewDay:(BOOL) isNewDay{
    OCTGistFile* file = remoteCopy.files.allValues.firstObject;
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
        [AppState incrementCompletedTasks:taskList.completedTaskCount];
        [AppState setTaskList:[TaskList newTaskListFromOldTaskList:taskList]];
    }else{
        [AppState setTaskList:taskList];
    }
    NSString* username = AppState.username;
    NSString* gistContent = AppState.taskList.contentForTasks;
    return [[[GithubService createGistWithContent:gistContent username:username]
            doNext:^(OCTGist *createdGist) {
                [AppState setGistToEdit:createdGist];
            }] doError:^(NSError *error) {
                DDLogError(@"createTodaysGistAndConsumeTaskList: failure: \n%@", error);
            }];
}

#pragma mark - Offline sync helpers

+ (RACSignal*) offlineSync{
    TaskList* savedTaskList = AppState.taskList;
    TaskList* newTaskList = nil;
    BOOL olderThan24Hours = [DateHelper isOlderThan24Hours:savedTaskList.lastUpdated];
    if (olderThan24Hours){
        [AppState incrementCompletedTasks:savedTaskList.completedTaskCount];
        newTaskList = [TaskList newTaskListFromOldTaskList:savedTaskList];
    }else{
        newTaskList = savedTaskList ? : [TaskList taskListForContent:@""];
    }
    [AppState setTaskList:newTaskList];
    return [self doNothing];
}

#pragma mark - Persistence helpers

+ (RACSignal*) persistTaskList:(TaskList*) newTaskList{
    
    // Do nothing if our list matches what's stored locally
    if ([newTaskList isEqualToList:AppState.taskList]){
        return [self doNothing];
    }
    
    // Always persist locally
    [AppState setTaskList:newTaskList];
    
    // Make sure we can make network calls
    if (AppState.userIsAuthenticated == NO){
        return [RACSignal error:Errors.notAuthenticated];
    }
    if (AppState.performedInitialSync == NO){
        return [RACSignal error:Errors.hasNotPerformedInitialSync];
    }
    if (AppState.gistToEdit == nil){
        return [RACSignal error:Errors.dataError];
    }
    if (_updateInProgress){
        _performAdditionalUpdate = YES;
        return [RACSignal error:Errors.updateInProgress];
    }
    
    // Make update call
    _updateInProgress = YES;
    NSString* content = [newTaskList contentForTasks];
    OCTGist* gistToEdit = AppState.gistToEdit;
    NSString* username = AppState.username;
    return [[[[GithubService updateGist:gistToEdit withContent:content username:username]
             doNext:^(OCTGist *updatedGist) {
                 [AppState setGistToEdit:updatedGist];
             }]
            doError:^(NSError *error) {
                DDLogError(@"update gist: error:\n %@", error);
            }]
            doCompleted:^{
                _updateInProgress = NO;
                if (_performAdditionalUpdate){
                    _performAdditionalUpdate = NO;
                    [self persistTaskList:newTaskList];
                }
            }];
}

#pragma mark - Public session methods

+ (RACSignal*) signOut{
    [GithubService invalidateCachedLogin];
    return [self doNothing];
    
}

+ (RACSignal*) startOfflineSession{
    [GithubService invalidateCachedLogin];
    return [self sync:NO];
}

+ (RACSignal*) startOnlineSessionWithStoredCreds{
    if ([GithubService authenticateWithStoredCredentials]){
        return [RACSignal zip:@[[self cacheUserMetadata], [self sync:YES]]];
    }else{
        DDLogError(@"failed to auth with stored credentials");
        return [RACSignal error:Errors.authFailure];
    }
}

+ (RACSignal*) startOnlineSessionWithUsername:(NSString*) user password:(NSString*) password auth:(NSString*) auth{
    NSString* authOrNil = auth.length == 0 ? nil : auth;
    return [[[GithubService authenticateUsername:user withPassword:password withAuth:authOrNil] flattenMap:^(id x) {
        return [RACSignal zip:@[[self sync:YES], [self cacheUserMetadata]]];
    }] doError:^(NSError *error) {
        DDLogError(@"auth failure:\n %@", error);
        [GithubService invalidateCachedLogin];
    }];
}

#pragma mark - Public synchronization methods

+ (RACSignal*) doNothing{
    return [RACSignal return:nil];
}

+ (RACSignal*) syncIfResuming {
    return AppState.performedInitialSync ?
    [self sync:AppState.userIsAuthenticated] :
    [self doNothing];
}

#pragma mark - Public task management methods

+ (RACSignal*) createViralGist{
    return [[GithubService createViralGist] flattenMap:^RACStream *(id value) {
        [AppState setSharedGist:YES];
        return [self doNothing];
    }];
}

+ (RACSignal*) updateTask:(NSInteger) index withText:(NSString*) newText{
    TaskList* taskList = AppState.taskList;
    [taskList taskAtIndex:index].taskDescription = newText;
    taskList.lastUpdated = [NSDate date];
    return [self persistTaskList:taskList];
}

+ (RACSignal*) deleteTask:(NSInteger) index{
    TaskList* taskList = AppState.taskList;
    [taskList removeTaskAtIndex:index];
    taskList.lastUpdated = [NSDate date];
    return [self persistTaskList:taskList];
}

+ (RACSignal*) toggleTask:(NSInteger) index{
    TaskList* taskList = AppState.taskList;
    Task* task = [taskList taskAtIndex:index];
    task.completed = !task.completed;
    taskList.lastUpdated = [NSDate date];
    return [self persistTaskList:taskList];
}

+ (RACSignal*) addNewTaskWithText:(NSString*) text{
    TaskList* taskList = AppState.taskList;
    [taskList addTask:[Task taskWithDescription:text isCompleted:NO]];
    taskList.lastUpdated = [NSDate date];
    return [self persistTaskList:taskList];
}

#pragma mark - Misc methods

+ (RACSignal*) startTutorialWithDelay{
    if (AppState.showedTutorial || AppState.taskCount > 0){
        return [RACSignal return:@(NO)];
    }
    return [[RACSignal performBlock:^{
        [AppState setShowedTutorial:YES];
    } afterDelay:0.5f] flattenMap:^RACStream *(id value) {
        return [RACSignal return:@(YES)];
    }];
}

@end
