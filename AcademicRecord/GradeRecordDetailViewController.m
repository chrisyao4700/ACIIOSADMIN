//
//  GradeRecordDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "GradeRecordDetailViewController.h"

@interface GradeRecordDetailViewController ()

@end

@implementation GradeRecordDetailViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSDictionary * grade_pack;
    NSArray * detail_list;
    
    NSDictionary * detail_pool;
    
    DataPickerViewController * dpvc;
    
    NSArray * scoreArray;
    NSArray * score_list;
    NSArray * grade_list;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    user = [CurrentUserManager getCurrentDispatch];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didClickRightItem:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    // Do any additional setup after loading the view.
}
-(IBAction)didClickRightItem:(id)sender{
    [self requestGradeRecordDetail:self.gradeRecordID];
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
                [self requestGradeRecordDetail:self.gradeRecordID];
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
    [self requestGradeRecordDetail:self.gradeRecordID];
    
}
-(void) requestGradeRecordDetail:(NSString *) recordID{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"grade_record_id":recordID,
                                
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"grade_detail" andCustomerTag:1];
    });
}

//TABLE FUNCTIONS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return detail_list?detail_list.count + 2:0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 3;
    }
    if (section > 0 && section <= detail_list.count) {
        temp = 3;
    }
    if (section > detail_list.count) {
        temp = 1;
    }
    
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * str = @"";
    if (section == 0) {
        str = @"BASIC INFO";
    }
    if (section >0 && section <= detail_list.count) {
        detail_pool = [detail_list objectAtIndex:section - 1];
        str = [detail_pool objectForKey:@"grade_subject_str"];
    }
    if (section == detail_list.count+1) {
        str = @" ";
    }
    return str;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.userInteractionEnabled =YES;
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"STUDENT SCORE #%@",self.gradeRecordID];
            cell.detailTextLabel.text = @"";
            cell.userInteractionEnabled = NO;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"GRADE"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[grade_pack objectForKey:@"grade"]];
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"NOTE"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[grade_pack objectForKey:@"note"]];
        }
    }
    if (indexPath.section > 0 && indexPath.section <= detail_list.count) {
        detail_pool = [CYFunctionSet stripNulls:[detail_list objectAtIndex:indexPath.section - 1]];
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"SUBJECT:"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [detail_pool objectForKey:@"grade_subject_str"]];
            cell.userInteractionEnabled = NO;
            
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"SCORE: "];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[detail_pool objectForKey:@"grade_score_str"]];
           
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"NOTE:"];
            cell.detailTextLabel.text = [detail_pool objectForKey:@"note"];
        }
    }
    if (indexPath.section == detail_list.count +1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"DELETE";
            cell.detailTextLabel.text = @"";
            cell.backgroundColor = [UIColor redColor];
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if(indexPath.row == 1){
            //GRADE
            if (grade_list) {
                NSNumber * num = [CYFunctionSet convertStingToNumber:[grade_pack objectForKey:@"grade"]];
                [self performDataPickerForKey:@"grade" forDatasource:grade_list forOrgIndex:num.integerValue -1];

            }else{
                [self prepareGradeList];
            }
        }
        if (indexPath.row == 2) {
            //note
            [self performAlertViewTextModifyWithKey:@"note" forValue:[grade_pack objectForKey:@"note"]
                                       forTableName:@"aci_grade_record" forDataID:self.gradeRecordID];
            
        }
    }
    if (indexPath.section > 0 && indexPath.section <= detail_list.count) {
        detail_pool = [CYFunctionSet stripNulls:[detail_list objectAtIndex:indexPath.section - 1]];
        if (indexPath.row == 1) {
            //SCORE
            if (score_list) {
                NSNumber * num = [CYFunctionSet convertStingToNumber:[detail_pool objectForKey:@"grade_score_id"]];
                [self performDataPickerForKey:@"grade_score_id" forDatasource:score_list forOrgIndex:num.integerValue];
            }else{
                [self requestScoreArray];
            }
        }
        if (indexPath.row == 2) {
            [self performAlertViewTextModifyWithKey:@"note" forValue:[detail_pool objectForKey:@"note"] forTableName:@"aci_grade_detail" forDataID:[detail_pool objectForKey:@"id"]];
        }
    }
    if(indexPath.section == detail_list.count +1){
        if (indexPath.row == 0) {
            [self confirmActionForTitle:@"WARNING" forMessage:@"DELETE THIS SCORE LIST?" forConfirmationHandler:^(UIAlertAction * action) {
                [self requestUpdateRecordForTable:@"aci_grade_record" forDataID:self.gradeRecordID forKey:@"status" forValue:@"0" withTag:11];
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
        grade_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        detail_list = [grade_pack objectForKey:@"detail_list"];
        [self reloadContentTable];
    }
    if (c_tag == 4) {
        scoreArray = [resultDic objectForKey:@"records"];
        [self prepareScoreList];
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

-(void) requestScoreArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        scoreArray = nil;
        
        NSDictionary * dict = @{
                                @"table_name" : @"aci_grade_score",
                                @"result_order": @"`id` ASC"
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:4];
    });
}
-(void) prepareScoreList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in scoreArray) {
        [temp addObject:[dict objectForKey:@"grade_score"]];
    }
    score_list = (NSArray *) temp;
    NSNumber * num = [CYFunctionSet convertStingToNumber:[detail_pool objectForKey:@"grade_score_id"]];
    [self performDataPickerForKey:@"grade_score_id" forDatasource:score_list forOrgIndex:num.integerValue];
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
    if ([key isEqualToString:@"grade"]) {
        [self requestUpdateRecordForTable:@"aci_grade_record" forDataID:self.gradeRecordID forKey:@"grade" forValue:[NSString stringWithFormat:@"%ld",(long)index + 1] withTag:2];
    }
    if ([key isEqualToString:@"grade_score_id"]) {
        [self requestUpdateRecordForTable:@"aci_grade_detail" forDataID:[detail_pool objectForKey:@"id"] forKey:@"grade_score_id" forValue:[NSString stringWithFormat:@"%ld",(long)index] withTag:2];
    }
}
-(void) prepareGradeList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    for (int i = 1; i< 13; i++) {
        [temp addObject:[NSString stringWithFormat:@"%d",i]];
    }
    grade_list = (NSArray *) temp;
    
    NSNumber * num = [CYFunctionSet convertStingToNumber:[grade_pack objectForKey:@"grade"]];
    [self performDataPickerForKey:@"grade" forDatasource:grade_list forOrgIndex:num.integerValue - 1];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}
@end
