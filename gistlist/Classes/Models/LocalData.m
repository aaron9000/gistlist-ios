#import "LocalData.h"

#define kShowedTutorial @"ShowedTutorial"
#define kTaskList @"TaskList"
#define kScheduledLocalNotification @"ScheduledLocalNotification"

@implementation LocalData

- (LocalData*) clone{
    return [[LocalData alloc] initWithDictionary:[self dictionaryValue]];
}

- (NSDictionary*) dictionaryValue{
    NSDictionary* dict = [_taskList dictionaryValue];
    NSDictionary* taskList = dict != nil ? dict : @{};
    return  @{
                kShowedTutorial: @(_showedTutorial),
                kTaskList: taskList,
                kScheduledLocalNotification: @(_scheduledLocalNotification)
             };
}

- (void) defaultValues{
    _showedTutorial = NO;
    _isNewUser = YES;
    _scheduledLocalNotification = NO;
    _taskList = [[TaskList alloc] init];
}

- (id) init{
    self = [super init];
    if (self){
        [self defaultValues];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary*) dictionary{
    self = [super init];
    if (self){
        if (dictionary){
            _showedTutorial = [dictionary[kShowedTutorial] boolValue];
            _taskList = [[TaskList alloc] initWithDictionary:dictionary[kTaskList]];
            _scheduledLocalNotification = [dictionary[kScheduledLocalNotification] boolValue];
        }else{
            [self defaultValues];
        }
    }
    return self;
}

@end
