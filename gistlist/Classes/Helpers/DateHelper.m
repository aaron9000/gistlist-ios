//
//  DateHelper.m
//  gistlist
//
//  Created by Aaron Geisler on 9/11/16.
//  Copyright © 2016 Aaron Geisler. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper


+ (NSDate*) twelveAMToday{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    date = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:date]];
    return date;
}

+ (NSDate*) fiveMinutesAgo{
    return [[NSDate date] dateByAddingTimeInterval:-60.0f * 5.0f];
}

+ (NSDate*) oneWeekAgo{
    return [[NSDate date] dateByAddingTimeInterval:-60.0f * 60.0f * 24.0f * 7.0f];
}

+ (NSDate*) twoWeeksAgo{
    return [[NSDate date] dateByAddingTimeInterval:-60.0f * 60.0f * 24.0f * 7.0f * 2.0f];
}

+ (NSDate*) threeWeeksAgo{
    return [[NSDate date] dateByAddingTimeInterval:-60.0f * 60.0f * 24.0f * 7.0f * 3.0f];
}

+ (NSDate*) oneMonthAgo{
    return [[NSDate date] dateByAddingTimeInterval:-60.0f * 60.0f * 24.0f * 30.0f];
}

+ (BOOL) isOlderThan24Hours:(NSDate*) date{
    return [[self twelveAMToday] compare:date] == NSOrderedDescending;
}

+ (BOOL) date:(NSDate*) date isOlderThanOtherDate:(NSDate*) otherDate{
    return [date compare:otherDate] == NSOrderedAscending;
}


@end
