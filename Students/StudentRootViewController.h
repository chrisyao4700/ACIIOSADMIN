//
//  StudentRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataSocketConnector.h"
#import "UIViewController+CYViewController.h"
#import "CurrentUserManager.h"
@interface StudentRootViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,AppDataSocketDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UICollectionView *contentTable;

@end
