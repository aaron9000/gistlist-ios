#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic) BOOL completed;
@property (nonatomic, strong) NSString* taskDescription;

- (NSString*) stringValue;
- (NSDictionary*) dictionaryValue;
+ (Task*) taskFromLine:(NSString*) line;
+ (Task*) taskWithDescription:(NSString*) description isCompleted:(BOOL) completed;
- (id) initWithDictionary:(NSDictionary*) dictionary;
- (id) initWithDescription:(NSString*) description completed:(BOOL) completed;

@end
