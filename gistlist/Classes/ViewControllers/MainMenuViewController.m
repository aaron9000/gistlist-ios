//
//  LoginViewController.m
//  ios-base
//
//  Created by Aaron Geisler on 3/13/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <SVProgressHUD.h>
#import "AppState.h"
#import "AppDelegate.h"
#import "MainMenuViewController.h"
#import "TasksViewController.h"
#import "LoginViewController.h"
#import "AppService.h"
#import "Helpers.h"
#import "Macros.h"
#import "Extensions.h"
#import "GLTheme.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void) showTasks{
    [self pushViewController:[[TasksViewController alloc] init]];
}

- (void) showLogin{
    [self pushViewController:[[LoginViewController alloc] init]];
}

- (void) useOffline{
    [AnalyticsHelper mainMenuOffline];
    [[AppService startOfflineSession] subscribeNext:^(id x) {
        [self showTasks];
    }];
}

- (void) attemptLogin{
    [AnalyticsHelper mainMenuSync];
    [self showLogin];
}

- (void) attemptLoginWithStoredCreds{
    AppDelegate* appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    if (AppState.userIsAuthenticated){
        [appDelegate registerAndScheduleNotifications];
        [self showTasks];
        return;
    }
    
    if (AppState.hasStoredCreds){
        [[[AppService startOnlineSessionWithStoredCreds] withLoadingSpinner] subscribeNext:^(NSNumber* completedTasks) {
            [DialogHelper attemptShowRewardToast:completedTasks.integerValue];
            [appDelegate registerAndScheduleNotifications];
            [self showTasks];
        }];
    }else{
        [NSObject performBlock:^{
            [appDelegate registerAndScheduleNotifications];
        } afterDelay:1.0f];
    }
}

- (void) setup{
    
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 400)];
    float padding = [self verticalPadding];
    
    _logo = [containerView addCenteredLogoWithImage:[GLTheme imageOfLoginGlLogo] withY:0];
    
    float offsetY = _logo.frame.size.height + (padding * 0.5f);
    _offline = [containerView addButtonWithColor:[GLTheme buttonColorBlue]
                               withText:@"Use Offline"
                                      y:offsetY
                                   image:[GLTheme imageOfLoginIconOffline]];
    [[_offline rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self useOffline];
    }];
    
    _sync = [containerView addButtonWithColor:[GLTheme buttonColorGreen]
                    withText:@"Sync with GitHub"
                                   y:offsetY + padding
                        image:[GLTheme imageOfLoginIconGithub]];
    [[_sync rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self attemptLogin];
    }];
    
    [containerView wta_setFrameSizeHeight:_sync.frame.size.height + _sync.frame.origin.y];
    [self.view addSubview:containerView];
    [containerView wta_centerAlignVerticallyInSuperviewOffset:offsetY * -0.5f];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self attemptLoginWithStoredCreds];
}

@end
