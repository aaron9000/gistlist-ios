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

+ (NSDate*) oneWeekAgo{
    return [[NSDate date] dateByAddingTimeInterval:-60.0f * 60.0f * 24.0f * 7.0f];
}

+ (BOOL) isOlderThan24Hours:(NSDate*) date{
    return [[self twelveAMToday] compare:date] == NSOrderedDescending;
}


@end
