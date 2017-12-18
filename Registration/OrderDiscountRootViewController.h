//
//  OrderDiscountRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "OrderDiscountRootDelegate.h"
@interface OrderDiscountRootViewController : UIViewController<AppDataSocketDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *contentTable;
@property id<OrderDiscountRootDelegate> delegate;


@property NSString * order_id;
@property NSString * mode;
@end
