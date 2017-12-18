//
//  ClassRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataSocketConnector.h"
#import "UIViewController+CYViewController.h"
#import "TeacherRootViewController.h"
@interface ClassRootViewController : UIViewController<AppDataSocketDelegate,UITableViewDelegate,UITableViewDataSource,TeacherSelectionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;


@property NSString * courseID;


@end
