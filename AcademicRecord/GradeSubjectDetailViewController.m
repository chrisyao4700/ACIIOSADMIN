//
//  GradeSubjectDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "GradeSubjectDetailViewController.h"

@interface GradeSubjectDetailViewController ()

@end

@implementation GradeSubjectDetailViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSDictionary * subject_pack;
    
    NSArray * category_list;
    NSArray * categoryArray;
    
    
    DataPickerViewController * dpvc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    user = [CurrentUserManager getCurrentDispatch];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didClickRightItem:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    // Do any additional setup after loading the view.
}
-(IBAction)didClickRightItem:(id)sender{
    [self requestUpdateRecordForTable:@"aci_grade_subject" forDataID:self.gradeSubjectID forKey:@"status" forValue:@"1" withTag:11];
    
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
                //[self requestClassDetailData:self.classID];
                [self requestGradeSubject:self.gradeSubjectID];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestGradeSubject:self.gradeSubjectID];
    
}

-(void) requestGradeSubject:(NSString *) gradeSubjectID{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *query = [NSString stringWithFormat:@"SELECT `aci_grade_subject`.*, `aci_student_category`.`student_category` AS `student_category_str` FROM `aci_grade_subject` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_grade_subject`.`student_category_id` WHERE `aci_grade_subject`.`id` = %@",self.gradeSubjectID];
        NSDictionary * dict = @{
                              @"query":query
                              };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:1];
    
    });
}
//TABLE FUNCTIONS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return subject_pack?3:0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 1;
        //ID
    }
    if (section == 1) {
        temp = 2;
        //CATEGORY && NAME
    }
    if (section == 2) {
        temp = 1;
    }
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * str = @"";
    if(section == 0){
        str= @"BASIC INFO";
    }
    if (section == 2) {
        str= @" ";
    }
    
    return str;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.userInteractionEnabled =YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            cell.textLabel.text = [NSString stringWithFormat:@"SUBJECT # %@",[subject_pack objectForKey:@"id"]];
            cell.detailTextLabel.text = @"";
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"GRADE SUBJECT"];
            cell.detailTextLabel.text = [subject_pack objectForKey:@"grade_subject"];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"STUDENT CATEGORY"];
            cell.detailTextLabel.text = [subject_pack objectForKey:@"student_category_str"];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0 ) {
            cell.textLabel.text = @"DELETE";
            cell.detailTextLabel.text = @"";
            cell.backgroundColor = [UIColor redColor];
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performAlertViewTextModifyWithKey:@"grade_subject" forValue:[subject_pack objectForKey:@"grade_subject"] forTableName:@"aci_grade_subject" forDataID:self.gradeSubjectID];
        }
        if(indexPath.row == 1){
            if (category_list) {
                NSNumber * num = [CYFunctionSet convertStingToNumber:[subject_pack objectForKey:@"student_category_id"]];
                [self performDataPickerForKey:@"student_category_id" forDatasource:category_list forOrgIndex:num.integerValue];
            }else{
                [self requestCategoryArray];
            }
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //DELETE
            [self confirmActionForTitle:@"WARNING" forMessage:[NSString stringWithFormat:@"DELETE SUBJECT #%@ -- %@",self.gradeSubjectID,[subject_pack objectForKey:@"grade_subject"]] forConfirmationHandler:^(UIAlertAction * action){
                [self requestUpdateRecordForTable:@"aci_grade_subject" forDataID:self.gradeSubjectID forKey:@"status" forValue:@"0" withTag:11];
            }];
        }
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
        subject_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        [self reloadContentTable];
    }
    if(c_tag == 4){
        categoryArray = [resultDic objectForKey:@"records"];
        [self prepareCategoryList];
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
-(void) requestCategoryArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        categoryArray = nil;
        
        NSDictionary * dict = @{
                                @"table_name" : @"aci_student_category",
                                @"result_order": @"`id` ASC"
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:4];
    });
}
-(void) prepareCategoryList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in categoryArray) {
        [temp addObject:[dict objectForKey:@"student_category"]];
    }
    category_list = (NSArray *) temp;
    NSNumber * num = [CYFunctionSet convertStingToNumber:[subject_pack objectForKey:@"student_category_id"]];
    [self performDataPickerForKey:@"student_category_id" forDatasource:category_list forOrgIndex:num.integerValue];
}

#pragma mark STATUS

-(void) performDataPickerForKey:(NSString *) key
                  forDatasource:(NSArray *)datasource
                    forOrgIndex:(NSInteger) orgIndex{
    
    if (!dpvc) {
        dpvc = [[DataPickerViewController alloc] init];
    }
    dpvc.key = key;
    dpvc.dataSource = datasource;
    dpvc.delegate = self;
    dpvc.orgIndex = orgIndex;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showDetailViewController:dpvc sender:self];
    });
    
    
}
-(void)didCancelPickingDataForKey:(NSString *)key{
    [self reloadContentTable];
}
-(void)didSavePickedDataForKey:(NSString *)key andIndex:(NSInteger)index{
    [self requestUpdateRecordForTable:@"aci_grade_subject" forDataID:self.gradeSubjectID forKey:key forValue:[NSString stringWithFormat:@"%ld",(long)index] withTag:2];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}
@end
