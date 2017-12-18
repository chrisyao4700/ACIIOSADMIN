//
//  StudentListDisplayViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "StudentListDisplayViewController.h"
#import "StudentDetailViewController.h"
#import "CurrentUserManager.h"
@interface StudentListDisplayViewController ()

@end

@implementation StudentListDisplayViewController{
    
    NSString * student_id_pool;
    
    NSArray * relation_student_list;
    NSDictionary * relation_student_pool;
    
    NSData * data_container;
    
    ACI_CURRENT_USER * user;
    
    AppDataSocketConnector * connector;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    user = [CurrentUserManager getCurrentDispatch];
    [self configBackgroundView];
    [self setNavigationBarString:@"STUDENTS"];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.mode isEqualToString:@"COURSE"]) {
        [self requestSearchCourseStudentWithCourse:self.data_id];
    }
    if([self.mode isEqualToString:@"CLASS"]){
        [self requestSearchClassStudentWithClass:self.data_id];
    }
    if ([self.mode isEqualToString:@"PARENT"]) {
        [self requestSearchParentStudentWithParent:self.data_id];
        
    }
}

-(void) requestSearchCourseStudentWithCourse:(NSString *) courseID{
    dispatch_async(dispatch_get_main_queue(), ^{
        relation_student_list = nil;
        NSDictionary * dict = @{
                                @"course_id":courseID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_course_student" andCustomerTag:1];
    });
}

-(void) requestSearchClassStudentWithClass:(NSString *) classID{
    dispatch_async(dispatch_get_main_queue(), ^{
        relation_student_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_class_student`.*,`aci_student`.`contact_id`, `aci_contact`.`first_name`, `aci_contact`.`last_name` FROM `aci_class_student` LEFT JOIN `aci_student` ON `aci_student`.`id` = `aci_class_student`.`student_id` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_student`.`contact_id` WHERE `aci_class_student`.`class_id` = %@ AND `aci_class_student`.`status` = 1",classID];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    });
}
-(void) requestSearchParentStudentWithParent:(NSString *) parentID{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary * dict = @{
                                @"parent_id":parentID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_ps_parent" andCustomerTag:1];
    });
}

-(void) requestInsertCourseStudent:(NSString *) studentID
                         forCourse:(NSString *) courseID{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary * dict = @{
                                @"cby":user.data_id,
                                @"cdate":[CYFunctionSet convertDateToString:[NSDate date]],
                                @"course_id":courseID,
                                @"student_id":studentID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_course_student" andCustomerTag:2];
    });
}

-(void) requestInsertClassStudent:(NSString *) studentID
                         forClass:(NSString *) classID
                        forCourse:(NSString *) courseID{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary * dict = @{
                                @"table_name":@"aci_class_student",
                                @"element_array":@[
                                        @{
                                            @"key":@"cby",
                                            @"value":user.data_id
                                            },
                                        @{
                                            @"key":@"cdate",
                                            @"value":[CYFunctionSet convertDateToString:[NSDate date]]
                                            },
                                        @{
                                            @"key":@"course_id",
                                            @"value":courseID
                                            },
                                        @{
                                            @"key":@"class_id",
                                            @"value":classID
                                            },
                                        @{
                                            @"key":@"student_id",
                                            @"value":studentID
                                            },
                                        @{
                                            @"key":@"status",
                                            @"value":@"1"
                                            }
                                        
                                        ]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:2];
    });
}
-(void) requestInsertParentStudent:(NSString *) studentID
                         forParent:(NSString *) parentID{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary * dict = @{
                                @"parent_id":parentID,
                                @"student_id":studentID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_ps_relation" andCustomerTag:3];
    });

}
-(void) requestRemoveCourseStudent:(NSString *) studentID
                         forCourse:(NSString *) courseID{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary * dict = @{
                                @"course_id":courseID,
                                @"student_id":studentID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"remove_course_student" andCustomerTag:3];
    });
}
-(void) requestRemoveClassStudent:(NSString *) studentID
                         forClass:(NSString *) classID{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"UPDATE `aci_class_student` SET `status` = 0 WHERE `student_id` = %@ AND `class_id` = %@",studentID,classID];
        NSDictionary * dict = @{
                               @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_update" andCustomerTag:3];
    });
}
-(void) requestRemoveParentStudent:(NSString *) studentID
                         forParent:(NSString *)parentID{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"UPDATE `aci_parent_student` SET `status` = 0 WHERE `student_id` = %@ AND `parent_id` = %@",studentID,parentID];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_update" andCustomerTag:3];
    });

}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 1;
    }
    if (section == 1) {
        if (relation_student_list) {
            temp = relation_student_list.count;
        }
    }
    return temp;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell ;
    
    if (indexPath.section == 0) {
        //ADD
        cell = [tableView dequeueReusableCellWithIdentifier:@"action_cell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ADD STUDENT";
        }
    }
    if (indexPath.section == 1) {
        //NORMAL LIST ITEM
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        relation_student_pool = [CYFunctionSet stripNulls:[relation_student_list objectAtIndex:indexPath.row]];
        cell.textLabel.text = [NSString stringWithFormat:@"ID # %@", [relation_student_pool objectForKey:@"student_id"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[relation_student_pool objectForKey:@"first_name"], [relation_student_pool objectForKey:@"last_name"]];
        data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"student_%@.png", [relation_student_pool objectForKey:@"student_id"]]];
        if (data_container) {
            cell.imageView.image = [UIImage imageWithData:data_container];
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //ADD STUDENT
            [self performSegueWithIdentifier:@"studentListDisplayToStudentSelect" sender:self];
        }
    }
    if (indexPath.section == 1) {
        relation_student_pool = [CYFunctionSet stripNulls:[relation_student_list objectAtIndex:indexPath.row]];
        student_id_pool = [relation_student_pool objectForKey:@"student_id"];
        [self performSegueWithIdentifier:@"toAction" sender:self];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //CGFloat temp = 60;
    return 65;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    
    if (section == 0) {
        temp = @" ";
    }
    if (section == 1) {
        temp = @"CURRENT STUDENTS";
    }
    return temp;
}
-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}
-(void)studentListActionDidCancel{
    [self reloadContentTable];
}
-(void)studentListActionRequestDelete:(NSString *)studentID{
    //DO DELETE
    if ([self.mode isEqualToString:@"COURSE"]) {
        [self requestRemoveCourseStudent:studentID forCourse:self.data_id];
    }
    if ([self.mode isEqualToString:@"CLASS"]) {
        [self requestRemoveClassStudent:studentID forClass:self.data_id];
    }
    if ([self.mode isEqualToString:@"PARENT"]) {
        [self requestRemoveParentStudent:studentID forParent:self.data_id];
    }
}
-(void)studentListActionRequestDetail:(NSString *)studentID{
    student_id_pool = studentID;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"studentListDisplayToStudentDetail" sender:self];
    });
}

-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        [self showAlertWithTittle:@"ERROR" forMessage:message];
        
    }
    [self reloadContentTable];
    
}
-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        relation_student_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 2) {
        if ([self.mode isEqualToString:@"COURSE"]) {
            [self requestSearchCourseStudentWithCourse:self.data_id];
        }
        if ([self.mode isEqualToString:@"CLASS"]) {
            [self requestSearchClassStudentWithClass:self.data_id];
        }
        if ([self.mode isEqualToString:@"PARENT"]) {
            [self requestSearchParentStudentWithParent:self.data_id];
        }
    }
    if (c_tag == 3) {
        if ([self.mode isEqualToString:@"COURSE"]) {
            [self requestSearchCourseStudentWithCourse:self.data_id];
        }
        if ([self.mode isEqualToString:@"CLASS"]) {
            [self requestSearchClassStudentWithClass:self.data_id];
        }
        if ([self.mode isEqualToString:@"PARENT"]) {
            [self requestSearchParentStudentWithParent:self.data_id];
        }
    }
}
-(void)studentSelectionDidSelectStudent:(NSString *)studentID{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self performSegueWithIdentifier:@"studentListDisplayToStudentSelect" sender:self];
        if ([self.mode isEqualToString:@"COURSE"]) {
            [self requestInsertCourseStudent:studentID forCourse:self.data_id];
        }
        if ([self.mode isEqualToString:@"CLASS"]) {
            [self requestInsertClassStudent:studentID forClass:self.data_id forCourse:self.course_id];
        }
        if ([self.mode isEqualToString:@"PARENT"]) {
            [self requestInsertParentStudent:studentID forParent:self.data_id];
        }
    });
}
-(NSArray *) prepareBanlist{
    if (relation_student_list) {
        NSMutableArray * temp = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in relation_student_list) {
            [temp addObject:[dict objectForKey:@"student_id"]];
        }
        return (NSArray *) temp;
        
    }
    return nil;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"studentListDisplayToStudentDetail"]) {
        StudentDetailViewController * sdvc = (StudentDetailViewController *) [segue destinationViewController];
        sdvc.studentID = student_id_pool;
    }
    if ([segue.identifier isEqualToString:@"toAction"]) {
        StudentListActionViewController * slavc = (StudentListActionViewController *)[segue destinationViewController];
        slavc.studentID = student_id_pool;
        slavc.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"studentListDisplayToStudentSelect"]) {
        StudentSelectViewController * ssvc = (StudentSelectViewController *)[segue destinationViewController];
        ssvc.delegate = self;
        ssvc.ban_list = [self prepareBanlist];
    }
}


@end
