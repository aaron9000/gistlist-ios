//
//  Analytics.m
//  gistlist
//
//  Created by Aaron Geisler on 8/3/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import "AnalyticsHelper.h"
#import <Mixpanel.h>

@implementation AnalyticsHelper

+ (void) appLaunch{
    [[Mixpanel sharedInstance] track:@"App - Launch"];
}

+ (void) createViralGist{
    [[Mixpanel sharedInstance] track:@"Virality - Create Gist"];
}

+ (void) showTutorial{
    [[Mixpanel sharedInstance] track:@"Tutorial - Show"];
}

+ (void) localNotifcation{
    [[Mixpanel sharedInstance] track:@"Local Notification"];
}

+ (void) taskCreate:(NSString*) task{
    [[Mixpanel sharedInstance] track:@"Task - Create" properties:@{@"task" : task ? : @""}];
}

+ (void) taskToggle{
    [[Mixpanel sharedInstance] track:@"Task - Toggle"];
}

+ (void) taskModify{
    [[Mixpanel sharedInstance] track:@"Task - Modify"];
}

+ (void) taskDelete{
    [[Mixpanel sharedInstance] track:@"Task - Delete"];
}

+ (void) settingsCopyURL{
    [[Mixpanel sharedInstance] track:@"Task - Delete"];
}

+ (void) settingsShareEmail{
    [[Mixpanel sharedInstance] track:@"Settings - Share Email"];
}

+ (void) settingsShareSMS{
    [[Mixpanel sharedInstance] track:@"Settings - Share SMS"];
}

+ (void) settingsShareEmailSuccess{
    [[Mixpanel sharedInstance] track:@"Settings - Share Email - Success"];
}

+ (void) settingsShareSMSSuccess{
    [[Mixpanel sharedInstance] track:@"Settings - Share SMS - Success"];
}

+ (void) settingsViewOnGithub{
    [[Mixpanel sharedInstance] track:@"Settings - View on Github"];
}

+ (void) settingsLeaveReview{
    [[Mixpanel sharedInstance] track:@"Settings - Leave Review"];
}

+ (void) settingsMoreApps{
    [[Mixpanel sharedInstance] track:@"Settings - More Apps"];
}

+ (void) settingsCredits{
    [[Mixpanel sharedInstance] track:@"Settings - Credits"];
}

+ (void) settingsSignOut{
    [[Mixpanel sharedInstance] track:@"Settings - Sign Out"];
}

+ (void) settingsFeatureUnavailable{
    [[Mixpanel sharedInstance] track:@"Settings - Feature Unavailable"];    
}

+ (void) mainMenuSync{
    [[Mixpanel sharedInstance] track:@"Main Menu - Sync"];
}

+ (void) mainMenuOffline{
    [[Mixpanel sharedInstance] track:@"Main Menu - Offline"];
}

+ (void) loginVerify{
    [[Mixpanel sharedInstance] track:@"Login - Verify"];
}

+ (void) loginSignIn{
    [[Mixpanel sharedInstance] track:@"Login - Sign In"];
}

+ (void) loginFailure{
    [[Mixpanel sharedInstance] track:@"Login - Failure"];   
}

@end
