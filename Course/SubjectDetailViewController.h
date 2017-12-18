//
//  SubjectDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "DataPickerViewController.h"
#import "AppDataSocketConnector.h"
@interface SubjectDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DataPickerDelegate,AppDataSocketDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@property NSString * subjectID;

@end
