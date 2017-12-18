//
//  SubjectDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "SubjectDetailViewController.h"

@interface SubjectDetailViewController ()

@end

@implementation SubjectDetailViewController{
    NSDictionary * subject_pack;
    
    NSArray * categoryArray;
    NSArray * statusArray;
    NSArray * category_list;
    NSArray * status_list;
    
    AppDataSocketConnector * connector;
    
    DataPickerViewController * dpvc;
    
    UIBarButtonItem * rightItem;
    
    NSString * key_pool;
    
    UIAlertController * text_alert;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self setNavigationBarString: [NSString stringWithFormat:@"Subject # %@",self.subjectID]];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightItemDidClick:)];
    [self configBackgroundView];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestSubjectDetailData];
}
-(IBAction)rightItemDidClick:(id)sender{
    //REFRESH
    //[self configViewData];
    [self requestUpdateRecordForTable:@"aci_subject" forDataID:self.subjectID forKey:@"subject_status_id" forValue:@"2" withTag:11];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark REQUEST
-(void) requestSubjectDetailData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_subject`.*, `aci_student_category`.`student_category` AS `student_category_str`, `aci_subject_status`.`subject_status` AS `subject_status_str` FROM `aci_subject` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_subject`.`student_category_id` LEFT JOIN `aci_subject_status` ON `aci_subject_status`.`id` = `aci_subject`.`subject_status_id` WHERE `aci_subject`.`id` = %@",self.subjectID];
        
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:1];
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
                [self requestSubjectDetailData];
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
        subject_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        [self reloadContentTable];
    }
    if (c_tag == 4) {
        categoryArray = [resultDic objectForKey:@"records"];
        [self prepareCategoryList];
    }
    if (c_tag == 5) {
        statusArray = [resultDic objectForKey:@"records"];
        [self prepareStatusList];
    }

}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}


#pragma mark TABLE
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    if (subject_pack) {
        return 4;
    }else{
        return 0;
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        //ID
        temp = 1;
    }
    if (section == 1) {
        //BASIC
        temp = 4;
    }
    if (section == 2) {
        //CATEGORY && STATUS
        temp = 2;
    }
    if (section == 3) {
        temp = 1;
    }
    
    return temp;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
        temp = @"SUBJECT INFO";
    }
    if (section == 3) {
        temp = @"ACTIONS";
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat temp = 65.0;
    return temp;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ID #";
            cell.detailTextLabel.text = [subject_pack objectForKey:@"id"];
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            //cell.backgroundColor = [UIColor lightGrayColor];
        }
    }
    if (indexPath.section == 1) {
        //BASIC
        switch (indexPath.row) {
            case 0:
                key_pool=@"class_name";
                break;
            case 1:
                key_pool=@"class_number";
                break;
            case 2:
                key_pool=@"description";
                break;
            case 3:
                key_pool=@"price";
                break;
                
            default:
                break;
        }//END SWITCH
        
        cell.textLabel.text = [key_pool.uppercaseString stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        cell.detailTextLabel.text = [subject_pack objectForKey:key_pool];
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //CATEGORY
            cell.textLabel.text = @"CATEGORY";
            cell.detailTextLabel.text = [subject_pack objectForKey:@"student_category_str"];
        }
        if (indexPath.row == 1) {
            //STATUS
            cell.textLabel.text = @"STATUS";
            cell.detailTextLabel.text = [subject_pack objectForKey:@"subject_status_str"];
        }
    }
    if (indexPath.section == 3) {
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
            case 0:
                key_pool=@"class_name";
                break;
            case 1:
                key_pool=@"class_number";
                break;
            case 2:
                key_pool=@"description";
                break;
            case 3:
                key_pool=@"price";
                break;
                
            default:
                break;
        }//END SWITCH
        
        [self performAlertViewTextModifyWithKey:key_pool forValue:[subject_pack objectForKey:key_pool] forTableName:@"aci_subject" forDataID:self.subjectID];
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            if (category_list) {
                NSNumber * num = [CYFunctionSet convertStingToNumber:[subject_pack objectForKey:@"student_category_id"]];
                [self performDataPickerForKey:@"student_category_id" forDatasource:category_list forOrgIndex:num.integerValue];
            }else{
                [self requestCategoryArray];
            }
        }
        if (indexPath.row == 1) {
            if (status_list) {
                NSNumber * num = [CYFunctionSet convertStingToNumber:[subject_pack objectForKey:@"subject_status_id"]];
                [self performDataPickerForKey:@"subject_status_id" forDatasource:status_list forOrgIndex:num.integerValue];
            }else{
                [self requestStatusArray];
            }
        }
       
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            //DELETE
            [self requestUpdateRecordForTable:@"aci_subject" forDataID:self.subjectID forKey:@"subject_status_id" forValue:@"0" withTag:11];
        }
    }

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
    [self requestUpdateRecordForTable:table_name forDataID:data_id forKey:key_pool forValue:f_value withTag:2];
}


#pragma mark CATEGORY

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

-(void) requestStatusArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        statusArray = nil;
        
        NSDictionary * dict = @{
                                @"table_name" : @"aci_subject_status",
                                @"result_order": @"`id` ASC"
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:5];
    });
}
-(void) prepareStatusList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in statusArray) {
        [temp addObject:[dict objectForKey:@"subject_status"]];
    }
    status_list = (NSArray *) temp;
    NSNumber * num = [CYFunctionSet convertStingToNumber:[subject_pack objectForKey:@"subject_status_id"]];
    [self performDataPickerForKey:@"subject_status_id" forDatasource:status_list forOrgIndex:num.integerValue];
}


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
    [self requestUpdateRecordForTable:@"aci_subject" forDataID:self.subjectID forKey:key forValue:[NSString stringWithFormat:@"%ld",(long)index] withTag:2];
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
