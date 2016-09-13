@import Nimble;
#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <OCMock/OCMock.h>
#import <Foundation/Foundation.h>
#import <Octokit/OctoKit.h>
#import "TaskList.h"

@interface TestHelper : NSObject

+ (TaskList*) taskList;
+ (TaskList*) taskListWithLastUpdated:(NSDate*) date;
+ (TaskList*) taskListAlternate;
+ (TaskList*) taskListAlternateWithLastUpdated:(NSDate*) date;
+ (OCTGist*) gistWithCreationDate:(NSDate*) date;

@end
