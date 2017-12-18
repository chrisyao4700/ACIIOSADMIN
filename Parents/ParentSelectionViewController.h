//
//  ParentSelectionViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentSelectionDelegate.h"
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
@interface ParentSelectionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,UISearchBarDelegate>

@property NSString * mode;
@property id<ParentSelectionDelegate> delegate;
@property NSArray * ban_list;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
