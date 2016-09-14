@import Nimble;
#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <OCMock/OCMock.h>
#import <Foundation/Foundation.h>
#import "AppService.h"
#import "GithubService.h"

@interface TestHelper : NSObject

+ (TaskList*) taskListLocal;
+ (TaskList*) taskListLocalWithLastUpdated:(NSDate*) date;
+ (TaskList*) taskListRemote;
+ (TaskList*) taskListRemoteWithLastUpdated:(NSDate*) date;

+ (void) setupForOnlineTests:(NSDate*) localDate remoteDate:(NSDate*) remoteDate service:(id*)ghServiceMockRef withGist:(id*) gistMockRef;
+ (void) commonTeardown;
+ (void) commonOnlineSyncTeardown:(id*)ghServiceMockRef withGist:(id*) gistMockRef;

@end
