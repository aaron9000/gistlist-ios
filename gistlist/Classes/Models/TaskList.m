#import <ObjectiveSugar.h>
#import "Helpers.h"
#import "TaskList.h"

@implementation TaskList

#pragma mark - Keys and Constants

#define kLastUpdated @"LastUpdated"
#define kTasks @"Tasks"

#pragma mark - Conversion and Construction

+ (TaskList*) taskListForContent:(NSString*) content{
    return [self taskListForContent:content lastUpdated:[NSDate date]];
}

+ (TaskList*) taskListForContent:(NSString*) content lastUpdated:(NSDate*) lastUpdated{
    NSArray* lines = [content split:@"\n"];
    NSArray* tasks = [lines map:^id(NSString* line) {
        return [Task taskFromLine:line];
    }];
    return [[TaskList alloc] initWithTasks:tasks lastUpdated:lastUpdated];
}

+ (TaskList*) newTaskListFromOldTaskList:(TaskList*) oldTaskList{
    NSArray* incompleteTasks = [[oldTaskList.tasks select:^BOOL(Task* task) {
        return !task.completed;
    }] mutableCopy];
    return [[TaskList alloc] initWithTasks:incompleteTasks lastUpdated:[NSDate date]];
}

- (BOOL) isEqualToList:(TaskList*) otherList{
    return [otherList.contentForTasks isEqualToString:self.contentForTasks];
}

- (id) initWithDictionary:(NSDictionary*) dictionary{
    self = [super init];
    if (self){
        NSArray* taskDictionaries = dictionary[kTasks];
        _tasks = [[taskDictionaries map:^id(id object) {
            return [[Task alloc] initWithDictionary:object];
        }] mutableCopy];
        if (_tasks == nil){
            _tasks = [NSMutableArray array];
        }
        _lastUpdated = dictionary[kLastUpdated];
        if (_lastUpdated == nil){
            _lastUpdated = [NSDate dateWithTimeIntervalSince1970:0];
        }
    }
    return self;
}

- (NSDictionary*) dictionaryValue{
    NSArray* taskDictionaries = [_tasks map:^id(id object) {
        return [object dictionaryValue];
    }];
    return @{
                kTasks: taskDictionaries,
                kLastUpdated: _lastUpdated
             };
}

- (id) initWithTasks:(NSArray*) tasks lastUpdated:(NSDate*) lastUpdated{
    self = [super init];
    if (self){
        _tasks = tasks.mutableCopy;
        _lastUpdated = lastUpdated;
    }
    return self;
}

- (id) init{
    self = [super init];
    if (self){
        _tasks = NSMutableArray.array;
        _lastUpdated = DateHelper.oneWeekAgo;
    }
    return self;
}

#pragma mark - Getters

- (Task*) taskAtIndex:(NSInteger) index{
    return (!_tasks || index < 0 || index >= _tasks.count) ? nil : _tasks[index];
}

- (NSInteger) completedTaskCount{
    return [_tasks select:^BOOL(Task* task) {
        return task.completed;
    }].count;
}

- (NSString*) contentForTasks{
    NSString* content = @"";
#warning want reduce
    for (Task* task in _tasks) {
        content = [content stringByAppendingString:task.stringValue];
    }
    return content;
}

#pragma mark - Modifying tasks

- (BOOL) addTask:(Task*) task{
    if (!_tasks) {
        return NO;
    }
    [_tasks insertObject:task atIndex:0];
    return YES;
}

- (BOOL) removeTaskAtIndex:(NSInteger) index{
    if (!_tasks || index < 0 || index >= _tasks.count) {
        return NO;
    }
    [_tasks removeObjectAtIndex:index];
    return YES;
}


@end
