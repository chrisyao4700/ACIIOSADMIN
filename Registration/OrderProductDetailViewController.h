//
//  OrderProductDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "OrderProductDetailDelegate.h"
#import "AppDataSocketConnector.h"
#import "StudentSelectViewController.h"
#import "CourseRootViewController.h"
@interface OrderProductDetailViewController : UIViewController<AppDataSocketDelegate,UITableViewDataSource,UITableViewDelegate,StudentSelectDelegate,CourseRootSelectionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@property NSString * productID;
@property id<OrderProductDetailDelegate> delegate;

@end
