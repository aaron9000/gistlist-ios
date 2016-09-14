@import Nimble;
#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <OCMock/OCMock.h>
#import <Foundation/Foundation.h>
#import "AppService.h"
#import "GithubService.h"

@interface TestHelper : NSObject

+ (TaskList*) taskList;
+ (TaskList*) taskListWithLastUpdated:(NSDate*) date;
+ (TaskList*) taskListAlternate;
+ (TaskList*) taskListAlternateWithLastUpdated:(NSDate*) date;

@end
