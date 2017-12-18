//
//  CampusCalendarViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CampusCalendarViewController.h"
#import "ClassDetailViewController.h"

@interface CampusCalendarViewController ()

@end

@implementation CampusCalendarViewController{

    AppDataSocketConnector * connector;
    ACI_CURRENT_USER * user;
    
    NSData * data_container;
    
    
    NSArray * classCountArray;
    NSDictionary * class_count_dict;
    
    
    NSArray * class_list;
    NSDictionary * class_pool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    
    user = [CurrentUserManager getCurrentDispatch];
    [self configCalendarView];
    [self configBackgroundView];
    [self.calendarView setBackgroundColor:[UIColor clearColor]];
    
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) configCalendarView{
    self.calendarView.delegate = self;
    self.calendarView.dataSource = self;
    [self.calendarView selectDate:[NSDate date] scrollToDate:YES];
    
    self.calendarView.scope = FSCalendarScopeMonth;
    
    // For UITest
    self.calendarView.accessibilityIdentifier = @"calendar";

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestClassCountWithStartDate:self.calendarView.currentPage];
    [self requestClassDetailListOnDate:[CYFunctionSet convertDateToConstantString:self.calendarView.selectedDate]];
}
-(void) requestClassCountWithStartDate:(NSDate *) startDate{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDate * start_date = startDate;
        NSDate * end_date = [NSDate dateWithTimeInterval:60*60*24*31 sinceDate:start_date];
        
        NSDictionary * dict = @{
                                @"start_date" : [CYFunctionSet convertDateToConstantString:start_date],
                                @"end_date": [CYFunctionSet convertDateToConstantString:end_date],
                                @"campus_id": user.main_campus_id
                              };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"class_calendar_count" andCustomerTag:1];
        
    });
}
-(void) requestClassDetailListOnDate:(NSString *) date_str{
    dispatch_async(dispatch_get_main_queue(), ^{
        class_list = nil;
        NSDictionary * dict = @{
                                @"date":date_str,
                                @"campus_id":user.main_campus_id
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"class_calendar_detail" andCustomerTag:2];
    });
}

-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    if(![message isEqualToString:@"NO RESULT FOUND"]){
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }else{
        if (c_tag == 1) {
            [self reloadCanlendar];
        }
        if (c_tag == 2) {
            [self reloadContentTable];
        }
    }
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{

    if (c_tag == 1) {
        classCountArray = [resultDic objectForKey:@"records"];
        [self prepareForClassCountDict];
        [self reloadCanlendar];
    }
    if (c_tag == 2) {
        class_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }

}

-(void) prepareForClassCountDict{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    for (NSDictionary * dict in classCountArray) {
        NSDictionary * class_count_data = [CYFunctionSet stripNulls:dict];
        [temp setValue:[class_count_data objectForKey:@"class_count"] forKey:[class_count_data objectForKey:@"class_date"]];
    }
    class_count_dict = (NSDictionary *) temp;
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}
-(void) reloadCanlendar{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.calendarView reloadData];
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (class_list) {
        return class_list.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.imageView.image = nil;
    class_pool =[CYFunctionSet stripNulls:[class_list objectAtIndex:indexPath.row]];
    if ([class_pool objectForKey:@"teacher_id"] && ![[class_pool objectForKey:@"teacher_id"] isEqualToString:@""]) {
        cell.textLabel.text = [NSString stringWithFormat:@"Teacher ID # %@ - %@",[class_pool objectForKey:@"teacher_id"], [class_pool objectForKey:@"teacher_name"]];
    }else{
        cell.textLabel.text = @"TEACHER NOT ASSIGNED";
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[class_pool objectForKey:@"subject_title"]];
    
    data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png", [class_pool objectForKey:@"teacher_id"]]];
    if ([CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png", [class_pool objectForKey:@"teacher_id"]]]) {
        cell.imageView.image = [UIImage imageWithData:data_container];
    }
    
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    class_pool =[CYFunctionSet stripNulls:[class_list objectAtIndex:indexPath.row]];

    [self performSegueWithIdentifier:@"campusCalendarToClassDetail" sender:self];
}

-(void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    [self requestClassCountWithStartDate:calendar.currentPage];
}
-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    [self requestClassDetailListOnDate:[CYFunctionSet convertDateToConstantString:date]];
}

-(NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
    NSInteger temp = 0;
    if (class_count_dict) {
        NSString * key = [CYFunctionSet convertDateToConstantString:date];
        
        if ([class_count_dict.allKeys containsObject:key]) {
            NSString * count_str = [class_count_dict objectForKey:key];
            NSNumber * count_num = [CYFunctionSet convertStingToNumber:count_str];
            
            temp = count_num.integerValue;
        }
    }
    return temp;
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"campusCalendarToClassDetail"]) {
        ClassDetailViewController * cdvc = (ClassDetailViewController *)[segue destinationViewController];
        cdvc.classID = [class_pool objectForKey:@"id"];
    }
}


@end
