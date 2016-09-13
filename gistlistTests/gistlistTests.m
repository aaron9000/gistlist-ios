#import "TestHelper.h"
#import "KeychainStorage.h"
#import "LocalStorage.h"
#import "TaskList.h"
#import "GithubService.h"
#import "AppState.h"
#import "AppService.h"
#import "Helpers.h"

#pragma mark - Helper Tests

#pragma mark - Model Tests

QuickSpecBegin(TaskListTests)

it(@"converts tasks to markdown", ^{
    TaskList* list = [TestHelper taskList];
    expect(list.contentForTasks).to(equal(@"- [ ] foo\n- [x] bar\n"));
});

it(@"counts completed tasks", ^{
    TaskList* list = [TestHelper taskList];
    expect(@(list.completedTaskCount)).to(equal(@(1)));
});

it(@"retrieves tasks by index", ^{
    TaskList* list = [TestHelper taskList];
    Task* a = list.tasks[0];
    Task* b = list.tasks[1];
    expect(a.taskDescription).to(equal(@"foo"));
    expect(@(a.completed)).to(equal(@(NO)));
    expect(b.taskDescription).to(equal(@"bar"));
    expect(@(b.completed)).to(equal(@(YES)));
});

it(@"converts markdown to task", ^{
    NSDate* d = [NSDate dateWithTimeIntervalSince1970:10000];
    TaskList* list = [TaskList taskListForContent:@"- [ ] foo\n- [x] bar\n" lastUpdated:d];
    Task* a = list.tasks[0];
    Task* b = list.tasks[1];
    expect(a.taskDescription).to(equal(@"foo"));
    expect(@(a.completed)).to(equal(@(NO)));
    expect(b.taskDescription).to(equal(@"bar"));
    expect(@(b.completed)).to(equal(@(YES)));
    expect(list.lastUpdated).to(equal(d));
});

it(@"tests equality correctly", ^{
    TaskList* a = [TestHelper taskList];
    TaskList* b = [TestHelper taskList];
    TaskList* c = [TestHelper taskList];
    ((Task*)c.tasks[0]).taskDescription = @"qux";
    expect(@([a isEqualToList:b])).to(equal(@(YES)));
    expect(@([a isEqualToList:a])).to(equal(@(YES)));
    expect(@([a isEqualToList:c])).to(equal(@(NO)));
});

it(@"creats a new task list from old task list (removing completed tasks)", ^{
    TaskList* a = [TestHelper taskList];
    TaskList* b = [TaskList newTaskListFromOldTaskList:a];
    expect(@(a.tasks.count)).to(equal(@(2)));
    expect(@(b.tasks.count)).to(equal(@(1)));
    expect(a.lastUpdated).toNot(equal(b.lastUpdated));
});

it(@"converts to and from a dictionary", ^{
    TaskList* a = [TestHelper taskList];
    NSDictionary* d = a.dictionaryValue;
    expect(d[@"Tasks"]).toNot(beNil());
    expect(d[@"LastUpdated"]).toNot(beNil());
    TaskList* b = [[TaskList alloc] initWithDictionary:d];
    expect(@([a isEqualToList:b])).to(equal(@(YES)));
});

QuickSpecEnd


#pragma mark - Storage Tests

QuickSpecBegin(KeychainStorageTests)

it(@"loads and stores completed tasks", ^{
    
    [KeychainStorage setCompletedTasks:5];
    expect(@(KeychainStorage.completedTasks)).to(equal(@(5)));
    
    [KeychainStorage setCompletedTasks:1];
    expect(@(KeychainStorage.completedTasks)).to(equal(@(1)));
});

it(@"loads and stores login credentials", ^{
    
    [KeychainStorage setToken:@"token" userLogin:@"login"];
    expect(KeychainStorage.token).to(equal(@"token"));
    expect(KeychainStorage.userLogin).to(equal(@"login"));
    
    [KeychainStorage setToken:@"a" userLogin:@"b"];
    expect(KeychainStorage.token).to(equal(@"a"));
    expect(KeychainStorage.userLogin).to(equal(@"b"));
});

QuickSpecEnd

QuickSpecBegin(LocalStorageTests)

it(@"loads and stores local data blobs", ^{
    LocalData* data = [[LocalData alloc] init];
    data.taskList = TestHelper.taskList;
    data.showedTutorial = YES;
    data.isNewUser = YES;
    data.sharedGist = YES;
    data.scheduledLocalNotification = YES;
    [LocalStorage setLocalData:data];
    LocalData* retrievedData = LocalStorage.localData;
    
    expect(@([retrievedData.taskList isEqualToList:data.taskList])).to(equal(@(YES)));
    expect(@(retrievedData.isNewUser)).to(equal(@(YES)));
});

QuickSpecEnd

#pragma mark - Service Tests

QuickSpecBegin(GithubServiceTests)

it(@"loads text from a valid gist raw url", ^{
    NSString* url = @"https://gist.githubusercontent.com/aaron9000/5571bec531688cecc69db2b7196d8566/raw/2e9267e70d53c1ca319c9a9bd85979e8079630e0/test.txt";
    __block NSString* content = nil;
    [[GithubService retrieveGistContentFromUrl:[NSURL URLWithString:url]] subscribeNext:^(NSString* c) {
        content = c;
    }];
    expect(content).toEventually(equal(@"dolphin"));
});

QuickSpecEnd


QuickSpecBegin(AppServiceTests)

it(@"does not sync on resume if we have not started a session", ^{
    __block id a = @(999);
    [AppState resetAllState];
    expect(@(AppState.performedInitialSync)).to(equal(@(NO)));
    [[AppService syncIfResuming] subscribeNext:^(id x) {
        a = x;
    }];
    expect(a).toEventually(equal(@(-1)));
});

it(@"syncs on resume after starting an online session", ^{
    __block id a = @(999);
    [AppState resetAllState];
    [[[AppService startOfflineSession] flattenMap:^RACStream *(id value) {
        expect(@(AppState.performedInitialSync)).to(equal(@(YES)));
        return [AppService syncIfResuming];
    }] subscribeNext:^(id x) {
        a = x;
    }];
    expect(a).toEventually(equal(@(0)));
});

it(@"offline sync restores clears old tasks when tasklist is old", ^{
    NSDate* oneWeekAgo = DateHelper.oneWeekAgo;
    
    [AppState resetAllState];
    [AppState setTaskList:[TestHelper taskListWithLastUpdated:oneWeekAgo]];
    expect(AppState.taskList.lastUpdated).to(equal(oneWeekAgo));
    expect(@(AppState.taskList.tasks.count)).to(equal(@(2)));
    
    __block id a = @(999);
    __block id b = @(999);
    [[[AppService startOfflineSession] flattenMap:^RACStream *(id x) {
        a = x;
        expect(@(AppState.taskList.tasks.count)).to(equal(@(1)));
        return [AppService syncIfResuming];
    }] subscribeNext:^(id x) {
        b = x;
    }];
    expect(a).toEventually(equal(@(1)));
    expect(b).toEventually(equal(@(0)));
});

QuickSpecEnd



