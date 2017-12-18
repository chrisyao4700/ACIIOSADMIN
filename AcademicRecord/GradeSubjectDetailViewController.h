//
//  GradeSubjectDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataSocketConnector.h"
#import "UIViewController+CYViewController.h"
#import "DataPickerViewController.h"

@interface GradeSubjectDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,DataPickerDelegate>
@property NSString * gradeSubjectID;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;


@end
