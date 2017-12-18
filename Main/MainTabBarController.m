//
//  MainTabBarController.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "MainTabBarController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITabBarItem * calendarItem = [self.tabBar.items objectAtIndex:0];
    calendarItem.image = [[UIImage imageNamed:@"tab_calendar_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    calendarItem.selectedImage = [[UIImage imageNamed:@"tab_calendar_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    calendarItem.title = @"CALENDAR";
    
    UITabBarItem * orderItem = [self.tabBar.items objectAtIndex:1];
    orderItem.image = [[UIImage imageNamed:@"tab_order_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    orderItem.selectedImage = [[UIImage imageNamed:@"tab_order_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    orderItem.title = @"ORDERS";

    
    
    
    UITabBarItem * studentItem = [self.tabBar.items objectAtIndex:2];
    studentItem.image = [[UIImage imageNamed:@"tab_student_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    studentItem.selectedImage = [[UIImage imageNamed:@"tab_student_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    studentItem.title = @"STUDENT";

    UITabBarItem * courseItem = [self.tabBar.items objectAtIndex:3];
    courseItem.image = [[UIImage imageNamed:@"tab_course_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    courseItem.selectedImage = [[UIImage imageNamed:@"tab_course_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    courseItem.title = @"COURSE";
    
    UITabBarItem * profileItem = [self.tabBar.items objectAtIndex:4];
    profileItem.image = [[UIImage imageNamed:@"tab_profile_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profileItem.selectedImage = [[UIImage imageNamed:@"tab_profile_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profileItem.title = @"SETTING";

    
//    UITabBarItem * teacherItem = [self.tabBar.items objectAtIndex:1];
//    teacherItem.image = [[UIImage imageNamed:@"tab_teacher_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    teacherItem.selectedImage = [[UIImage imageNamed:@"tab_teacher_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    teacherItem.title = @"Staff";
//    
//    
//    
//    UITabBarItem * subjectItem = [self.tabBar.items objectAtIndex:2];
//    subjectItem.image = [[UIImage imageNamed:@"tab_subject_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    subjectItem.selectedImage = [[UIImage imageNamed:@"tab_subject_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    subjectItem.title = @"Subjects";
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
