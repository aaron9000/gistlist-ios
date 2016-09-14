#import "TestHelper.h"
#import "TestData.h"
#import "Helpers.h"
#import "AppState.h"
#import "KeychainStorage.h"

@implementation TestHelper

+ (TaskList*) taskListRemote{
    return [self taskListRemoteWithLastUpdated:NSDate.date];
}

+ (TaskList*) taskListRemoteWithLastUpdated:(NSDate*) date{
    Task* a = [Task taskWithDescription:@"foo" isCompleted:NO];
    Task* b = [Task taskWithDescription:@"bar" isCompleted:YES];
    Task* c = [Task taskWithDescription:@"qux" isCompleted:NO];
    Task* d = [Task taskWithDescription:@"blek" isCompleted:NO];
    Task* e = [Task taskWithDescription:@"flurp" isCompleted:YES];
    return [[TaskList alloc] initWithTasks:@[a, b, c, d, e] lastUpdated:date];
}

+ (TaskList*) taskListLocal{
    return [self taskListLocalWithLastUpdated:NSDate.date];
}

+ (TaskList*) taskListLocalWithLastUpdated:(NSDate*) date{
    Task* a = [Task taskWithDescription:@"foo" isCompleted:NO];
    Task* b = [Task taskWithDescription:@"bar" isCompleted:YES];
    return [[TaskList alloc] initWithTasks:@[a, b] lastUpdated:date];
}

+ (void) commonSetup {
    [AppState resetAllState];
}

+ (void) commonTeardown {
    // Nothing
}

+ (void) commonOnlineSyncSetup:(id*)ghServiceMockRef withGist:(id*) gistMockRef{
    // Do nothing
}

+ (void) commonOnlineSyncTeardown:(id*)ghServiceMockRef withGist:(id*) gistMockRef {
    [*ghServiceMockRef stopMocking];
    [*gistMockRef stopMocking];
    *ghServiceMockRef = nil;
    *gistMockRef = nil;
}

+ (void) setupForOnlineTests:(NSDate*) localDate remoteDate:(NSDate*) remoteDate service:(id*)ghServiceMockRef withGist:(id*) gistMockRef{
    TaskList* remoteTaskList = self.taskListRemote;
    OCTGist* gist = [[OCTGist alloc] init];
    BOOL localIsMoreRecent = [DateHelper date:remoteDate isOlderThanOtherDate:localDate];
    
    // Gist mock
    id gistMock = OCMClassMock([OCTGist class]);
    OCMStub([gistMock creationDate]).andReturn(remoteDate);
    id remoteGistToReturn = (localIsMoreRecent || !remoteDate) ? nil : gistMock;
    
    // Github service mocks
    id ghServiceMock = OCMClassMock([GithubService class]);
    OCMStub([ghServiceMock userIsAuthenticated]).andReturn(YES);
    OCMStub([ghServiceMock createGistWithContent:OCMArg.any username:OCMArg.any]).andReturn([RACSignal return:gist]);
    OCMStub([ghServiceMock retrieveMostRecentGistSince:OCMArg.any]).andReturn([RACSignal return:remoteGistToReturn]);
    OCMStub([ghServiceMock authenticateWithStoredCredentials]).andReturn([RACSignal return:@(YES)]);
    OCMStub([ghServiceMock updateGist:OCMArg.any withContent:OCMArg.any username:OCMArg.any]).andReturn([RACSignal return:@(YES)]);
    OCMStub([ghServiceMock retrieveGistContentFromUrl:OCMArg.any]).andReturn([RACSignal return:remoteTaskList.contentForTasks]);
    OCMStub(ClassMethod([ghServiceMock sharedService])).andReturn(ghServiceMock);
    
    // Configure local storage
    [AppState setTaskList:localDate ? [self taskListLocalWithLastUpdated:localDate] : nil];
    [KeychainStorage setToken:@"token" userLogin:@"login"];
}


@end
