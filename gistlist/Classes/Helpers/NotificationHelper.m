//
//  NotificationHelper.m
//  gistlist
//
//  Created by Aaron Geisler on 4/23/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import "NotificationHelper.h"
#import "LocalStorage.h"

@implementation NotificationHelper


+ (void) attemptScheduleLocalNotification{
    
    LocalData* localData = [LocalStorage localData];
    if (localData.scheduledLocalNotification == NO){
        [localData setScheduledLocalNotification:YES];
        [LocalStorage setLocalData:localData];
    }else{
        return;
    }
    
    // Determine the fire date
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate* date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay) fromDate:date];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:dateComponents.day];
    [dateComps setMonth:dateComponents.month];
    [dateComps setYear:dateComponents.year];
    [dateComps setHour:11];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    NSDate* fireDate = [calendar dateFromComponents:dateComps];
    float oneDay = 60 * 60 * 24;
    fireDate = [NSDate dateWithTimeInterval:oneDay sinceDate:fireDate];
    
    // setup notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"You have items in your TODO";
    localNotification.alertAction = @"View Tasks";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
