//
//  ParentDisplayViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentActionViewController.h"
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "ParentSelectionViewController.h"
@interface ParentDisplayViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,ParentActionDelegate,AppDataSocketDelegate,ParentSelectionDelegate>

@property NSString * data_id;

@property NSString * mode;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@end
