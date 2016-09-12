#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import "BaseViewController.h"

@interface TasksViewController : BaseViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UICollectionViewDelegate>{
    
    // Interface
    UIView* _containerView;
    UIView* _blankView;
    UIView* _buttonContainerView;
    UIView* _entryContainerView;
    UITextField* _taskInput;
    UICollectionView* _collectionView;
    UITapGestureRecognizer* _tap;
    VBFPopFlatButton* _rightButton;
    UIImageView* _plusIcon;
    UIImageView* _headerIcon;
    VBFPopFlatButton* _leftButton;
    UIView* _headerLine;
    VBFPopFlatButton* _actionButton;
    
    // State
    BOOL _refreshOnAppear;
    BOOL _isEditMode;
    UITextField* _cellTextfieldBeingEdited;
}

@end
