//
//  DateHelper.h
//  gistlist
//
//  Created by Aaron Geisler on 9/11/16.
//  Copyright © 2016 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject

+ (NSDate*) twelveAMToday;
+ (NSDate*) fiveMinutesAgo;
+ (NSDate*) oneWeekAgo;
+ (NSDate*) twoWeeksAgo;
+ (NSDate*) threeWeeksAgo;
+ (NSDate*) oneMonthAgo;
+ (BOOL) isOlderThan24Hours:(NSDate*) date;
+ (BOOL) date:(NSDate*) date isOlderThanOtherDate:(NSDate*) otherDate;

@end
