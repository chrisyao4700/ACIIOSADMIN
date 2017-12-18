//
//  OrderFormRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"

@interface OrderFormRootViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,AppDataSocketDelegate,UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *contentTable;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
