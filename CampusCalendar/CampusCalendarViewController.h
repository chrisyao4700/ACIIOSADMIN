//
//  CampusCalendarViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
@import  FSCalendar;
#import "AppDataSocketConnector.h"
#import "UIViewController+CYViewController.h"

@interface CampusCalendarViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,FSCalendarDelegate,FSCalendarDataSource>
@property (strong, nonatomic) IBOutlet FSCalendar *calendarView;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@end
