//
//  DialogHelper.h
//  gistlist
//
//  Created by Aaron Geisler on 4/11/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface DialogHelper : NSObject

// Toasts
+ (void) attemptShowRewardToast:(int) tasks;
+ (void) showThankYouToast;
+ (void) showThankYouAgainToast;
+ (void) showTaskCompletionToast:(NSInteger) stars;
+ (void) showClipboardToast;
+ (void) showSyncFailedToast;
+ (void) showClearsDailyToast;

// Alerts
+ (RACSignal*) showWelcomeAlert;
+ (RACSignal*) showLogoutConfirmationAlert;
+ (RACSignal*) showSyncRequiredAlert;
+ (RACSignal*) showLoginErrorAlert;
+ (RACSignal*) showAuthErrorAlert;
+ (RACSignal*) showCredentialsErrorAlert;
+ (RACSignal*) showOKErrorAlert:(NSError *)error;

@end
