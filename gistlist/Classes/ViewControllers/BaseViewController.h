//
//  BaseViewController.h
//  gistlist
//
//  Created by Aaron Geisler on 8/23/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import <WTAHelpers/UIView+WTAFrameHelpers.h>

typedef enum PhoneType {
    PhoneTypeIphone4 = 0,
    PhoneTypeIphone5 = 1,
    PhoneTypeIphone6 = 2,
    PhoneTypeIphone6P = 3
} PhoneType;

@interface BaseViewController : UIViewController

- (PhoneType) phoneType;
- (float) verticalPadding;
- (void) pushViewController:(BaseViewController*) viewController;
- (void) popViewController;
- (void) popToRootViewController;

@end
