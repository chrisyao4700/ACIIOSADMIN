//
//  OrderAddonDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "OrderAddonDetailDelegate.h"
@interface OrderAddonDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate>
@property NSString * addonID;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@property id<OrderAddonDetailDelegate> delegate;


@end
