//
//  LoginViewController.h
//  gistlist
//
//  Created by Aaron Geisler on 8/23/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface LoginViewController : BaseViewController <UITextFieldDelegate>{
    UIButton* _closeButton;
    UIButton* _verifyButton;
    UIButton* _signInButton;
    UIButton* _joinButton;
    UITextField* _usernameTextField;
    UITextField* _passwordTextField;
    UITextField* _authTextField;
    UILabel* _usernameLabel;
    UILabel* _passwordLabel;
    UILabel* _authLabel;
    UIImageView* _authLogo;
    UIImageView* _loginLogo;
    UITapGestureRecognizer* _tap;
    BOOL _showingLogin;
}

@end
