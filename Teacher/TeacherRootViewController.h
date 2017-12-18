//
//  TeacherRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "TeacherSelectionDelegate.h"
@interface TeacherRootViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate>

@property NSString * mode;

@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property id<TeacherSelectionDelegate> delegate;

@end
