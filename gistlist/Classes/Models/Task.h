#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic) BOOL completed;
@property (nonatomic, strong) NSString* taskDescription;

+ (Task*) taskFromLine:(NSString*) line;
+ (Task*) taskWithDescription:(NSString*) description isCompleted:(BOOL) completed;

- (NSString*) stringValue;
- (NSDictionary*) dictionaryValue;
- (id) initWithDictionary:(NSDictionary*) dictionary;

@end
