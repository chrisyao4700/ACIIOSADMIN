//
//  CourseRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataSocketConnector.h"
#import "UIViewController+CYViewController.h"
#import "CourseRootSelectionDelegate.h"
@interface CourseRootViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,AppDataSocketDelegate,UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *contentTable;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property id<CourseRootSelectionDelegate> delegate;
@property NSString * mode;

@end
