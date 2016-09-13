#import "AppState.h"

#import "KeychainStorage.h"
#import "LocalStorage.h"
#import "URLs.h"

@implementation AppState

#pragma mark - In-memory State

static OCTGist* _gistToEdit;
static NSString* _userImageUrl;
static NSString* _username;
static BOOL _performedInitialSync;
static NSInteger _pendingCompletedTasks;

#pragma mark - Internal Helpers

+ (NSMutableArray*) tasks{
    return LocalStorage.localData.taskList.tasks;
}

#pragma mark - Setters & modifiers

+ (void) setPendingCompletedTasks:(NSInteger) tasks{
    _pendingCompletedTasks = tasks;
}

+ (void) setTaskList:(TaskList*) taskList{
    LocalData* newData = [LocalStorage.localData clone];
    newData.taskList = taskList;
    [LocalStorage setLocalData:newData];
}

+ (void) setUserName:(NSString*) name andUserImageUrl:(NSString*) imageUrl{
    _username = name;
    _userImageUrl = imageUrl;
}

+ (void) setPerformedInitialSync:(BOOL) didSync{
    _performedInitialSync = didSync;
}

+ (void) incrementCompletedTasks:(NSInteger) number{
    NSInteger newNumber = KeychainStorage.completedTasks + number;
    [KeychainStorage setCompletedTasks:newNumber];
    _pendingCompletedTasks = number;
}

+ (void) setGistToEdit:(OCTGist*) gistToEdit{
    _gistToEdit = gistToEdit;
}

+ (void) setSharedGist:(BOOL) sharedGist{
    LocalData* newData = LocalStorage.localData.clone;
    newData.sharedGist = sharedGist;
    [LocalStorage setLocalData:newData];
}

+ (void) setShowedTutorial:(BOOL) showedTutorial{
    LocalData* newData = LocalStorage.localData.clone;
    newData.showedTutorial = showedTutorial;
    [LocalStorage setLocalData:newData];
}

+ (void) resetAllState{
    [LocalStorage resetLocalData];
    [KeychainStorage resetKeychainData];
    _gistToEdit = nil;
    _userImageUrl = nil;
    _username = nil;
    _performedInitialSync = NO;
    _pendingCompletedTasks = 0;
}

#pragma mark - Task getters

+ (OCTGist*) gistToEdit{
    return _gistToEdit;
}

+ (TaskList*) taskList{
    return LocalStorage.localData.taskList;
}

+ (Task*) taskAtIndex:(NSInteger) index{
    NSMutableArray* tasks = [self tasks];
    return (tasks != nil && index >= tasks.count) ? nil : tasks[index];
}

+ (NSString*) taskDescriptionAtIndex:(NSInteger) index{
    return [self taskAtIndex:index].taskDescription;
}

+ (BOOL) taskIsCompleteAtIndex:(NSInteger) index{
    return [self taskAtIndex:index].completed;
}

+ (NSInteger) taskCount{
    return [self tasks].count;
}

+ (NSURL*) gistUrl{
    return _gistToEdit.HTMLURL ? : [NSURL URLWithString:GIST_URL];
}

+ (NSInteger) pendingCompletedTasks{
    return _pendingCompletedTasks;
}

+ (NSInteger) completedTasks{
    return KeychainStorage.completedTasks;
}

#pragma mark - Users and authentication getters

+ (NSString*) userImageUrl{
    return _userImageUrl ? : @"";
}

+ (NSString*) username{
    return _username ? : @"GistList";
}

+ (BOOL) hasStoredCreds{
    return (KeychainStorage.token.length > 0 && KeychainStorage.userLogin.length > 0);
}

#pragma mark - Misc

+ (BOOL) sharedGist{
    return LocalStorage.localData.sharedGist;
}

+ (BOOL) performedInitialSync{
    return _performedInitialSync;
}

+ (BOOL) showedTutorial{
    return LocalStorage.localData.showedTutorial;
}

@end
