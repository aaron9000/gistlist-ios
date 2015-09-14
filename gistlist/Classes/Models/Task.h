//
//  GLTask.h
//  ios-base
//
//  Created by Aaron Geisler on 3/13/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic) BOOL completed;
@property (nonatomic, strong) NSString* taskDescription;

- (NSString*) stringValue;
- (NSDictionary*) dictionaryValue;
+ (Task*) taskFromLine:(NSString*) line;
+ (Task*) taskWithDescription:(NSString*) description isCompleted:(BOOL) completed;
- (id) initWithDictionary:(NSDictionary*) dictionary;

@end
