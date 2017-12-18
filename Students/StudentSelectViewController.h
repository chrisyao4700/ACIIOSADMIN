//
//  StudentSelectViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentSelectDelegate.h"
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
@interface StudentSelectViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate>
@property id<StudentSelectDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@property NSArray * ban_list;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
