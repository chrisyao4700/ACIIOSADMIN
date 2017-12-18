//
//  OrderDiscountDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "OrderDiscountDetailDelegate.h"
@interface OrderDiscountDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@property id<OrderDiscountDetailDelegate> delegate;
@property NSString * discountID;
@end
