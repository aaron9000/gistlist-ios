//
//  TaskCell.m
//  gistlist
//
//  Created by Aaron Geisler on 6/8/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import "TaskCell.h"
#import "Macros.h"
#import "Config.h"
#import "Extensions.h"
#import "GLTheme.h"

@implementation TaskCell

#pragma mark - Public

- (void) refreshWithData:(Task*) task withIndex:(int) index isEditMode:(BOOL) isEditMode isLastItem:(BOOL) isLastItem{
    const float indent = BUTTON_SIZE + (BUTTON_PADDING * 2);
    
    // Stop holding keyboard
    [_taskTextField resignFirstResponder];
    
    BOOL isComplete = task.completed;
    _taskLabel.text = task.taskDescription;
    _taskTextField.text = task.taskDescription;
    _toggleButton.tag = index;
    _taskTextField.tag = index;
    _taskLabel.hidden = isEditMode;
    _taskTextField.hidden = !isEditMode;
    _topLine.frame = CGRectMake(0, 0, SCREEN_WIDTH, LINE_HEIGHT);
    _bottomLine.frame = CGRectMake(isLastItem ? 0 : indent, TASK_CELL_HEIGHT - LINE_HEIGHT, SCREEN_WIDTH, LINE_HEIGHT);
    _topLine.hidden = index != 0;
    _bottomLine.hidden = NO || (isEditMode && !isLastItem);
    _taskTextField.enabled = isEditMode;
    _taskTextField.alpha = task.completed ? 0.5f : 1.0f;
    _taskTextField.layer.borderWidth = 0.5f;
    _taskTextField.layer.borderColor = [[GLTheme tileColorDivider] CGColor];
    _taskTextField.backgroundColor = UIColor.clearColor;
    _taskTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    if (isComplete){
        _toggleButton.tintColor = UIColor.whiteColor;
        _toggleButton.roundBackgroundColor = isEditMode ? [GLTheme buttonColorRed] : [GLTheme buttonColorGreen];
        _toggleButton.currentButtonType = isEditMode ? buttonMinusType : buttonOkType;;
        _toggleButton.alpha = isEditMode ? 0.5f : 1.0f;
    }else{
        _toggleButton.tintColor = UIColor.whiteColor;
        _toggleButton.roundBackgroundColor = isEditMode ? [GLTheme buttonColorRed] : [GLTheme buttonColorGray];
        _toggleButton.currentButtonType = isEditMode ? buttonMinusType : buttonSquareType;
        _toggleButton.alpha = 1.0f;
    }
    
    self.contentView.tag = index;
}

- (void) resetAnimation{
    [self.contentView.layer removeAllAnimations];
}

- (void) dismissKeyboard{
    [_taskTextField resignFirstResponder];
}

#pragma mark - Helpers

- (CGRect) lineRectForRect:(CGRect) rect{
    return CGRectMake(0, rect.origin.y + (rect.size.height - LINE_HEIGHT), SCREEN_WIDTH, LINE_HEIGHT);
}

- (UIView*) lineForBottomOfView:(UIView*) view{
    CGRect lineRect = [self lineRectForRect:view.frame];
    UIView* line = [[UIView alloc] initWithFrame:lineRect];
    line.backgroundColor = [GLTheme tileColorDivider];
    return line;
}

#pragma mark - Setup

- (void) setup{
    const float verticalPadding = 10.0f;
    UIFont* font = [UIFont fontWithName:FONT size:15.0f];
    
    // Background
    self.backgroundColor = [GLTheme backgroundColorDefault];
    
    // Add line
    _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _topLine.backgroundColor = [GLTheme tileColorDivider];
    [self.contentView addSubview:_topLine];
    
    _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _bottomLine.backgroundColor = [GLTheme tileColorDivider];
    [self.contentView addSubview:_bottomLine];
    
    // Add label
    CGRect descriptionFrame = CGRectMake((BUTTON_PADDING * 2) + BUTTON_SIZE,
                                         verticalPadding,
                                         SCREEN_WIDTH - (TASK_CELL_HEIGHT + BUTTON_PADDING + 3),
                                         TASK_CELL_HEIGHT - (verticalPadding * 2));
    _taskLabel = [[UILabel alloc] initWithFrame:descriptionFrame];
    _taskLabel.text = @"text";
    _taskLabel.font = font;
    _taskLabel.contentMode = UIViewContentModeCenter;
    _taskLabel.textColor = [GLTheme textColorDefault];
    _taskLabel.backgroundColor = [UIColor clearColor];
    _taskLabel.clipsToBounds = YES;
    _taskLabel.layer.cornerRadius = _taskLabel.frame.size.height * 0.25f;
    [self.contentView addSubview:_taskLabel];
    
    // Add TextField
    descriptionFrame = CGRectOffset(descriptionFrame, 0, 1);
    _taskTextField = [[UITextField alloc] initWithFrame:descriptionFrame];
    _taskTextField.font = font;
    _taskTextField.contentMode = UIViewContentModeCenter;
    _taskTextField.textColor = [GLTheme textColorDefault];
    _taskTextField.backgroundColor = [UIColor clearColor];
    _taskTextField.text = @"description";
    _taskTextField.backgroundColor = [GLTheme backgroundColorEditText];
    _taskTextField.clipsToBounds = YES;
    _taskTextField.layer.cornerRadius = CORNER_RADIUS;
    _taskTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _taskTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    _taskTextField.keyboardType = UIKeyboardTypeDefault;
    _taskTextField.returnKeyType = UIReturnKeyDone;
    [self.contentView addSubview:_taskTextField];
    
    // Add button
    CGRect toggleRect = CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE);
    _toggleButton = [[VBFPopFlatButton alloc] initWithFrame:toggleRect buttonType:buttonOkType buttonStyle:buttonRoundedStyle animateToInitialState:YES];
    _toggleButton.lineThickness = BUTTON_LINE_THICKNESS;
    _toggleButton.roundBackgroundColor = [GLTheme buttonColorGreen];
    _toggleButton.tintColor = [GLTheme buttonColorGreen];
    [_toggleButton setHitTestEdgeInsets:BUTTON_HITTEST_INSET];
    [self.contentView addSubview:_toggleButton];
    [_toggleButton wta_leftAlignInSuperviewOffset:BUTTON_PADDING];
    [_toggleButton wta_centerAlignVerticallyInSuperview];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end
