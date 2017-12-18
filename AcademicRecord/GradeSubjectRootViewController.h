//
//  GradeSubjectRootViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "GradeSubjectSelectionDelegate.h"
#import "CYMultiActionViewController.h"
@interface GradeSubjectRootViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,CYMultiActionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@property id<GradeSubjectSelectionDelegate> delegate;
@property NSString * mode;

@end
