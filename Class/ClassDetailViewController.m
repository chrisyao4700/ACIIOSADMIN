//
//  ClassDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ClassDetailViewController.h"
#import "StudentListDisplayViewController.h"
#import "StaffDetailViewController.h"
#import "SubjectDetailViewController.h"
@interface ClassDetailViewController ()

@end

@implementation ClassDetailViewController{
    AppDataSocketConnector * connector;
    
    NSDictionary * class_pack;
    NSData * data_container;
    
    NSString * key_pool;
    
    DateTimeSelectorViewController * dtvc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    [self setNavigationBarString:[NSString stringWithFormat:@"CLASS # %@",self.classID]];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestClassDetailData:self.classID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) requestClassDetailData:(NSString *) classID{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"class_id":self.classID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"class_detail" andCustomerTag:1];
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
            //[self requestStaffInfo];
            if (c_tag == 2) {
                [self requestClassDetailData:self.classID];
            }
            
            if (c_tag == 11) {
                //ACTIVE
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                    
                });
                
            }
        }];
        
        
    });
}
-(void) requestDeleteClass{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"class_id":self.classID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"delete_class" andCustomerTag:11];
    });
}

-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    [self showAlertWithTittle:@"ERROR" forMessage:message];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    
    if (c_tag == 1) {
        class_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        [self reloadContentTable];
    }
    if (c_tag == 11) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (class_pack) {
        return 6;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 2;
        //ID
    }
    if (section == 1) {
        temp = 2;
        //FROM && TO
    }
    if (section == 2) {
        temp = 1;
        //SUBJECT
        //DP
    }
    if (section == 3) {
        temp = 2;
        //TEACHER
        //DP
    }
    if (section == 4) {
        temp = 1;
        //STUDENT
    }
    if (section == 5){
        temp = 1;
        //DELETE
    }
    return temp;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    
    if (section == 0) {
        temp = @"CLASS";
    }
    if (section == 1) {
        //
        temp = @"BASIC INFO";
    }
    if (section == 2) {
        temp = @"SUBJECT";
    }
    if (section == 3) {
        temp = @"TEACHER";
    }
    if (section == 4) {
        temp = @"STUDENT";
    }
    if (section == 5) {
        temp = @" ";
    }
    return temp;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat temp = 65.0;
    
    return temp;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.userInteractionEnabled =YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    
    
    if (indexPath.section == 0) {
        //IDVE
        //cell.backgroundColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"ID # %@-%@ ",[class_pack objectForKey:@"course_id"],[class_pack objectForKey:@"id"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"CREATED AT-- %@",[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[class_pack objectForKey:@"cdate"]]]];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"CAMPUS";
            cell.detailTextLabel.text = [class_pack objectForKey:@"campus_name"];
        }
    }
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                key_pool = @"start_time";
                break;
            case 1:
                key_pool = @"end_time";
                break;
                
            default:
                break;
        }
        cell.textLabel.text = [key_pool.uppercaseString stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        cell.detailTextLabel.text = [class_pack objectForKey:key_pool];
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [class_pack objectForKey:@"subject_title"];
            cell.detailTextLabel.text = [class_pack objectForKey:@"subject_detail"];
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            //
            cell.textLabel.text = @"ASSIGN TEACHER";
            cell.detailTextLabel.text = @"";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"TEACHER ID # %@", [class_pack objectForKey:@"teacher_id"]];
            cell.detailTextLabel.text = [class_pack objectForKey:@"teacher_name"];
            data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png",[class_pack objectForKey:@"teacher_id"]]];
            if (data_container) {
                cell.imageView.image = [UIImage imageWithData:data_container];
            }
        }
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            //STUDENT
            cell.textLabel.text = @"VIEW STUDENTS";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            //DELETE
            cell.textLabel.text = @"DELETE";
            cell.detailTextLabel.text = @"";
            cell.backgroundColor = [UIColor redColor];
        }
    }
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 1:
                key_pool = @"start_time";
                break;
            case 2:
                key_pool = @"end_time";
                break;
                
            default:
                break;
        }
        [self performDateTimePickerForKey:key_pool forOrgDate:[CYFunctionSet convertStringToDate:[class_pack objectForKey:key_pool]]];
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //TO SUBJECT DETAIL
            [self performSegueWithIdentifier:@"classDetailToSubjectDetail" sender:self];
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            //ASSIGN TEACHER
            [self performSegueWithIdentifier:@"classDetailToTeacherRoot" sender:self];
        }
        if (indexPath.row == 1) {
            //TEACHER DETAIL
            [self performSegueWithIdentifier:@"classDetailToTeacherDetail" sender:self];
        }
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"classDetailToStudentList" sender:self];
        }
    }
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            [self requestDeleteClass];
        }
    }
}
-(void) performDateTimePickerForKey:(NSString *) key
                         forOrgDate:(NSDate *) orgDate{
    if (!dtvc) {
        dtvc = [[DateTimeSelectorViewController alloc] init];
    }
    dtvc.key = key;
    dtvc.org_date = orgDate;
    dtvc.delegate = self;
    dtvc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:dtvc animated:YES completion:nil];
}
-(void)datetimePickerDidCancelWithKey:(NSString *)key{
    [self reloadContentTable];
}
-(void)datetimePickerDidSaveWithKey:(NSString *)key andValue:(NSString *)selectedDate{
    [self requestUpdateRecordForTable:@"aci_class" forDataID:self.classID forKey:key forValue:selectedDate withTag:2];
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}
-(void)teacherSelectionDidSelectTeacher:(NSString *)teacherID{
    [self requestUpdateRecordForTable:@"aci_class" forDataID:self.classID forKey:@"teacher_id" forValue:teacherID withTag:2];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"classDetailToSubjectDetail"]) {
        SubjectDetailViewController * sdvc = (SubjectDetailViewController *)[segue destinationViewController];
        sdvc.subjectID = [class_pack objectForKey:@"subject_id"];
    }
    if ([segue.identifier isEqualToString:@"classDetailToTeacherRoot"]) {
        TeacherRootViewController * trvc = (TeacherRootViewController *)[segue destinationViewController];
        trvc.delegate = self;
        trvc.mode = @"SELECT";
        
    }
    if ([segue.identifier isEqualToString:@"classDetailToTeacherDetail"]) {
        StaffDetailViewController * sdvc = (StaffDetailViewController *) [segue destinationViewController];
        sdvc.staffID = [class_pack objectForKey:@"teacher_id"];
    }
    if ([segue.identifier isEqualToString:@"classDetailToStudentList"]) {
        StudentListDisplayViewController * sldvc = (StudentListDisplayViewController *)[segue destinationViewController];
        sldvc.mode = @"CLASS";
        sldvc.data_id = self.classID;
        sldvc.course_id = [class_pack objectForKey:@"course_id"];
    }
    
}


@end
