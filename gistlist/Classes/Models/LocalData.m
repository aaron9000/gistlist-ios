#import "LocalData.h"

#define kScheduledLocalNotification @"ScheduledLocalNotification"
#define kShowedTutorial @"ShowedTutorial"
#define kTaskList @"TaskList"
#define kIsNewUser @"IsNewUser"

@implementation LocalData

- (LocalData*) clone{
    return [[LocalData alloc] initWithDictionary:[self dictionaryValue]];
}

- (NSDictionary*) dictionaryValue{
    NSDictionary* dict = [_taskList dictionaryValue];
    NSDictionary* taskList = dict != nil ? dict : @{};
    return  @{
                kShowedTutorial: @(_showedTutorial),
                kIsNewUser: @(_isNewUser),
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
            
            _taskList = [[TaskList alloc] initWithDictionary:dictionary[kTaskList]];
            _scheduledLocalNotification = [dictionary[kScheduledLocalNotification] boolValue];
            _showedTutorial = [dictionary[kShowedTutorial] boolValue];
            _isNewUser = [dictionary[kIsNewUser] boolValue];
        }else{
            [self defaultValues];
        }
    }
    return self;
}

@end
