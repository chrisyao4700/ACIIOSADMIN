//
//  GradeSubjectRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "GradeSubjectRootViewController.h"
#import "GradeSubjectDetailViewController.h"
@interface GradeSubjectRootViewController ()

@end

@implementation GradeSubjectRootViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    
    NSArray * subject_list;
    NSDictionary * subject_pool;
    
    NSIndexPath * indexPathPool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    //[self setNavigationBarString:@"STUDENT SUBJECT"];
    user = [CurrentUserManager getCurrentDispatch];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didClickRightItem:)];
    
    if ([self.mode isEqualToString:@"MANAGE"]) {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    // Do any additional setup after loading the view.
}
-(IBAction)didClickRightItem:(id)sender{
    [self performAlertViewTextModifyWithKey:@"GRADE SUBJECT" forValue:@"" forTableName:@"" forDataID:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestGradeSubjectList];
}
-(void) requestInsertGradeSubjectWithSubject:(NSString *) grade_subject{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //subject_list = nil;
        NSDictionary * dict = @{
                                @"table_name":@"aci_grade_subject",
                                @"element_array":@[
                                        @{
                                            @"key":@"status",
                                            @"value":@"0"
                                            },
                                        @{
                                            @"key":@"campus_id",
                                            @"value":user.main_campus_id
                                            },
                                        @{
                                            @"key":@"grade_subject",
                                            @"value":grade_subject
                                            }
                                        ]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:3];
        
    });
}
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
                                                             [self requestInsertGradeSubjectWithSubject:value];}];
        
        [text_alert addAction:okAction];
        [text_alert addAction:cancelAction];
        [text_alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            //textField.placeholder = @"New information here...";
            textField.text = value;
            
        }];
        [self presentViewController:text_alert animated:YES completion:nil];
    });
}
//-(void) didSaveTextForKey:(NSString *) key
//                 andValue:(NSString *) value
//             forTableName:(NSString *) table_name
//                forDataID:(NSString *) data_id{
//    NSString * f_value = value;
//    if ([key isEqualToString:@"password"]) {
//        f_value = [CYFunctionSet md5:value];
//    }
//    [self requestUpdateRecordForTable:table_name forDataID:data_id forKey:key forValue:f_value withTag:2];
//}


-(void) requestGradeSubjectList{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        subject_list = nil;
        
        NSString *query = [NSString stringWithFormat:@"SELECT `aci_grade_subject`.*, `aci_student_category`.`student_category` AS `student_category_str` FROM `aci_grade_subject` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_grade_subject`.`student_category_id` WHERE `aci_grade_subject`.`campus_id` = %@ AND `aci_grade_subject`.`status` != 0 ORDER BY `aci_grade_subject`.`student_category_id` ASC, `id` ASC ",user.main_campus_id];
        NSDictionary * dict = @{
                                @"query": query
                                };
                [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    
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
                [self requestGradeSubjectList];
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


//TABLE FUNCTIONS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return subject_list?1:0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return subject_list?subject_list.count:0;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * str = @"";
    
    
    return str;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    subject_pool = [CYFunctionSet stripNulls:[subject_list objectAtIndex:indexPath.row]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"SUBJECT# %@", [subject_pool objectForKey:@"id"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@",[subject_pool objectForKey:@"grade_subject"],[subject_pool objectForKey:@"student_category_str"]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    subject_pool = [CYFunctionSet stripNulls:[subject_list objectAtIndex:indexPath.row]];
    if ([self.mode isEqualToString:@"MANAGE"]) {
        indexPathPool = indexPath;
        [self performSegueWithIdentifier:@"toAction" sender:self];
    }
    if ([self.mode isEqualToString:@"SELECT"]) {
        [self.delegate gradeSubjectDidSelect:[subject_pool objectForKey:@"id"]];
        [self.navigationController popViewControllerAnimated:YES];
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
    [self reloadContentTable];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        subject_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 3) {
        subject_pool = [resultDic objectForKey:@"record"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"toDetail" sender:self];
        });
        //[self requestGradeSubjectList];
    }
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}
-(void) reloadContentTableWithIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    });
}
-(void)cyMultiActionRequestCancel:(NSIndexPath *)indexPath{
    [self reloadContentTable];
}
-(void)cyMultiActionRequestDelete:(NSIndexPath *)indexPath{
    
    subject_pool = [CYFunctionSet stripNulls:[subject_list objectAtIndex:indexPath.row]];
    [self confirmActionForTitle:@"WARNING" forMessage:[NSString stringWithFormat:@"DELETE %@ ?",[subject_pool objectForKey:@"grade_subject"]] forConfirmationHandler:^(UIAlertAction * action){
        [self requestUpdateRecordForTable:@"aci_grade_subject" forDataID:[subject_pool objectForKey:@"id"] forKey:@"status" forValue:@"0" withTag:2];
    }];
}
-(void) cyMultiActionRequestDetail:(NSIndexPath *)indexPath{
    subject_pool = [CYFunctionSet stripNulls:[subject_list objectAtIndex:indexPath.row]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"toDetail" sender:self];
    });
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"toAction"]) {
        CYMultiActionViewController * cmavc = (CYMultiActionViewController *)[segue destinationViewController];
        cmavc.indexPath = indexPathPool;
        cmavc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"toDetail"]) {
        GradeSubjectDetailViewController * gsdvc = (GradeSubjectDetailViewController *)[segue destinationViewController];
        gsdvc.gradeSubjectID = [subject_pool objectForKey:@"id"];
    }
}
@end
