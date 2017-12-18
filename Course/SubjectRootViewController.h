//
//  SubjectRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubjectRootSelectionDelegate.h"
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"

@interface SubjectRootViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,AppDataSocketDelegate,UISearchBarDelegate>

@property id<SubjectRootSelectionDelegate> delegate;
@property NSString * mode;
@property (strong, nonatomic) IBOutlet UICollectionView *contentTable;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
