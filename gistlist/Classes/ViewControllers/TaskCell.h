//
//  TaskCell.h
//  gistlist
//
//  Created by Aaron Geisler on 6/8/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import <WTAHelpers/UIView+WTAFrameHelpers.h>
#import "Task.h"

@interface TaskCell : UICollectionViewCell

@property (nonatomic, strong) UILabel* taskLabel;
@property (nonatomic, strong) UIView* topLine;
@property (nonatomic, strong) UIView* bottomLine;
@property (nonatomic, strong) UITextField* taskTextField;
@property (nonatomic, strong) VBFPopFlatButton* toggleButton;

- (void) dismissKeyboard;
- (void) refreshWithData:(Task*) task withIndex:(int) index isEditMode:(BOOL) isEditMode isLastItem:(BOOL) isLastItem;

@end
