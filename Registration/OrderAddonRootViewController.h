//
//  OrderAddonRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataSocketConnector.h"
#import "UIViewController+CYViewController.h"
#import "OrderAddonRootDelegate.h"

@interface OrderAddonRootViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,AppDataSocketDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *contentTable;
@property id<OrderAddonRootDelegate> delegate;

@property NSString * order_id;

@property NSString * mode;
@end
