//
//  SettingsViewController.h
//  gistlist
//
//  Created by Aaron Geisler on 3/19/14.
//  Copyright (c) 2014 Aaron Geisler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>{
    UIButton* _closeButton;
    UIImageView* _profileImage;
    UILabel* _usernameLabel;
    UIImageView* _starIcon;
    UILabel* _starText;
    UILabel* _versionLabel;
    NSMutableArray* _buttons;
}

@end
