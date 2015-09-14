//
//  GLTaskList.h
//  ios-base
//
//  Created by Aaron Geisler on 3/14/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

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
- (void) addTask:(Task*) task;

// Construction and conversion
+ (TaskList*) taskListForContent:(NSString*) content;
+ (TaskList*) taskListForContent:(NSString*) content lastUpdated:(NSDate*) lastUpdated;
+ (TaskList*) newTaskListFromOldTaskList:(TaskList*) oldTaskList;
- (BOOL) isEqualToList:(TaskList*) otherList;
- (id) initWithDictionary:(NSDictionary*) dictionary;
- (id) initWithTasks:(NSArray*) tasks lastUpdated:(NSDate*) lastUpdated;
- (NSDictionary*) dictionaryValue;

@end
