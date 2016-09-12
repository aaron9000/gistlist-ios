//
//  TestHelpers.m
//  gistlist
//
//  Created by Aaron Geisler on 9/11/16.
//  Copyright © 2016 Aaron Geisler. All rights reserved.
//

#import "TestHelpers.h"

@implementation TestHelpers

+ (TaskList*) taskList{
    Task* a = [Task taskWithDescription:@"foo" isCompleted:NO];
    Task* b = [Task taskWithDescription:@"bar" isCompleted:YES];
    return [[TaskList alloc] initWithTasks:@[a, b] lastUpdated:[NSDate date]];
}

@end
