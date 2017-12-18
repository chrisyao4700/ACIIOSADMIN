//
//  ParentDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"

@interface ParentDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate>

@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@property NSString * parentID;
@end
