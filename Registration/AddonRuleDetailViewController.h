//
//  AddonRuleDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
@interface AddonRuleDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AppDataSocketDelegate>


@property NSString * addonRuleID;

@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@end
