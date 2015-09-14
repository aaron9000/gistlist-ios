//
//  LocalSettings.h
//  Blob
//
//  Created by Aaron Geisler on 3/18/13.
//
//

#import <Foundation/Foundation.h>
#import "TaskList.h"

@interface LocalData : NSObject{
    
}
@property (nonatomic) BOOL isNewUser;
@property (nonatomic) BOOL showedTutorial;
@property (nonatomic) BOOL scheduledLocalNotification;
@property (nonatomic, strong) TaskList* taskList;

- (id) initWithDictionary:(NSDictionary*) dictionary;
- (NSDictionary*) dictionaryValue;
- (LocalData*) clone;

@end
