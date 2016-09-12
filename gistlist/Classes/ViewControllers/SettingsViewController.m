//
//  SettingsViewController.m
//  gistlist
//
//  Created by Aaron Geisler on 3/19/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <iRate.h>
#import <SDWebImageDownloader.h>
#import <CocoaLumberjack.h>
#import <SVProgressHUD.h>
#import "Extensions.h"
#import "SettingsViewController.h"
#import "Helpers.h"
#import "GithubService.h"
#import "AppService.h"
#import "AppState.h"
#import "Macros.h"
#import "Config.h"
#import "GLTheme.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

#pragma mark - Constants

#define SETTINGS_BUTTON_HEIGHT 44.0f

#pragma mark - Email

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled:
        case MFMailComposeResultFailed:
        case MFMailComposeResultSaved:
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            break;
        case MFMailComposeResultSent:
            [AnalyticsHelper settingsShareEmailSuccess];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            break;
    }
}

#pragma mark - SMS

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultCancelled:
        case MessageComposeResultFailed:
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            break;
        case MessageComposeResultSent:
            [AnalyticsHelper settingsShareSMSSuccess];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            break;
    }
}

#pragma mark - Line Views

- (UIView*) lineView{
    CGRect lineRect = CGRectMake(80, 78, SCREEN_WIDTH - 80, LINE_HEIGHT);
    UIView* line = [[UIView alloc] initWithFrame:lineRect];
    line.backgroundColor = [GLTheme tileColorDivider];
    return line;
}

- (UIView*) topLineView{
    CGRect lineRect = CGRectMake(0, 0, SCREEN_WIDTH, LINE_HEIGHT);
    UIView* line = [[UIView alloc] initWithFrame:lineRect];
    line.backgroundColor = [GLTheme tileColorDivider];
    return line;
}

- (UIView*) bottomLineView{
    CGRect lineRect = CGRectMake(15, [self buttonHeight] - LINE_HEIGHT, SCREEN_WIDTH - 15, LINE_HEIGHT);
    UIView* line = [[UIView alloc] initWithFrame:lineRect];
    line.backgroundColor = [GLTheme tileColorDivider];
    return line;
}

- (UIView*) bottomLineViewExtended{
    CGRect lineRect = CGRectMake(0, [self buttonHeight] - LINE_HEIGHT, SCREEN_WIDTH, LINE_HEIGHT);
    UIView* line = [[UIView alloc] initWithFrame:lineRect];
    line.backgroundColor = [GLTheme tileColorDivider];
    return line;
}

#pragma mark - Button Callbacks

- (void) copyUrl{
    if (AppState.userIsAuthenticated == NO){
        [self showOfflineAlert];
        return;
    }
    [AnalyticsHelper settingsCopyURL];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString* absUrl = AppState.gistUrl.absoluteString;
    pasteboard.string = absUrl;
    [DialogHelper showClipboardToast];
}

- (void) shareSMS{
    if (AppState.userIsAuthenticated == NO){
        [self showOfflineAlert];
        return;
    }
    [AnalyticsHelper settingsShareSMS];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText] && controller != nil) {
        NSString* url = AppState.gistUrl.absoluteString;
        controller.body = url;
        controller.recipients = [NSArray arrayWithObjects:@"", nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
        }];
    }
}

- (NSString*) emailSubject{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@'s TODO (%@)", AppState.username, dateString];
}

- (void) shareEmail{
    if (AppState.userIsAuthenticated == NO){
        [self showOfflineAlert];
        return;
    }
    [AnalyticsHelper settingsShareEmail];
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail] && mailComposer != nil) {
        mailComposer.mailComposeDelegate = self;
        NSString* url = AppState.gistUrl.absoluteString;
        NSString* subject = [self emailSubject];
        [mailComposer setMessageBody:[NSString stringWithFormat:@"<a>%@</a>", url] isHTML:YES];
        [mailComposer setSubject:subject];
        [self presentViewController:mailComposer animated:YES completion:^{
        }];
    }
}

- (void) viewOnGithub{
    if (AppState.userIsAuthenticated == NO){
        [self showOfflineAlert];
        return;
    }
    [AnalyticsHelper settingsViewOnGithub];
    [[UIApplication sharedApplication] openURL:AppState.gistUrl];
}

- (void) leaveReview{
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (void) promoteGistList{
    if (AppState.userIsAuthenticated == NO){
        [self showOfflineAlert];
        return;
    }
    if (AppState.userIsAuthenticated){
        if (AppState.sharedGist == NO){
            [[[[AppService createViralGist] withLoadingSpinner] withErrorAlert] subscribeNext:^(id x) {
                [AnalyticsHelper createViralGist];
                [DialogHelper showThankYouToast];
            }];
        }else{
            [DialogHelper showThankYouAgainToast];
        }
    }
}


- (void) showSignoutOutAlert{
    [[DialogHelper showLogoutConfirmationAlert] subscribeNext:^(NSNumber* buttonIndex) {
        if (buttonIndex.intValue == 1) {
            [self signOut];
        }
    }];
}

- (void) signOut{
    [[AppService signOut] subscribeNext:^(id x) {
        [AnalyticsHelper settingsSignOut];
        [self popToRootViewController];
    }];
    
}

- (void) dismiss{
    [self popViewController];
}

- (void) showOfflineAlert{
    [[DialogHelper showSyncRequiredAlert] subscribeNext:^(id x) {
        [AnalyticsHelper settingsFeatureUnavailable];
    }];
}

#pragma mark - ViewController Lifecycle

- (void) changeProfileImage:(UIImage*) image{
    _profileImage.image = image;
    [UIView animateWithDuration:0.5f animations:^{
        _profileImage.alpha = 1.0f;
    }];
}

- (void) setup{ 
    
    // Locals
    const float padding = 15.0f;
    const float profileSize = 50.0f;
    
    // Background
    self.view.backgroundColor = [GLTheme backgroundColorSettings];
    
    // Close button
    _closeButton = [self.view addCloseButton];
    [[_closeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self dismiss];
    }];
    
    // Profile
    NSString* pictureUrl = AppState.userImageUrl;
    CGRect profileFrame = CGRectMake(padding, 55.0f, profileSize, profileSize);
    _profileImage = [[UIImageView alloc] initWithFrame:profileFrame];
    _profileImage.clipsToBounds = YES;
    _profileImage.layer.cornerRadius = profileFrame.size.width * 0.5f;
    _profileImage.alpha = 0.0f;
    _profileImage.backgroundColor = [GLTheme buttonColorGreen];
    if (GithubService.userIsAuthenticated){
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:pictureUrl]
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                 
                                                             }
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                if (image && !error){
                                                                    [self changeProfileImage:image];
                                                                }else{
                                                                    DDLogError(@"unable to cache thumbnail @ %@ \n %@", pictureUrl, error);
                                                                }
                                                            }];
        _profileImage.backgroundColor = [UIColor clearColor];
    }else{
        [self changeProfileImage:[GLTheme imageOfUserAvatar]];
    }
    [self.view addSubview:_profileImage];
    
    // Username
    float usernameX = padding * 2.0f + profileSize;
    float usernameWidth = 230.0f;
    _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(usernameX, 47.0f, usernameWidth , 26.0f)];
    _usernameLabel.text = AppState.username;
    _usernameLabel.font = [UIFont fontWithName:FONT size:20];
    _usernameLabel.textColor = [GLTheme textColorDefault];
    _usernameLabel.textAlignment = NSTextAlignmentLeft;
    _usernameLabel.backgroundColor = [UIColor clearColor];
    _usernameLabel.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_usernameLabel];
    
    // Stars
    float starLineY = 45.0f + 25.0f + STATUS_BAR_SIZE;
    CGRect starIconFrame = CGRectMake(usernameX, starLineY, 16, 18);
    _starIcon = [[UIImageView alloc] initWithFrame:starIconFrame];
    _starIcon.image = [GLTheme imageOfSettingIconCompleted];
    [self.view addSubview:_starIcon];
    
    // Star text
    float starTextX = usernameX + 12 + padding;
    CGRect starTextFrame = CGRectMake(starTextX, starLineY, 200.0f, 18);
    _starText = [[UILabel alloc] initWithFrame:starTextFrame];
    _starText.text = [NSString stringWithFormat:@"%i tasks completed", (int)AppState.completedTasks];
    _starText.font = [UIFont fontWithName:FONT size:15];
    _starText.textColor = [GLTheme textColorDefault];
    _starText.textAlignment = NSTextAlignmentLeft;
    _starText.backgroundColor = [UIColor clearColor];
    _starText.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_starText];

    // Version label
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    CGRect versionFrame = CGRectMake(0, SCREEN_WIDTH - 13, SCREEN_WIDTH, 12);
    _versionLabel = [[UILabel alloc] initWithFrame:versionFrame];
    _versionLabel.text = [NSString stringWithFormat:@"v %@", version];
    _versionLabel.font = [UIFont fontWithName:FONT size:8];
    _versionLabel.textColor = [GLTheme textColorDefault];
    _versionLabel.alpha = 0.25f;
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    _versionLabel.backgroundColor = [UIColor clearColor];
    _versionLabel.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_versionLabel];
    
    // Divider
    [self.view addSubview:[self lineView]];
    
    // Add buttons
    _buttons = [NSMutableArray array];
    BOOL offline = ![GithubService userIsAuthenticated];
    [[self addButtonWithTitle:@"View on GitHub" isLast:NO isGray:offline] subscribeNext:^(id x) {
        [self viewOnGithub];
    }];
    [[self addButtonWithTitle:@"Share - Copy URL" isLast:NO isGray:offline] subscribeNext:^(id x) {
        [self copyUrl];
    }];
    [[self addButtonWithTitle:@"Share - SMS" isLast:NO isGray:offline] subscribeNext:^(id x) {
        [self shareSMS];
    }];
    [[self addButtonWithTitle:@"Share - Email" isLast:NO isGray:offline] subscribeNext:^(id x) {
        [self shareEmail];
    }];
    [[self addButtonWithTitle:@"Promote on GitHub" isLast:NO isGray:offline] subscribeNext:^(id x) {
        [self promoteGistList];
    }];
    [[self addButtonWithTitle:@"Leave a Review" isLast:NO isGray:NO] subscribeNext:^(id x) {
        [self leaveReview];
    }];
    if (offline){
        [[self addButtonWithTitle:@"Sync with GitHub" isLast:YES isGray:NO] subscribeNext:^(id x) {
            [self signOut];
        }];
    }else{
        [[self addButtonWithTitle:@"Sign Out" isLast:YES isGray:NO] subscribeNext:^(id x) {
            [self showSignoutOutAlert];
        }];
    }
}

- (float) buttonHeight{
    return SETTINGS_BUTTON_HEIGHT;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (RACSignal*) addButtonWithTitle:(NSString*) title isLast:(BOOL) isLast isGray:(BOOL) isGray{

    // Button & text
    NSInteger index = _buttons.count;
    float buttonHeight = [self buttonHeight];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, index * buttonHeight + 120, SCREEN_WIDTH, buttonHeight)];
    button.backgroundColor = UIColor.whiteColor;
    UIImage* downImage = [self imageWithColor:[GLTheme tileColorHighlight]];
    UIImage* upImage = [self imageWithColor:isGray ? [GLTheme tileColorInactive] : [GLTheme tileColorDefault]];
    [button setBackgroundImage:downImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:upImage forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:FONT size:15.0f];
    NSString* titleWithSpace = [NSString stringWithFormat:@" %@", title];
    for (NSNumber* state in @[@(UIControlStateNormal), @(UIControlStateSelected), @(UIControlStateHighlighted)]) {
        [button setTitle:titleWithSpace forState:state.integerValue];
        [button setTitleColor:[GLTheme textColorDefault] forState:state.integerValue];
    }
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    CGRect rect = button.titleLabel.frame;
    button.titleLabel.frame = CGRectMake(rect.origin.x + 10, rect.origin.y, rect.size.width - 10, rect.size.height);

    // Chevron
    UIImage* chevronIcon = [GLTheme imageOfSettingsIconArrow];
    float w = chevronIcon.size.width;
    float h = chevronIcon.size.height;
    CGRect imageFrame = CGRectMake(0, ([self buttonHeight] - h) * 0.5f, w, h);
    UIImageView* chevron = [[UIImageView alloc] initWithFrame:imageFrame];
    chevron.image = chevronIcon;
    [button addSubview:chevron];
    [chevron wta_rightAlignInSuperviewOffset:20];
    
    // Add line on bottom
    if (index == 0){
        UIView* top = [self topLineView];
        [button addSubview:top];
    }
    UIView* bottom = [self bottomLineView];
    if (index){
        bottom = [self bottomLineViewExtended];
    }
    [button addSubview:bottom];
    
    // Add and return click signal
    [_buttons addObject:button];
    [self.view addSubview:button];
    return [button rac_signalForControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}


@end
