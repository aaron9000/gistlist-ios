#import <Foundation/Foundation.h>
#import "Task.h"

@interface TaskList : NSObject{

}

@property (nonatomic, strong) NSMutableArray* tasks;
@property (nonatomic, strong) NSDate* lastUpdated;

// Getters
- (NSString*) contentForTasks;
- (NSInteger) completedTaskCount;
- (Task*) taskAtIndex:(NSInteger) index;

// Modification of tasks
- (BOOL) removeTaskAtIndex:(NSInteger) index;
- (BOOL) addTask:(Task*) task;

// Construction and conversion
+ (TaskList*) taskListForContent:(NSString*) content;
+ (TaskList*) taskListForContent:(NSString*) content lastUpdated:(NSDate*) lastUpdated;
+ (TaskList*) newTaskListFromOldTaskList:(TaskList*) oldTaskList;
- (BOOL) isEqualToList:(TaskList*) otherList;
- (id) initWithDictionary:(NSDictionary*) dictionary;
- (id) initWithTasks:(NSArray*) tasks lastUpdated:(NSDate*) lastUpdated;
- (NSDictionary*) dictionaryValue;

@end
