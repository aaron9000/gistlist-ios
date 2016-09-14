
#import "AppDelegate.h"
#import <iRate.h>
#import <Crittercism.h>
#import <Mixpanel.h>
#import <CocoaLumberjack.h>
#import <SVProgressHUD.h>
#import "LandingViewController.h"
#import "AppState.h"
#import "AppService.h"
#import "Helpers.h"
#import "Config.h"
#import "GLTheme.h"
#import "Extensions.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Static

+ (void) initialize{
    [self setupIRate];
}

#pragma mark - Local Notifications

- (void) registerAndScheduleNotifications{
    [self registerForNotifications];
    [NotificationHelper attemptScheduleLocalNotification];
}

- (void) registerForNotifications{
    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{

}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    [AnalyticsHelper localNotifcation];
}

- (void) handleNotificationOnAppLaunch:(UILocalNotification*) localNotification{
    [AnalyticsHelper localNotifcation];
}

#pragma mark - Third Party

+ (void) setupIRate{
    [iRate sharedInstance].appStoreID = APP_STORE_ID;
#if DEBUG
    [iRate sharedInstance].previewMode = NO;
#else
    [iRate sharedInstance].previewMode = NO;
#endif
    [iRate sharedInstance].eventsUntilPrompt = 3;
}

- (void) setupThirdParty{
    [Crittercism enableWithAppID:CRITTERCISM_TOKEN];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    [SVProgressHUD setBackgroundColor:[GLTheme backgroundColorSpinner]];
    [SVProgressHUD setForegroundColor:[GLTheme textColorSpinner]];
    [SVProgressHUD setFont:[UIFont fontWithName:FONT size:16]];
}

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([URL.host isEqual:@"oauth"]) {
        [OCTClient completeSignInWithCallbackURL:URL];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #ifdef TEST
        return;
    #endif
    
    // Thirdparty libraries
    [self setupThirdParty];
    
    // Setup window and root view controller
    _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _window.backgroundColor = UIColor.blackColor;
    LandingViewController* vc = [[LandingViewController alloc] init];
    _navController = [[UINavigationController alloc] initWithRootViewController:vc];
    _navController.navigationBarHidden = YES;
    _window.rootViewController = _navController;
    [_window addSubview:vc.view];
    [_window makeKeyAndVisible];
    
    // Handle launching from a notification
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self handleNotificationOnAppLaunch:localNotification];
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    #ifdef TEST
        return;
    #endif
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    RACSignal* sync = AppState.performedInitialSync ?
    [[AppService.sharedService syncIfResuming] withLoadingSpinner] :
    [AppService.sharedService syncIfResuming];
    [sync subscribeNext:^(NSNumber* completedTasks) {
        [DialogHelper attemptShowRewardToast:completedTasks.integerValue];
    } error:^(NSError *error) {
        [DialogHelper showSyncFailedToast];
    }];
}

@end
