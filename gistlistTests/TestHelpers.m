//
//  TestHelpers.m
//  gistlist
//
//  Created by Aaron Geisler on 9/11/16.
//  Copyright © 2016 Aaron Geisler. All rights reserved.
//

#import "TestHelpers.h"
#import <ISO8601DateFormatter.h>
#import "TestData.h"

@implementation TestHelpers

+ (TaskList*) taskList{
    return [self taskListWithLastUpdated:NSDate.date];
}

+ (TaskList*) taskListWithLastUpdated:(NSDate*) date{
    Task* a = [Task taskWithDescription:@"foo" isCompleted:NO];
    Task* b = [Task taskWithDescription:@"bar" isCompleted:YES];
    return [[TaskList alloc] initWithTasks:@[a, b] lastUpdated:date];
}

+ (OCTGist*) gistWithCreationDate:(NSDate*) date{
    NSError* error = nil;
    ISO8601DateFormatter* formatter = [[ISO8601DateFormatter alloc] init];
    NSMutableDictionary* dict = TestData.sampleGistData.mutableCopy;
    dict[@"created_at"] = [formatter stringFromDate:date];
    return [[OCTGist alloc] initWithDictionary:dict error:&error];
}

@end
