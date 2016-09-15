#import "Task.h"
#import <ObjectiveSugar.h>

#define kCompleted @"Completed"
#define kDescription @"Description"
#define kUncheckedToken @"- [ ] "
#define kCheckedToken @"- [x] "

@implementation Task

- (NSString*) stringValue{
    return [NSString stringWithFormat:@"%@%@\n", _completed ? kCheckedToken : kUncheckedToken, _taskDescription];
}

+ (BOOL) string:(NSString*) string hasPrefix:(NSString*) prefix{
    if (string.length < prefix.length){
        return NO;
    }
    return [[string substringToIndex:prefix.length] isEqualToString:prefix];
}

- (NSDictionary*) dictionaryValue{
    return @{
                kDescription: _taskDescription,
                kCompleted: @(_completed)
             };
}

- (id) initWithDictionary:(NSDictionary*) dictionary{
    self = [super init];
    if (self){
        _taskDescription = dictionary[kDescription];
        _completed = [dictionary[kCompleted] boolValue];
    }
    return self;
}

+ (Task*) taskFromLine:(NSString*) line{
    NSString* sanitizedLine = [line strip];
    BOOL checked = [self string:sanitizedLine hasPrefix:kCheckedToken];
    BOOL unchecked = [self string:sanitizedLine hasPrefix:kUncheckedToken];
    if (checked || unchecked){
        sanitizedLine = checked ?
        [sanitizedLine stringByReplacingOccurrencesOfString:kCheckedToken withString:@""] :
        [sanitizedLine stringByReplacingOccurrencesOfString:kUncheckedToken withString:@""];
        [sanitizedLine strip];
        return [Task taskWithDescription:sanitizedLine isCompleted:checked];
    }else{
        return nil;
    }
}

+ (Task*) taskWithDescription:(NSString*) description isCompleted:(BOOL) completed{
    Task* task = [[Task alloc] init];
    task.completed = completed;
    task.taskDescription = description;
    return task;
}

@end
