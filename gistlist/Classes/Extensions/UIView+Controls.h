//
//  UIView+Controls.h
//  gistlist
//
//  Created by Aaron Geisler on 5/16/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import <WTAHelpers/UIView+WTAFrameHelpers.h>

@interface UIView (Controls)

- (UIButton*) addButtonWithText:(NSString*) text y:(float) y;
- (UIButton*) addButtonWithColor:(UIColor*) color withText:(NSString*) text y:(float) y image:(UIImage*) image;
- (VBFPopFlatButton*) addCloseButton;
- (UITextField*) addTextFieldWithWidth:(float) width withY:(float) y withShadowText:(NSString*) shadowText toView:(UIView*) parent;
- (UITextField*) addTextFieldWithY:(float) y withShadowText:(NSString*) shadowText;
- (UIImageView*) addLeftAlignedLogoWithImage:(UIImage*) image withY:(float) y;
- (UIImageView*) addCenteredLogoWithImage:(UIImage*) image withY:(float) y;
- (UILabel*) addLabelForField:(UITextField*) textField withText:(NSString*) text;

@end
