//
//  ClassDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "TeacherRootViewController.h"
#import "DateTimeSelectorViewController.h"
@interface ClassDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,TeacherSelectionDelegate,DateTimeSelectorDelegate>

@property NSString * classID;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@end
