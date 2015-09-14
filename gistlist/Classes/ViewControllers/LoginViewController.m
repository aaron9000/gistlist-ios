//
//  LoginViewController.m
//  gistlist
//
//  Created by Aaron Geisler on 8/23/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <CocoaLumberjack.h>
#import <OCTClient.h>
#import "LoginViewController.h"
#import "TasksViewController.h"
#import "Macros.h"
#import "Extensions.h"
#import "Config.h"
#import "Errors.h"
#import "AppService.h"
#import "Helpers.h"
#import "GLTheme.h"

@implementation LoginViewController

#pragma mark - Textfield Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _usernameTextField){
        [_passwordTextField becomeFirstResponder];
    }
    if (textField == _passwordTextField){
        [self attemptSignIn];
    }
    if (textField == _authTextField){
        [self attemptVerify];
    }    
    return YES;
}

#pragma mark - View Helpers

- (void) dismiss{
    [self popViewController];
}

- (void) dismissKeyboard{
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_authTextField resignFirstResponder];
}

- (void) translateOn:(UIView*) v{
    float offset = self.view.frame.size.width;
    CGRect start = v.frame;
    CGRect off = CGRectMake(start.origin.x + offset, start.origin.y, start.size.width, start.size.height);
    v.frame = off;
    v.hidden = NO;
    [UIView animateWithDuration:0.6f animations:^{
        v.frame = start;
    } completion:^(BOOL finished) {
        if (v == _authTextField){
            [_authTextField becomeFirstResponder];
        }
    }];
}

- (void) translateOff:(UIView*) v{
    float offset = self.view.frame.size.width;
    CGRect start = v.frame;
    CGRect off = CGRectMake(start.origin.x - offset, start.origin.y, start.size.width, start.size.height);
    v.hidden = NO;
    [UIView animateWithDuration:0.6f animations:^{
        v.frame = off;
    } completion:^(BOOL finished) {
        v.hidden = YES;
        v.frame = start;
    }];
}

#pragma mark - Actions

- (void) attemptVerify{
    [AnalyticsHelper loginVerify];
    [self attemptGitHubLogin];
}

- (void) attemptSignIn{
    [AnalyticsHelper loginSignIn];
    [self attemptGitHubLogin];
}

- (void) showLogin:(BOOL) showLogin{
    if (_showingLogin == showLogin){
        return;
    }
    [self dismissKeyboard];
    _showingLogin = showLogin;
    NSArray* leavingViews = showLogin ? [self authViews] : [self loginViews];
    NSArray* enteringViews = !showLogin ? [self authViews] : [self loginViews];
    for (UIView* v in leavingViews) {
        [self translateOff:v];
    }
    for (UIView* v in enteringViews) {
        [self translateOn:v];
    }
}

- (void) attemptGitHubLogin{
    NSString* u = _usernameTextField.text;
    NSString* p = _passwordTextField.text;
    NSString* a = _authTextField.text;
    a = [a isEqualToString:@""] ? nil : a;
    [[[AppService startSessionAndSyncWithUsername:u password:p auth:a] withLoadingSpinner] subscribeNext:^(id x) {
        [self dismiss];
    } error:^(NSError *error) {
        if (error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired){
            if (_showingLogin){
                [self showLogin:NO];
            }else{
                [AnalyticsHelper loginFailure];
                [[DialogHelper showAuthErrorAlert] subscribeNext:^(id x) {
                }];
            }
        }else{
            if (error.code == OCTClientErrorAuthenticationFailed){
                [[DialogHelper showCredentialsErrorAlert] subscribeNext:^(id x) {
                }];
            }else{
                [[DialogHelper showOKErrorAlert:error] subscribeNext:^(id x) {
                }];
            }
            [self showLogin:YES];
        }
    }];
}

#pragma mark - View Setup

- (NSArray*) loginViews{
    return @[_loginLogo, _usernameTextField, _usernameLabel, _joinButton, _passwordTextField, _passwordLabel, _signInButton];
}

- (NSArray*) authViews{
    return @[_authLogo, _authTextField, _authLabel, _verifyButton];
}

- (void) setupLogin{

    const float verticalPadding = [self verticalPadding];
    const float startY = 110.0f;
    
    _loginLogo = [self.view addLeftAlignedLogoWithImage:[GLTheme imageOfLoginHeaderSync] withY:55.0f];
    
    _usernameTextField = [self.view addTextFieldWithY:startY withShadowText:@""];
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    _usernameTextField.delegate = self;
    [self.view addSubview:_usernameTextField];
    
    _usernameLabel = [self.view addLabelForField:_usernameTextField withText:@"Username or Email:"];
    
    _passwordTextField = [self.view addTextFieldWithY:startY + verticalPadding withShadowText:@""];
    [_passwordTextField setSecureTextEntry:YES];
    _passwordTextField.returnKeyType = UIReturnKeyDone;
    _passwordTextField.delegate = self;
    [self.view addSubview:_passwordTextField];
    
    _passwordLabel = [self.view addLabelForField:_passwordTextField withText:@"Password:"];

    _signInButton = [self.view addButtonWithColor:[GLTheme buttonColorGreen]
                                    withText:@"Sign In"
                                           y:startY + (verticalPadding * 2.0f)
                                        image:[GLTheme imageOfLoginIconGithub]];
    [[_signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self attemptSignIn];
    }];
    
    _joinButton = [self.view addButtonWithText:@"Need an account?" y:self.view.frame.size.height - 80];
    [[_joinButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GITHUB_URL]];
    }];
}

- (void) setupAuth{
    
    const float startY = 110.0f;
    
    _authLogo = [self.view addLeftAlignedLogoWithImage:[GLTheme imageOfLoginHeaderTwoFactor] withY:55.0f];
    
    _authTextField = [self.view addTextFieldWithY:startY withShadowText:@""];
    _authTextField.autocorrectionType = UITextAutocapitalizationTypeNone;
    _authTextField.keyboardType = UIKeyboardTypeNumberPad;
    _authTextField.returnKeyType = UIReturnKeyDone;
    _authTextField.delegate = self;
    [self.view addSubview:_authTextField];
    
    _authLabel = [self.view addLabelForField:_authTextField withText:@"Authentication Code:"];
    
    _verifyButton = [self.view addButtonWithColor:[GLTheme buttonColorGreen]
                                    withText:@"Verify"
                                           y:startY + [self verticalPadding]
                                        image:[GLTheme imageOfLoginIconVerify]];
    [[_verifyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self attemptVerify];
    }];
    
    for (UIView* v in [self authViews]) {
        v.hidden = YES;
    }
    _showingLogin = YES;
}

- (void) setup{
    
    self.view.backgroundColor = [GLTheme backgroundColorDefault];
    _closeButton = [self.view addCloseButton];
    [[_closeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self dismiss];
    }];
    
    [self setupLogin];
    [self setupAuth];
    
    _tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
            action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:_tap];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

@end
