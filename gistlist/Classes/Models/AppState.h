#import <Foundation/Foundation.h>
#import <OctoKit.h>
#import "TaskList.h"

@interface AppState : NSObject

// Setters
+ (void) setPendingCompletedTasks:(NSInteger) tasks;
+ (void) setTaskList:(TaskList*) taskList;
+ (void) setUserName:(NSString*) name andUserImageUrl:(NSString*) imageUrl;
+ (void) setPerformedInitialSync:(BOOL) didSync;
+ (void) incrementCompletedTasks:(NSInteger) number;
+ (void) setGistToEdit:(OCTGist*) gistToEdit;
+ (void) setSharedGist:(BOOL) sharedGist;
+ (void) setShowedTutorial:(BOOL) showedTutorial;

// Task getters
+ (OCTGist*) gistToEdit;
+ (TaskList*) taskList;
+ (NSString*) taskDescriptionAtIndex:(NSInteger) index;
+ (Task*) taskAtIndex:(NSInteger) index;
+ (BOOL) taskIsCompleteAtIndex:(NSInteger) index;
+ (NSInteger) taskCount;
+ (NSURL*) gistUrl;
+ (NSInteger) pendingCompletedTasks;
+ (NSInteger) completedTasks;

// Authentication & user getter
+ (BOOL) hasStoredCreds;
+ (BOOL) userIsAuthenticated;
+ (NSString*) userImageUrl;
+ (NSString*) username;

// Misc
+ (BOOL) performedInitialSync;
+ (BOOL) sharedGist;
+ (BOOL) showedTutorial;


@end
