//
//  CourseDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "CourseDetailDPTableViewCell.h"
#import "SubjectDetailViewController.h"
#import "WeekItemDetailViewController.h"
#import "ClassRootViewController.h"
#import "StaffDetailViewController.h"
#import "StudentListDisplayViewController.h"
@interface CourseDetailViewController ()

@end

@implementation CourseDetailViewController{
    AppDataSocketConnector * connector;
    
    UIBarButtonItem * rightItem;
    
    NSDictionary * course_pack;
    
    NSDictionary * subject_pack;
    
    ACI_CURRENT_USER * user;
    
    DatePickerViewController * dtvc;
    
    UIAlertController * text_alert;
    
    NSArray * weekItem_list;
    NSDictionary * weekItem_pool;
    
    NSNumber * num_pool;
    
    NSDictionary * teacher_pack;
    
    NSData * data_container;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    [self configLoadingView];
    user = [CurrentUserManager getCurrentDispatch];
    [self setNavigationBarString:[NSString stringWithFormat:@"COURSE # %@",self.courseID]];
    
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self configBackgroundView];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestCourseDetailDataWithTag:1];
    [self requestClassPatternList];
}
-(IBAction)rightItemDidClick:(id)sender{
    if ([course_pack objectForKey:@"subject_id"]) {
        [self requestUpdateRecordForTable:@"aci_course" forDataID:self.courseID forKey:@"course_status_id" forValue:@"2" withTag:11];
    }else{
        [self showAlertWithTittle:@"ERROR" forMessage:@"PLEASE SELECT SUBJECT FIRST"];
    }
}

-(void) requestCourseDetailDataWithTag:(NSInteger) c_tag{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query= [NSString stringWithFormat:@"SELECT `aci_course`.*, `aci_campus`.`campus_name`, `aci_contact`.`first_name`, `aci_contact`.`last_name` FROM `aci_course` LEFT JOIN `aci_campus` ON `aci_campus`.`id` = `aci_course`.`campus_id` LEFT JOIN `aci_users` ON `aci_users`.`id` = `aci_course`.`cby` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` WHERE `aci_course`.`id` = %@", self.courseID];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:c_tag];
    });
}
-(void) requestSubjectDetailDataWithID:(NSString *) subjectID
                                forTag:(NSInteger )c_tag{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_subject`.*, `aci_student_category`.`student_category` AS `student_category_str`, `aci_subject_status`.`subject_status` AS `subject_status_str` FROM `aci_subject` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_subject`.`student_category_id` LEFT JOIN `aci_subject_status` ON `aci_subject_status`.`id` = `aci_subject`.`subject_status_id` WHERE `aci_subject`.`id` = %@",subjectID];
        
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:c_tag];
    });
}
-(void) requestAddClassPattern{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"table_name":@"aci_course_item",
                                @"element_array":@[
                                        @{
                                            @"key":@"course_id",
                                            @"value":self.courseID
                                            },
                                        @{
                                            @"key":@"cby",
                                            @"value":user.data_id
                                            },
                                        @{
                                            @"key":@"cdate",
                                            @"value":[CYFunctionSet convertDateToString:[NSDate date]]
                                            }
                                        ]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:8];
    });
}

-(void) requestClassPatternList{
    dispatch_async(dispatch_get_main_queue(), ^{
        weekItem_list = nil;
        NSDictionary * dict = @{
                                @"table_name":@"aci_course_item",
                                @"condition":[NSString stringWithFormat:@" `course_id` = %@ AND `status` = 1", self.courseID],
                                @"result_order": @"`id` ASC"
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:9];
    });
}
-(void) requestUpdateRecordForTable:(NSString *) table_name
                          forDataID:(NSString *) data_id
                             forKey:(NSString *) key
                           forValue:(NSString *) value
                            withTag:(NSInteger) c_tag{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        NSArray * elements = @[
                               @{
                                   @"key" : key,
                                   @"value": value
                                   }
                               ];
        NSDictionary * dict = @{
                                @"table_name":table_name,
                                @"data_id":data_id,
                                @"element_array":elements
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"update_record" andCustomerTag:c_tag andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            if (c_tag == 2) {
                //NORMAL UPDATE
                [self requestCourseDetailDataWithTag:1];
            }
            if (c_tag == 3) {
                //SELECTED SUBJECT
                //[self requestCourseDetailDataWithTag:5];
            }
            
            if (c_tag == 5) {
                [self requestCourseDetailDataWithTag:6];
            }
            
            
            if (c_tag == 11) {
                //ACTIVE && DELETE
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    });
}
-(void) requestTeacherDataWithTeacherID:(NSString *) teacherID forTag:(NSInteger) c_tag{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector =[[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        teacher_pack = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_users`.`id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_user_category`.`user_category` AS `category_str`, `aci_user_status`.`user_status` AS `status_str` FROM `aci_users` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` LEFT JOIN `aci_user_category` ON `aci_user_category`.`id` = `aci_users`.`user_category_id` LEFT JOIN `aci_user_status` ON `aci_user_status`.`id` = `aci_users`.`user_status_id` WHERE `aci_users`.`id` = %@",teacherID];
        NSDictionary * dict = @{
                                @"query" : query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:c_tag];
    });
    
}
-(void) requestAssignTeacherWithTeacherID:(NSString *) teacherID forTag:(NSInteger) c_tag{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"course_id": self.courseID,
                                @"teacher_id": teacherID
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"assign_course_teacher" andCustomerTag:c_tag];
    });
    
    
}
-(void) requestDeleteCourse{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"course_id":self.courseID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"delete_course" andCustomerTag:11];
    });
}

-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if(c_tag == 1){
        course_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        if ((![course_pack objectForKey:@"subject_id"] || [[course_pack objectForKey:@"subject_id"] isEqualToString:@""]) && (![course_pack objectForKey:@"teacher_id"] || [[course_pack objectForKey:@"teacher_id"] isEqualToString:@""])) {
            [self reloadContentTable];
        }else{
            if ([course_pack objectForKey:@"subject_id"] && ![[course_pack objectForKey:@"subject_id"] isEqualToString:@""]) {
                [self requestSubjectDetailDataWithID:[course_pack objectForKey:@"subject_id"] forTag:4];
            }
            if ([course_pack objectForKey:@"teacher_id"] && ![[course_pack objectForKey:@"teacher_id"] isEqualToString:@""]) {
                [self requestTeacherDataWithTeacherID:[course_pack objectForKey:@"teacher_id"] forTag:10];
            }
            
        }
    }
    if (c_tag == 2) {
        //NORMAL UPDATE
        [self requestCourseDetailDataWithTag:1];
    }
    
    //WON'T RUN
    if (c_tag == 3) {
        //SELECTED SUBJECT
        //[self requestCourseDetailDataWithTag:5];
    }
    //END WON'T RUN
    
    if (c_tag == 4) {
        subject_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        [self reloadContentTable];
    }
    
    //WON'T RUN
    if (c_tag == 5) {
        [self requestCourseDetailDataWithTag:6];
    }
    //END WON'T RUN
    
    if (c_tag == 6) {
        //UPDATED PRICE WILL WON'T REQUEST SUBJECT
        course_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        [self reloadContentTable];
    }
    
    if (c_tag == 7) {
        //JUST UPDATED SUBJECT
        subject_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        [self requestUpdateRecordForTable:@"aci_course" forDataID:self.courseID forKey:@"price" forValue:[subject_pack objectForKey:@"price"] withTag:5];
    }
    
    if (c_tag == 8) {
        //ADD COURSE ITEM
        weekItem_pool = [CYFunctionSet stripNulls: [resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"courseDetailToWeekItemDetail" sender:self];
        });
        
    }
    if (c_tag == 9) {
        weekItem_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 10) {
        teacher_pack = [resultDic objectForKey:@"record"];
        [self reloadContentTable];
    }
    
    //WON'T RUN
    if (c_tag == 11) {
        //ACTIVE && DELETE
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    //END WON'T RUN
    
    if (c_tag == 12) {
        //UPDATED TEACHER
        [self requestCourseDetailDataWithTag:13];
    }
    if (c_tag == 13) {
        //GET UPDATED COURSE PACK AND REQUEST TEACHER ONLY
        course_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        if ([course_pack objectForKey:@"teacher_id"] && ![[course_pack objectForKey:@"teacher_id"] isEqualToString:@""]) {
            [self requestTeacherDataWithTeacherID:[course_pack objectForKey:@"teacher_id"] forTag:10];
        }else{
            [self reloadContentTable];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (course_pack) {
        return 12;
    }else{
        return 0;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 2;
    }
    if (section == 1) {
        //BASIC
        temp = 3;
    }
    if (section == 2) {
        //NOTE
        temp = 1;
    }
    if (section == 3) {
        //SELECT SUBJECT
        temp = 1;
    }
    if (section == 4) {
        //SUBJECT DISPLAY
        if (subject_pack) {
            temp = 1;
        }
        
    }
    
    if (section == 5) {
        //ADD ITEM
        temp = 1;
    }
    if (section == 6) {
        //WEEK ITEM LIST
        if (weekItem_list) {
            temp = weekItem_list.count;
        }
    }
    
    if (section == 7) {
        temp = 1;
    }
    if (section == 8) {
        //TEACHER SELECT
        temp = 1;
    }
    if (section == 9) {
        //TEACHER DISPLAY
        if (teacher_pack) {
            temp = 1;
        }
        
    }
    if (section == 10) {
        //STUDENTS
        temp = 1;
    }
    if (section == 11) {
        //ACTIONS
        temp = 1;
    }
    
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    
    if (section == 0) {
        temp = @"BASIC INFO";
    }
    if (section == 3) {
        temp = @"SUBJECT";
    }
    if (section == 5) {
        temp = @"CLASS PARTTERN";
    }
    if (section == 7) {
        temp = @"CLASS";
    }
    
    if (section == 8) {
        
        temp = @"TEACHER";
    }
    if (section == 10) {
        temp = @"STUDENTS";
    }
    if (section == 11) {
        temp = @"ACTIONS";
    }
    return temp;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat temp = 65.0;
    if (indexPath.section == 2 || indexPath.section == 4 || indexPath.section == 9) {
        temp = 120;
    }
    return temp;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    
    if (indexPath.section == 2 || indexPath.section == 4 || indexPath.section == 9) {
        //DP CELL
        CourseDetailDPTableViewCell * dp_cell = (CourseDetailDPTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"dp_cell" forIndexPath:indexPath];
        dp_cell.backgroundColor = [UIColor clearColor];
        dp_cell.userInteractionEnabled = YES;
        
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                dp_cell.titleLabel.text = @"NOTE";
                dp_cell.dpView.text = [course_pack objectForKey:@"note"];
                dp_cell.dpImageView.image =[UIImage imageNamed:@"dp_note"];
            }
        }
        if (indexPath.section == 4) {
            if (indexPath.row == 0) {
                dp_cell.titleLabel.text = [NSString stringWithFormat:@"%@ -- %@",[subject_pack objectForKey:@"class_name"],[subject_pack objectForKey:@"class_number"]];
                dp_cell.dpView.text = [NSString stringWithFormat:@"%@\nDefault Price: $ %@\nCategory: %@",
                                       [subject_pack objectForKey:@"description"],[subject_pack objectForKey:@"price"], [subject_pack objectForKey:@"student_category_str"]];
                dp_cell.dpImageView.image = [UIImage imageNamed:@"dp_subject"];
                
            }
        }
        if (indexPath.section == 9) {
            if (indexPath.row == 0) {
                dp_cell.titleLabel.text = @"TEACHER INFO";
                dp_cell.dpView.text = [NSString stringWithFormat:@"%@ %@\nID # %@",[teacher_pack objectForKey:@"first_name"],[teacher_pack objectForKey:@"last_name"],[teacher_pack objectForKey:@"id"]];
                data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png",[teacher_pack objectForKey:@"id"]]];
                if (data_container) {
                    dp_cell.dpImageView.image = [UIImage imageWithData:data_container];
                }
            }
        }
        
        return dp_cell;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.section == 0) {
            //cell.backgroundColor = [UIColor lightGrayColor];
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (indexPath.row == 0) {
                //ID
                cell.textLabel.text = [NSString stringWithFormat:@"ID # %@", self.courseID];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Created by:%@ %@ -- %@",[course_pack objectForKey:@"first_name"], [course_pack objectForKey:@"last_name"], [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[course_pack objectForKey:@"cdate"]]]];
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = [NSString stringWithFormat:@"CAMPUS"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [course_pack objectForKey:@"campus_name"]];
            }
            
        }
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                //START
                cell.textLabel.text = @"START DATE";
                cell.detailTextLabel.text = [course_pack objectForKey:@"start_date"];
            }
            if (indexPath.row == 1) {
                //END
                cell.textLabel.text = @"END DATE";
                cell.detailTextLabel.text = [course_pack objectForKey:@"end_date"];
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"PRICE";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"$ %@",[course_pack objectForKey:@"price"]];
            }
            
        }
        if(indexPath.section == 3){
            //SELECT SUBJECT
            if (indexPath.row == 0) {
                cell.textLabel.text = @"SELECT SUBJECT";
                cell.detailTextLabel.text = @"";
            }
        }
        
        
        if (indexPath.section == 5) {
            //ADD PATTERN
            if (indexPath.row == 0) {
                cell.textLabel.text = @"ADD CLASS PATTERN";
                cell.detailTextLabel.text = @"";
            }
        }
        if (indexPath.section == 6) {
            weekItem_pool = [CYFunctionSet stripNulls: [weekItem_list objectAtIndex:indexPath.item]];
            num_pool = [CYFunctionSet convertStingToNumber:[weekItem_pool objectForKey:@"weekday"]];
            cell.textLabel.text = [CYFunctionSet getWeekdayStringWithNumber:num_pool.integerValue];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[CYFunctionSet convertDateToTimeString:[CYFunctionSet convertStringToDate:[weekItem_pool objectForKey:@"start_time"]]], [CYFunctionSet convertDateToTimeString:[CYFunctionSet convertStringToDate:[weekItem_pool objectForKey:@"end_time"]]]];
        }
        if (indexPath.section == 7) {
            cell.textLabel.text = @"VIEW CLASSES";
            cell.detailTextLabel.text = @"";
        }
        if (indexPath.section == 8) {
            cell.textLabel.text = @"ASSIGN TEACHER";
            cell.detailTextLabel.text = @"";
        }
        if (indexPath.section == 10) {
            cell.textLabel.text = @"VIEW STUDENTS";
            cell.detailTextLabel.text = @"";
        }
        
        if (indexPath.section == 11) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"DELETE";
                cell.detailTextLabel.text = @"";
                cell.backgroundColor =[UIColor redColor];
            }
        }
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //START
            [self performDatePickForKey:@"start_date" forOrgDate:[CYFunctionSet convertDateFromYearString:[course_pack objectForKey:@"start_date"]]];
        }
        if (indexPath.row == 1) {
            //END
            [self performDatePickForKey:@"end_date" forOrgDate:[CYFunctionSet convertDateFromYearString:[course_pack objectForKey:@"end_date"]]];
        }
        if (indexPath.row == 2) {
            //PRICE
            [self performAlertViewTextModifyWithKey:@"price" forValue:[course_pack objectForKey:@"price"] forTableName:@"aci_course" forDataID:self.courseID];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self performAlertViewTextModifyWithKey:@"note" forValue:[course_pack objectForKey:@"note"] forTableName:@"aci_course" forDataID:self.courseID];
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"courseDetailToSubjectRoot" sender:self];
        }
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"courseDetailToSubjectDetail" sender:self];
        }
    }
    if (indexPath.section == 5) {
        //ADD CLASS PATTERN
        if (indexPath.row == 0) {
            [self requestAddClassPattern];
            
        }
    }

    if(indexPath.section == 6){
        weekItem_pool = [CYFunctionSet stripNulls: [weekItem_list objectAtIndex:indexPath.row]];
        [self performSegueWithIdentifier:@"courseDetailToWeekItemDetail" sender:self];
    }
    if (indexPath.section == 7) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"courseDetailToClassRoot" sender:self];
        }
        
    }
    
    if (indexPath.section == 8) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"courseDetailToTeacherRoot" sender:self];
        }
        
    }
    if (indexPath.section == 9) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"courseDetailToTeacherDetail" sender:self];
        }
        
    }
    
    
    if (indexPath.section == 10) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"courseDetailToStudentList" sender:self];
        }
    }
    if (indexPath.section == 11) {
        if (indexPath.row == 0) {
            [self requestDeleteCourse];
        }
    }
    
}





-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }
    
}



#pragma mark DATE PICKER

-(void) performDatePickForKey:(NSString *) key
                   forOrgDate:(NSDate *) org_date{
    
    if (!dtvc) {
        dtvc = [[DatePickerViewController alloc] init];
    }
    dtvc.delegate = self;
    dtvc.key = key;
    dtvc.org_date = org_date;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showDetailViewController:dtvc sender:self];
    });
    
}
-(void)datePickerDidSaveDate:(NSDate *)aDate forKey:(NSString *)key{
    [self requestUpdateRecordForTable:@"aci_course" forDataID:self.courseID forKey:key forValue:[CYFunctionSet convertDateToConstantString:aDate] withTag:2];
}
-(void)datePickerDidClickCancel{
    [self reloadContentTable];
}

#pragma mark TEXT
-(void) performAlertViewTextModifyWithKey:(NSString *) key
                                 forValue:(NSString *) value
                             forTableName:(NSString *) table_name
                                forDataID:(NSString *) data_id{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        text_alert = [UIAlertController
                      alertControllerWithTitle:key
                      message:value
                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self reloadContentTable];
                                                             }];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             //[locationHandler updateGasPoint];
                                                             NSString * value = [[text_alert.textFields objectAtIndex:0] text];
                                                             [self didSaveTextForKey:key
                                                                            andValue:value
                                                                        forTableName: table_name
                                                                           forDataID: data_id];                                                         }];
        
        [text_alert addAction:okAction];
        [text_alert addAction:cancelAction];
        [text_alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            //textField.placeholder = @"New information here...";
            textField.text = value;
            
        }];
        [self presentViewController:text_alert animated:YES completion:nil];
    });
}
-(void) didSaveTextForKey:(NSString *) key
                 andValue:(NSString *) value
             forTableName:(NSString *) table_name
                forDataID:(NSString *) data_id{
    NSString * f_value = value;
    if ([key isEqualToString:@"password"]) {
        f_value = [CYFunctionSet md5:value];
    }
    [self requestUpdateRecordForTable:table_name forDataID:data_id forKey:key forValue:f_value withTag:2];
}

#pragma mark - Navigation
-(void)subjectSelectionDidPickSubject:(NSString *)subjectID{
    [self requestUpdateRecordForTable:@"aci_course" forDataID:self.courseID forKey:@"subject_id" forValue:subjectID withTag:3];
    [self requestSubjectDetailDataWithID:subjectID forTag:7];
}
-(void)teacherSelectionDidSelectTeacher:(NSString *)teacherID{
    [self requestAssignTeacherWithTeacherID:teacherID forTag:12];
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"courseDetailToSubjectRoot"]) {
        SubjectRootViewController * srvc = (SubjectRootViewController *)[segue destinationViewController];
        srvc.mode = @"SELECT";
        srvc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"courseDetailToSubjectDetail"]) {
        SubjectDetailViewController * sdvc = (SubjectDetailViewController *)[segue destinationViewController];
        sdvc.subjectID = [subject_pack objectForKey:@"id"];
    }
    if ([segue.identifier isEqualToString:@"courseDetailToWeekItemDetail"]) {
        WeekItemDetailViewController * widvc = (WeekItemDetailViewController *)[segue destinationViewController];
        widvc.courseItemID = [weekItem_pool objectForKey:@"id"];
    }
    if ([segue.identifier isEqualToString:@"courseDetailToClassRoot"]) {
        ClassRootViewController * crvc = (ClassRootViewController *)[segue destinationViewController];
        crvc.courseID = self.courseID;
    }
    if ([segue.identifier isEqualToString:@"courseDetailToTeacherRoot"]) {
        TeacherRootViewController * trvc = (TeacherRootViewController *)[segue destinationViewController];
        trvc.mode = @"SELECT";
        trvc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"courseDetailToTeacherDetail"]) {
        StaffDetailViewController * stdvc = (StaffDetailViewController *)[segue destinationViewController];
        stdvc.staffID = [teacher_pack objectForKey:@"id"];
    }
    if ([segue.identifier isEqualToString:@"courseDetailToStudentList"]) {
        StudentListDisplayViewController * sldvc = (StudentListDisplayViewController *)[segue destinationViewController];
        sldvc.data_id = self.courseID;
        sldvc.mode = @"COURSE";
    }
}


@end
