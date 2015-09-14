//
//  Analytics.h
//  gistlist
//
//  Created by Aaron Geisler on 8/3/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsHelper : NSObject

+ (void) appLaunch;

+ (void) createViralGist;
+ (void) showTutorial;
+ (void) localNotifcation;

+ (void) taskCreate:(NSString*) task;
+ (void) taskModify;
+ (void) taskToggle;
+ (void) taskDelete;

+ (void) settingsCopyURL;
+ (void) settingsShareEmail;
+ (void) settingsShareSMS;
+ (void) settingsShareEmailSuccess;
+ (void) settingsShareSMSSuccess;
+ (void) settingsViewOnGithub;
+ (void) settingsLeaveReview;
+ (void) settingsMoreApps;
+ (void) settingsCredits;
+ (void) settingsSignOut;
+ (void) settingsFeatureUnavailable;

+ (void) mainMenuSync;
+ (void) mainMenuOffline;

+ (void) loginVerify;
+ (void) loginSignIn;
+ (void) loginFailure;

@end
