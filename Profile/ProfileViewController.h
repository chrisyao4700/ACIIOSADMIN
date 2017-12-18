//
//  ProfileViewController.h
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentUserManager.h"
#import "UIViewController+CYViewController.h"

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,CurrentUserDelegate>
@property (strong, nonatomic) IBOutlet UITableView *profileTable;

@end
