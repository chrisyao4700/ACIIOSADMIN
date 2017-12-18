//
//  GradeRecordDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "DataPickerViewController.h"
@interface GradeRecordDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,DataPickerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@property NSString * gradeRecordID;


@end
