//
//  OrderDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "OrderProductDetailViewController.h"
#import "OrderDiscountDetailViewController.h"
#import "OrderAddonDetailViewController.h"
#import "ParentSelectionViewController.h"
#import "OrderAddonRootViewController.h"
#import "OrderAddonDetailViewController.h"
#import "OrderDiscountRootViewController.h"
#import "OrderDiscountDetailViewController.h"
@import SquarePointOfSaleSDK;


@interface OrderDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,OrderDiscountDetailDelegate,OrderAddonDetailDelegate,OrderProductDetailDelegate,ParentSelectionDelegate,OrderAddonRootDelegate,OrderDiscountRootDelegate,OrderAddonDetailDelegate,OrderDiscountDetailDelegate>

@property NSString * orderID;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

-(void) refreshOrderDetail;
-(void) showErrorMessage:(NSString *) message;

@end
