//
//  AppDelegate.h
//  gistlist
//
//  Created by Aaron Geisler on 3/28/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LandingViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
}

@property (strong, nonatomic) LandingViewController* landingViewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

- (void) registerAndScheduleNotifications;

@end
