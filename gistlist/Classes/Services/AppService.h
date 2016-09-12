#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACSignal+Extensions.h"
#import "TaskList.h"
#import "Task.h"

typedef enum {
    SyncResultFreshInstall,
    SyncResultOfflineReuse,
    SyncResultOfflineNew,
    SyncResultOnlineReuseRemote,
    SyncResultOnlineNewRemote,
    SyncResultOnlineReuseLocal,
    SyncResultOnlineNewLocal
} SyncResult;

@interface AppService : NSObject{

}

// Sessions
+ (RACSignal*) signOut;
+ (RACSignal*) startOfflineSession;
+ (RACSignal*) startOnlineSessionWithStoredCreds;
+ (RACSignal*) startOnlineSessionWithUsername:(NSString*) user password:(NSString*) password auth:(NSString*) auth;

// Synchronization
+ (RACSignal*) syncIfResuming;

// Task Mangement & synchronization
+ (RACSignal*) createViralGist;
+ (RACSignal*) updateTask:(NSInteger) index withText:(NSString*) newText;
+ (RACSignal*) deleteTask:(NSInteger) index;
+ (RACSignal*) toggleTask:(NSInteger) index;
+ (RACSignal*) addNewTaskWithText:(NSString*) text;

// Misc
+ (RACSignal*) startTutorialWithDelay;

@end
