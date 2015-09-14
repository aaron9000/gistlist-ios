//
//  BaseViewController.m
//  gistlist
//
//  Created by Aaron Geisler on 8/23/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import "BaseViewController.h"
#import "Macros.h"
#import "GLTheme.h"
#import "Config.h"
#import "Extensions.h"

@implementation BaseViewController

- (PhoneType) phoneType{
    if (IS_IPHONE_4_OR_LESS){
        return PhoneTypeIphone4;
    }else{
        if (IS_IPHONE_5){
            return PhoneTypeIphone5;
        }else{
            return IS_IPHONE_6 ? PhoneTypeIphone6 : PhoneTypeIphone6P;
        }
    }
}

- (float) verticalPadding{
    switch ([self phoneType]) {
        case PhoneTypeIphone4:
            return 58.0f;
        case PhoneTypeIphone5:
            return 64.0f;
        case PhoneTypeIphone6:
            return 70.0f;
        case PhoneTypeIphone6P:
            return 76.0f;
    }
}

#define DURATION 0.5f
#define DELAY 0.25f

- (void) pushViewController:(BaseViewController*) viewController{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:DURATION];
    [self.navigationController pushViewController:viewController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (void) popToRootViewController{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:DURATION];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:DELAY];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [UIView commitAnimations];
}

- (void) popViewController{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:DURATION];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:DELAY];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
}

- (void) viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme backgroundColorDefault];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

@end
