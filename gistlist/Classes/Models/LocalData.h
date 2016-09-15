#import <Foundation/Foundation.h>
#import "TaskList.h"

@interface LocalData : NSObject{
    
}
@property (nonatomic) BOOL isNewUser;
@property (nonatomic) BOOL sharedGist;
@property (nonatomic) BOOL showedTutorial;
@property (nonatomic) BOOL scheduledLocalNotification;
@property (nonatomic, strong) TaskList* taskList;

- (id) initWithDictionary:(NSDictionary*) dictionary;
- (NSDictionary*) dictionaryValue;
- (LocalData*) clone;

@end
