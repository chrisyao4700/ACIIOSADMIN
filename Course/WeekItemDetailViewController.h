//
//  WeekItemDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "DataPickerViewController.h"
#import "CYTimePickerViewController.h"
#import "WeekItemDetailDelegate.h"
@interface WeekItemDetailViewController : UIViewController<DataPickerDelegate,CYTimePickerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@property NSString * courseItemID;
@property id <WeekItemDetailDelegate> delegate;
@end
