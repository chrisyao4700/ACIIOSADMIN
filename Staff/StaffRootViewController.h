//
//  StaffRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "CurrentUserManager.h"

@interface StaffRootViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,AppDataSocketDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *contentTable;

@end
