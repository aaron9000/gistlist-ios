//
//  UIView+Controls.m
//  gistlist
//
//  Created by Aaron Geisler on 5/16/15.
//  Copyright (c) 2015 Aaron Geisler. All rights reserved.
//

#import "UIView+Controls.h"
#import "UIButton+Extensions.h"
#import "InterfaceConsts.h"
#import "GLTheme.h"
#import "Macros.h"

@implementation UIView (Controls)

- (UITextField*) addTextFieldWithWidth:(float) width withY:(float) y withShadowText:(NSString*) shadowText toView:(UIView*) parent{
    const int fontSize = 15;
    UITextField* taskInput = [[UITextField alloc] initWithFrame:CGRectMake(0, y, width, TEXTFIELD_HEIGHT)];
    taskInput.backgroundColor = [GLTheme backgroundColorDefault];
    taskInput.textColor = [GLTheme textColorDefault];
    taskInput.layer.borderWidth = LINE_HEIGHT;
    taskInput.layer.borderColor = [[GLTheme tileColorDivider] CGColor];
    taskInput.textAlignment = NSTextAlignmentCenter;
    taskInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
    taskInput.autocorrectionType = UITextAutocapitalizationTypeNone;
    taskInput.autocorrectionType = UITextAutocorrectionTypeYes;
    taskInput.keyboardType = UIKeyboardTypeDefault;
    taskInput.autocorrectionType = UITextAutocorrectionTypeNo;
    taskInput.returnKeyType = UIReturnKeyDefault;
    taskInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    taskInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    taskInput.layer.cornerRadius = CORNER_RADIUS;
    [[UITextField appearance] setTintColor:[GLTheme textColorDefault]];
    taskInput.font = [UIFont fontWithName:FONT size:fontSize];
    UIColor* placeholderColor = [GLTheme textColorPlaceholder];
    taskInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:shadowText
                                                                      attributes:@{NSForegroundColorAttributeName: placeholderColor,
                                                                                   NSFontAttributeName: taskInput.font}];
    [parent addSubview:taskInput];
    [taskInput wta_centerAlignHorizontallyInSuperview];
    return taskInput;
}

- (UITextField*) addTextFieldWithY:(float) y withShadowText:(NSString*) shadowText{
    float width = SCREEN_WIDTH - (2.0f * TEXTFIELD_HORIZONTAL_PADDING);
    return [self addTextFieldWithWidth:width withY:y withShadowText:shadowText toView:self];
}

- (UILabel*) addLabelForField:(UITextField*) textField withText:(NSString*) text{
    const float height = 24.0f;
    const int fontSize = 12;
    CGRect frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y - height, textField.frame.size.width, height);
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textColor = [GLTheme textColorLabel];
    label.font = [UIFont fontWithName:FONT size:fontSize];
    [self addSubview:label];
    return label;
}

- (UIImageView*) addLogoWithImage:(UIImage*) image withY:(float) y centered:(BOOL) centered{
    float x = centered ? (SCREEN_WIDTH - image.size.width) * 0.5f : TEXTFIELD_HORIZONTAL_PADDING;
    UIImageView* logo = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, image.size.width, image.size.height)];
    logo.image = image;
    [self addSubview:logo];
    return logo;
}

- (UIImageView*) addLeftAlignedLogoWithImage:(UIImage*) image withY:(float) y{
    return [self addLogoWithImage:image withY:y centered:NO];
}

- (UIImageView*) addCenteredLogoWithImage:(UIImage*) image withY:(float) y{
    return [self addLogoWithImage:image withY:y centered:YES];
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

- (UIButton*) addButtonWithText:(NSString*) text y:(float) y{
    const float padding = TEXTFIELD_HORIZONTAL_PADDING;
    const float buttonHeight = 50.0f;
    UIColor* color = [GLTheme textColorPlaceholder];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(padding, y, self.frame.size.width - (padding * 2), buttonHeight)];
    [button setTitle:text forState:UIControlStateNormal];
    button.layer.cornerRadius = buttonHeight * 0.5f;
    button.clipsToBounds = YES;
    button.backgroundColor = UIColor.clearColor;
    UIColor* a = UIColor.clearColor;
    [button setBackgroundImage:[self imageWithColor:a] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:a] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont fontWithName:FONT size:15.0f];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateHighlighted];
    [self addSubview:button];
    return button;
}

- (UIButton*) addButtonWithColor:(UIColor*) color withText:(NSString*) text y:(float) y image:(UIImage*) image{
    const float padding = 22.0f;
    const float buttonHeight = 50.0f;
    const float iconSize = 27.0f;
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(padding, y, self.frame.size.width - (padding * 2), buttonHeight)];
    [button setTitle:text forState:UIControlStateNormal];
    button.layer.cornerRadius = buttonHeight * 0.5f;
    button.clipsToBounds = YES;
    button.backgroundColor = UIColor.clearColor;
    UIColor* a = [color colorWithAlphaComponent:0.5f];
    [button setBackgroundImage:[self imageWithColor:color] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:a] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont fontWithName:FONT size:15.0f];
    UIImageView* iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
    iconImage.image = image;
    [button addSubview:iconImage];
    [self addSubview:button];
    [iconImage wta_centerAlignVerticallyInSuperview];
    [iconImage wta_leftAlignInSuperviewOffset:iconImage.frame.origin.y];
    return button;
}

- (VBFPopFlatButton*) addCloseButton{
    CGRect buttonRect = CGRectMake(self.frame.size.width - (BUTTON_PADDING + BUTTON_SIZE + 3),
                                   BUTTON_PADDING + STATUS_BAR_SIZE,
                                   BUTTON_SIZE,
                                   BUTTON_SIZE);
    VBFPopFlatButton* close = [[VBFPopFlatButton alloc] initWithFrame:buttonRect buttonType:buttonCloseType buttonStyle:buttonRoundedStyle animateToInitialState:YES];
    close.lineThickness = BUTTON_LINE_THICKNESS;
    [close setHitTestEdgeInsets:BUTTON_HITTEST_INSET];
    close.roundBackgroundColor = [GLTheme buttonColorGray];
    close.tintColor = UIColor.whiteColor;
    [self addSubview:close];
    
    return close;
}

@end
