//
//  ClassRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ClassRootViewController.h"
#import "CurrentUserManager.h"
#import "ClassDetailViewController.h"
@interface ClassRootViewController ()

@end

@implementation ClassRootViewController{
    AppDataSocketConnector * connector;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSArray * class_list;
    NSDictionary * class_pool;
    
    NSNumber * num_pool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    [self configBackgroundView];
    [self setNavigationBarString:@"CLASS"];
    
    user = [CurrentUserManager getCurrentDispatch];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view.
}
-(IBAction)rightItemDidClick:(id)sender{
    [self requestClassList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestClassList];
}

-(void) requestClassList{
    dispatch_async(dispatch_get_main_queue(), ^{
        class_list = nil;
        NSDictionary * dict = @{
                                @"table_name":@"aci_class",
                                @"condition": [NSString stringWithFormat:@" `course_id` = %@ AND `class_status_id` != 0 ",self.courseID],
                                @"result_order":[NSString stringWithFormat:@" `id` ASC"]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:1];
    
    });
}
-(void) requestCreateClassWithPattern{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"course_id":self.courseID,
                                @"cdate":[CYFunctionSet convertDateToString:[NSDate date]],
                                @"cby":user.data_id
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"pattern_class" andCustomerTag:2];
    });
}

-(void) requestCreateNewClass{
    dispatch_async(dispatch_get_main_queue(), ^{
        class_pool = nil;
        NSDictionary * dict = @{
                                @"table_name":@"aci_class",
                                @"element_array":@[
                                        @{
                                            @"key":@"course_id",
                                            @"value":self.courseID
                                            },
                                        @{
                                            @"key":@"cdate",
                                            @"value":[CYFunctionSet convertDateToString:[NSDate date]]
                                            },
                                        @{
                                            @"key":@"cby",
                                            @"value":user.data_id
                                            }
                                        ]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:3];
    });
}

-(void) requestAssignAllClassesToTeacher:(NSString *) teacherID{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"UPDATE `aci_class` SET `teacher_id` = %@ WHERE `course_id` = %@",teacherID,self.courseID];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_update" andCustomerTag:4];
    });

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
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        class_list =[resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 2) {
        [self requestClassList];
    }
    if (c_tag == 3) {
        class_pool = [CYFunctionSet stripNulls: [resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"classRootToClassDetail" sender:self];
        });
    }
    if (c_tag == 4) {
        [self showAlertWithTittle:@"SUCCESS" forMessage:@"TEACHER ASSIGNED"];
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
    return 65;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 2;
    }
    if (section == 1) {
        if (class_list) {
            temp = class_list.count;
        }
    }
    return temp;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    
    if (section == 0) {
        temp = @" ";
    }
    if (section == 1) {
        temp = @"CLASSES";
    }
    return temp;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"action_cell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ADD NEW CLASS";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"CREATE CLASSES WITH PATTERN";
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"ASSIGN TEACHER FOR ALL CLASSES";
        }
    }
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        
        class_pool = [CYFunctionSet stripNulls:[class_list objectAtIndex:indexPath.row]];
        
        cell.textLabel.text = [NSString stringWithFormat:@"ID # %@-%@",self.courseID, [class_pool objectForKey:@"id"]];
        //num_pool = [CYFunctionSet convertStingToNumber:[class_pool objectForKey:@"weekday"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %@",[CYFunctionSet convertDateToYearString:[CYFunctionSet convertStringToDate:[class_pool objectForKey:@"start_time"]]],[CYFunctionSet convertDateToTimeString:[CYFunctionSet convertStringToDate:[class_pool objectForKey:@"start_time"]]], [CYFunctionSet convertDateToTimeString:[CYFunctionSet convertStringToDate:[class_pool objectForKey:@"end_time"]]]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //ADD NEW
            [self requestCreateNewClass];
        }
        if (indexPath.row == 1) {
            //PATTERN CLASS
            [self requestCreateClassWithPattern];
        }
        if (indexPath.row == 2){
            //ASSIGN TEACHER
            [self performSegueWithIdentifier:@"classRootToTeacherRoot" sender:self];
        }
    }
    if (indexPath.section == 1) {
        class_pool = [CYFunctionSet stripNulls:[class_list objectAtIndex:indexPath.row]];
        [self performSegueWithIdentifier:@"classRootToClassDetail" sender:self];
    }
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}

-(void)teacherSelectionDidSelectTeacher:(NSString *)teacherID{
    [self requestAssignAllClassesToTeacher:teacherID];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"classRootToTeacherRoot"]) {
        TeacherRootViewController * trvc = (TeacherRootViewController *)[segue destinationViewController];
        trvc.mode = @"SELECT";
        trvc.delegate = self;
    
    }
    if ([segue.identifier isEqualToString:@"classRootToClassDetail"]) {
        ClassDetailViewController * cdvc = (ClassDetailViewController *)[segue destinationViewController];
        cdvc.classID = [class_pool objectForKey:@"id"];
    }
}


@end
