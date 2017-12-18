//
//  StudentListDisplayViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentListActionViewController.h"
#import "StudentSelectViewController.h"
@interface StudentListDisplayViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,StudentListActionDelegate,StudentSelectDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@property NSString * mode;
@property NSString * data_id;
@property NSString * course_id;

@end
