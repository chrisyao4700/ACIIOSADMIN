//
//  CourseDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "SubjectRootViewController.h"
#import "DatePickerViewController.h"
#import "TeacherRootViewController.h"
#import "SubjectRootViewController.h"

@interface CourseDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,SubjectRootSelectionDelegate,DatePickerDelegate,SubjectRootSelectionDelegate,TeacherSelectionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@property NSString * courseID;

@end
