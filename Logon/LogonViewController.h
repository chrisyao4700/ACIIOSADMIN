//
//  LogonViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/8/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "CurrentUserManager.h"

@interface LogonViewController : UIViewController<UITextFieldDelegate,CurrentUserDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *logonButton;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@end
