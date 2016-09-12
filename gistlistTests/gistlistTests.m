#import "TestHelpers.h"
#import "KeychainStorage.h"
#import "TaskList.h"

#pragma mark - Helper Tests

#pragma mark - Model Tests

QuickSpecBegin(TaskListTests)

//// Getters
//- (NSString*) contentForTasks;
//- (NSInteger) completedTaskCount;
//- (Task*) taskAtIndex:(NSInteger) index;
//
//// Modification of tasks
//- (BOOL) removeTaskAtIndex:(NSInteger) index;
//- (BOOL) addTask:(Task*) task;
//
//// Construction and conversion
//+ (TaskList*) taskListForContent:(NSString*) content;
//+ (TaskList*) taskListForContent:(NSString*) content lastUpdated:(NSDate*) lastUpdated;
//+ (TaskList*) newTaskListFromOldTaskList:(TaskList*) oldTaskList;
//- (BOOL) isEqualToList:(TaskList*) otherList;
//- (id) initWithDictionary:(NSDictionary*) dictionary;
//- (id) initWithTasks:(NSArray*) tasks lastUpdated:(NSDate*) lastUpdated;
//- (NSDictionary*) dictionaryValue;

it(@"converts tasks to markdown", ^{
    
    TaskList* list = [TestHelpers taskList];
    expect(list.contentForTasks).to(equal(@"- [ ] foo\n- [x] bar\n"));
});

it(@"counts completed tasks", ^{
    TaskList* list = [TestHelpers taskList];
    expect(@(list.completedTaskCount)).to(equal(@(1)));
});

it(@"retrieves tasks by index", ^{
    TaskList* list = [TestHelpers taskList];
    Task* a = list.tasks[0];
    Task* b = list.tasks[1];
    expect(a.taskDescription).to(equal(@"foo"));
    expect(@(a.completed)).to(equal(@(NO)));
    expect(b.taskDescription).to(equal(@"bar"));
    expect(@(b.completed)).to(equal(@(YES)));
});

it(@"converts markdown to task", ^{
    TaskList* list = [TaskList taskListForContent:@"- [ ] foo\n- [x] bar\n"];
    Task* a = list.tasks[0];
    Task* b = list.tasks[1];
    expect(a.taskDescription).to(equal(@"foo"));
    expect(@(a.completed)).to(equal(@(NO)));
    expect(b.taskDescription).to(equal(@"bar"));
    expect(@(b.completed)).to(equal(@(YES)));
});

//it(@"loads and stores login credentials", ^{
//    
//    [KeychainStorage setToken:@"token" userLogin:@"login"];
//    expect(KeychainStorage.token).to(equal(@"token"));
//    expect(KeychainStorage.userLogin).to(equal(@"login"));
//    
//    [KeychainStorage setToken:@"a" userLogin:@"b"];
//    expect(KeychainStorage.token).to(equal(@"a"));
//    expect(KeychainStorage.userLogin).to(equal(@"b"));
//});

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

//it(@"loads and stores completed tasks", ^{
//    
//    [KeychainStorage setCompletedTasks:5];
//    expect(@(KeychainStorage.completedTasks)).to(equal(@(5)));
//    
//    [KeychainStorage setCompletedTasks:1];
//    expect(@(KeychainStorage.completedTasks)).to(equal(@(1)));
//});
//
//it(@"loads and stores login credentials", ^{
//    
//    [KeychainStorage setToken:@"token" userLogin:@"login"];
//    expect(KeychainStorage.token).to(equal(@"token"));
//    expect(KeychainStorage.userLogin).to(equal(@"login"));
//    
//    [KeychainStorage setToken:@"a" userLogin:@"b"];
//    expect(KeychainStorage.token).to(equal(@"a"));
//    expect(KeychainStorage.userLogin).to(equal(@"b"));
//});

QuickSpecEnd

#pragma mark - Service Tests




