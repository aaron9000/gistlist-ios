//
//  DialogHelper.m
//  gistlist
//
//  Created by Aaron Geisler on 4/11/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import "DialogHelper.h"
#import <SVProgressHUD.h>
#import "Errors.h"
#import "InterfaceConsts.h"
#import "Extensions.h"

@implementation DialogHelper

#pragma mark - Toasts

+ (void) attemptShowRewardToast:(int) tasks{
    if (tasks <= 0){
        return;
    }
    [NSObject performBlock:^{
        [self showTaskCompletionToast:tasks];
    } afterDelay:0.3f];
}

+ (void) showThankYouToast{
    [SVProgressHUD showSuccessWithStatus:@"Thank you for supporting GistList!"];
}

+ (void) showThankYouAgainToast{
    [SVProgressHUD showSuccessWithStatus:@"Thank you for supporting GistList!"];
}

+ (void) showTaskCompletionToast:(NSInteger) stars{
    NSString* status = stars == 1 ? @"Completed 1 task" : [NSString stringWithFormat:@"Completed %i tasks", (int)stars];
    [SVProgressHUD showSuccessWithStatus:status];
}

+ (void) showClipboardToast{
    [SVProgressHUD showSuccessWithStatus:@"Copied to clipboard"];
}

+ (void) showSyncFailedToast{
    [SVProgressHUD showSuccessWithStatus:@"Sync Failed"];
}

+ (void) showClearsDailyToast{
    [SVProgressHUD showInfoWithStatus:@"Completed tasks are cleared daily."];
}

#pragma mark - Alerts

+ (RACSignal*) showWelcomeAlert{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Welcome to GistList!" message:@"" delegate:self cancelButtonTitle:@"Get Started" otherButtonTitles: nil];
    [alert show];
    return [alert rac_buttonClickedSignal];
}

+ (RACSignal*) showLogoutConfirmationAlert{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sign Out?" message:@"Are you sure you want to sign out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    return [alert rac_buttonClickedSignal];
}

+ (RACSignal*) showSyncRequiredAlert{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sync with GitHub to use this feature" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    return [alert rac_buttonClickedSignal];
}

+ (RACSignal*) showAuthErrorAlert{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Auth Error" message:@"Make sure your authorization code is correct." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    return [alert rac_buttonClickedSignal];
}

+ (RACSignal*) showCredentialsErrorAlert{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Make sure your credentials correct." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    return [alert rac_buttonClickedSignal];
}

+ (RACSignal*) showLoginErrorAlert{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sign In Error" message:@"Make sure your credentials are entered correctly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    return [alert rac_buttonClickedSignal];
}

+ (RACSignal *)showOKErrorAlert:(NSError *)error {
    NSString *message = [Errors errorMessage:error];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Something Went Wrong"
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    return [alert rac_buttonClickedSignal];
}

@end
