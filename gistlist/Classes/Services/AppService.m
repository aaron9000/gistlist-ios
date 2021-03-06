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

+ (instancetype)sharedService
{
    static AppService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppService alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Sync Helpers

- (RACSignal*) sync:(BOOL) online{
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

- (RACSignal*) onlineSync{
    if (!GithubService.sharedService.userIsAuthenticated){
        return [RACSignal error:Errors.notAuthenticated];
    }
    
    RACSignal* retrieve = [GithubService.sharedService retrieveMostRecentGistSince:DateHelper.oneMonthAgo];
    return [[retrieve flattenMap:^(OCTGist* mostRecentRemoteGist) {
        TaskList* localTaskList = AppState.taskList;
        NSDate* localLastUpdated = localTaskList.lastUpdated;
        NSDate* remoteLastUpdated = mostRecentRemoteGist.creationDate;
        BOOL remoteOlderThan24Hours = [DateHelper isOlderThan24Hours:remoteLastUpdated];
        BOOL localOlderThan24Hours = [DateHelper isOlderThan24Hours:localLastUpdated];
        
        // We dont have a "last updated" field on OCTGist, so we pull back gists more recent than the last local update
        return [[GithubService.sharedService retrieveMostRecentGistSince:localLastUpdated] flattenMap:^(OCTGist* remoteGistMoreRecentThanLocal) {
            if (remoteGistMoreRecentThanLocal){
                return [self onlineSyncConsumeRemote:remoteGistMoreRecentThanLocal
                                     createNewGist:remoteOlderThan24Hours];
            }else{
                if (mostRecentRemoteGist){
                    return [self onlineSyncConsumeLocal:localTaskList
                                 mostRecentRemoteGist:mostRecentRemoteGist
                                        createNewGist:remoteOlderThan24Hours];
                }else{
                    return [self onlineSyncConsumeLocal:localTaskList
                                 mostRecentRemoteGist:nil
                                        createNewGist:localOlderThan24Hours];
                }
            }
        }];
    }] doError:^(NSError *error) {
        DDLogError(@"failed to retrieve gist:\n %@", error);
    }];
}

- (RACSignal*) onlineSyncConsumeRemote:(OCTGist*) remoteGist
                     createNewGist:(BOOL) createNewGist{
    
    OCTGistFile* file = remoteGist.files.allValues.firstObject;
    return [[[GithubService.sharedService retrieveGistContentFromUrl:file.rawURL] flattenMap:^RACStream *(NSString* content) {
        TaskList* list = [TaskList taskListForContent:content];
        TaskList* newList = createNewGist ? [TaskList newTaskListFromOldTaskList:list] : list;
        NSString* newContent = newList.contentForTasks;
        [AppState setTaskList:newList];
        if (createNewGist){
            [AppState incrementCompletedTasks:list.completedTaskCount];
            return [GithubService.sharedService createGistWithContent:newContent username:AppState.username];
        }else{
            return [RACSignal return:remoteGist];
        }
    }] flattenMap:^RACStream *(OCTGist* gist) {
        [AppState setGistToEdit:gist];
        return [RACSignal return:@(YES)];
    }];
}

- (RACSignal*) onlineSyncConsumeLocal:(TaskList*) taskList
             mostRecentRemoteGist:(OCTGist*) mostRecentGist
                    createNewGist:(BOOL) createNewGist{
    
    TaskList* newList = createNewGist ? [TaskList newTaskListFromOldTaskList:taskList] : taskList;
    NSString* newContent = newList.contentForTasks;
    [AppState setTaskList:newList];
    RACSignal* gistSignal = nil;
    if (createNewGist){
        [AppState incrementCompletedTasks:taskList.completedTaskCount];
    }
    if (createNewGist || !mostRecentGist){
        gistSignal = [GithubService.sharedService createGistWithContent:newContent username:AppState.username];
    }else{
        gistSignal = [RACSignal return:mostRecentGist];
    }
    return [gistSignal flattenMap:^RACStream *(OCTGist* gist) {
        [AppState setGistToEdit:gist];
        return [RACSignal return:@(YES)];
    }];
}

#pragma mark - Offline sync helpers

- (RACSignal*) offlineSync{
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
    return [RACSignal return:@(YES)];
}

#pragma mark - Persistence helpers

- (RACSignal*) persistTaskList:(TaskList*) newTaskList{
    
    // Do nothing if our list matches what's stored locally
    if ([newTaskList isEqualToList:AppState.taskList]){
        return [RACSignal return:@(NO)];
    }
    
    // Always persist locally
    [AppState setTaskList:newTaskList];
    
    // Make sure we can make network calls
    if (GithubService.sharedService.userIsAuthenticated == NO){
        return [RACSignal error:Errors.notAuthenticated];
    }
    if (AppState.performedInitialSync == NO){
        return [RACSignal error:Errors.hasNotPerformedInitialSync];
    }
    if (AppState.gistToEdit == nil){
        return [RACSignal error:Errors.dataError];
    }
    if (_syncInProgress){
        return [RACSignal error:Errors.updateInProgress];
    }
    
    // Make update call
    _syncInProgress = YES;
    NSString* content = [newTaskList contentForTasks];
    OCTGist* gistToEdit = AppState.gistToEdit;
    NSString* username = AppState.username;
    return [[[[GithubService.sharedService updateGist:gistToEdit withContent:content username:username]
              flattenMap:^RACStream *(OCTGist* updatedGist) {
                  [AppState setGistToEdit:updatedGist];
                  return [RACSignal return:@(YES)];
              }]
            doError:^(NSError *error) {
                DDLogError(@"update gist: error:\n %@", error);
            }]
            doCompleted:^{
                // TODO: It may be wise to try to sync again in circumstances where a sync call was squashed
                _syncInProgress = NO;
            }];
}

#pragma mark - Misc helpers

- (RACSignal*) cacheUserMetadata{
    if (AppState.username.length && AppState.userImageUrl.length){
        return [RACSignal return:@(YES)];
    }
    return [[[GithubService.sharedService retrieveUserMetadata] doNext:^(OCTUser* userInfo) {
        [AppState setUserName:userInfo.name andUserImageUrl:userInfo.avatarURL.absoluteString];
    }] doError:^(NSError *error) {
        DDLogError(@"cacheUserMetadata: error:\n %@", error);
    }];
}

#pragma mark - Public session methods

- (RACSignal*) signOut{
    return [GithubService.sharedService invalidateCachedLogin];
}

- (RACSignal*) startOfflineSession{
    return [[GithubService.sharedService invalidateCachedLogin] flattenMap:^RACStream *(id value) {
        return [self sync:NO];
    }];
}

- (RACSignal*) startOnlineSessionWithStoredCreds{
    return [[[GithubService.sharedService authenticateWithStoredCredentials] flattenMap:^RACStream *(id value) {
        return [self cacheUserMetadata];
    }] flattenMap:^RACStream *(id value) {
        return [self sync:YES];
    }];
}

- (RACSignal*) startOnlineSessionWithUsername:(NSString*) user password:(NSString*) password auth:(NSString*) auth{
    NSString* authOrNil = auth.length == 0 ? nil : auth;
    return [[[[GithubService.sharedService authenticateUsername:user withPassword:password withAuth:authOrNil] flattenMap:^(id x) {
        return [self cacheUserMetadata];
    }] flattenMap:^RACStream *(id value) {
        return [self sync:YES];
    }] doError:^(NSError *error) {
        DDLogError(@"auth failure:\n %@", error);
        [[GithubService.sharedService invalidateCachedLogin] subscribeNext:^(id x) {
        }];
    }];
}

#pragma mark - Public synchronization methods

- (RACSignal*) syncIfResuming {
    return AppState.performedInitialSync ?
    [self sync:GithubService.sharedService.userIsAuthenticated] :
    [RACSignal return:@(-1)];
}

#pragma mark - Public task management methods

- (RACSignal*) createViralGist{
    return [[GithubService.sharedService createViralGist] flattenMap:^RACStream *(id value) {
        [AppState setSharedGist:YES];
        return [RACSignal return:@(YES)];
    }];
}

- (RACSignal*) updateTask:(NSInteger) index withText:(NSString*) newText{
    TaskList* taskList = AppState.taskList;
    [taskList taskAtIndex:index].taskDescription = newText;
    taskList.lastUpdated = [NSDate date];
    return [self persistTaskList:taskList];
}

- (RACSignal*) deleteTask:(NSInteger) index{
    TaskList* taskList = AppState.taskList;
    [taskList removeTaskAtIndex:index];
    taskList.lastUpdated = [NSDate date];
    return [self persistTaskList:taskList];
}

- (RACSignal*) toggleTask:(NSInteger) index{
    TaskList* taskList = AppState.taskList;
    Task* task = [taskList taskAtIndex:index];
    task.completed = !task.completed;
    taskList.lastUpdated = [NSDate date];
    return [self persistTaskList:taskList];
}

- (RACSignal*) addNewTaskWithText:(NSString*) text{
    TaskList* taskList = AppState.taskList;
    [taskList addTask:[Task taskWithDescription:text isCompleted:NO]];
    taskList.lastUpdated = [NSDate date];
    return [self persistTaskList:taskList];
}

#pragma mark - Public misc methods

- (RACSignal*) startTutorialWithDelay{
    if (AppState.showedTutorial || AppState.taskCount > 0){
        return [RACSignal return:@(NO)];
    }
    return [[[RACSignal return:nil] delay:0.5f] flattenMap:^RACStream *(id value) {
        [AppState setShowedTutorial:YES];
        return [RACSignal return:@(YES)];
    }];
}

@end
