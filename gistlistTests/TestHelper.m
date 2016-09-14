#import "TestHelper.h"
#import "TestData.h"
#import "Helpers.h"

@implementation TestHelper

+ (TaskList*) taskListAlternate{
    return [self taskListAlternateWithLastUpdated:NSDate.date];
}

+ (TaskList*) taskListAlternateWithLastUpdated:(NSDate*) date{
    Task* a = [Task taskWithDescription:@"foo" isCompleted:NO];
    Task* b = [Task taskWithDescription:@"bar" isCompleted:YES];
    Task* c = [Task taskWithDescription:@"qux" isCompleted:NO];
    Task* d = [Task taskWithDescription:@"blek" isCompleted:NO];
    Task* e = [Task taskWithDescription:@"flurp" isCompleted:YES];
    return [[TaskList alloc] initWithTasks:@[a, b, c, d, e] lastUpdated:date];
}

+ (TaskList*) taskList{
    return [self taskListWithLastUpdated:NSDate.date];
}

+ (TaskList*) taskListWithLastUpdated:(NSDate*) date{
    Task* a = [Task taskWithDescription:@"foo" isCompleted:NO];
    Task* b = [Task taskWithDescription:@"bar" isCompleted:YES];
    return [[TaskList alloc] initWithTasks:@[a, b] lastUpdated:date];
}


@end
