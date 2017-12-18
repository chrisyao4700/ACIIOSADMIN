//
//  DiscountRuleDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "DiscountRuleDetailViewController.h"

@interface DiscountRuleDetailViewController ()

@end

@implementation DiscountRuleDetailViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSString * key_pool;
    NSDictionary * rule_pack;
    
    NSNumber * num_pool;
    
    
    NSArray * categoryArray;
    NSArray * category_list;
    
    NSArray * percentageArray;
    
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
    [self requestUpdateRecordForTable:@"aci_discount_rule" forDataID:self.discountRuleID forKey:@"status" forValue:@"1" withTag:11];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestDiscountDetailData:self.discountRuleID];
    
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
                //[self requestStaffInfo];
                [self requestDiscountDetailData:self.discountRuleID];
            }
            
            if (c_tag == 11) {
                //ACTIVE || DELETED
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
            if ([key isEqualToString:@"cashback"]) {
                textField.placeholder = @"Number Only";
            }else{
                textField.text = value;
            }
            
            
            
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



-(void) requestDiscountDetailData:(NSString *) discountID{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_discount_rule`.*, `aci_discount_category`.`discount_category` AS `category_str`, CONCAT (`aci_contact`.`first_name`, ' ', `aci_contact`.`last_name`) AS `creator_name` FROM `aci_discount_rule` LEFT JOIN `aci_discount_category` ON `aci_discount_category`.`id` = `aci_discount_rule`.`discount_category_id` LEFT JOIN `aci_users` ON `aci_users`.`id` = `aci_discount_rule`.`cby` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` WHERE `aci_discount_rule`.`id` = %@",discountID];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:1];
    });
}



//TABLE FUNCTIONS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 5;
    }
    if (section == 1) {
        temp = 1;
    }
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * str = @"";
    
    if (section == 0) {
        str = @"BASIC INFO";
    }
    if (section == 1) {
        str = @" ";
    }
    
    return str;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //ID
            cell.textLabel.text = [NSString stringWithFormat:@"DISCOUNT RULE # %@",self.discountRuleID];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"CREATED BY %@ -- %@",[rule_pack objectForKey:@"creator_name"], [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[rule_pack objectForKey:@"cdate"]]]];
            cell.userInteractionEnabled = NO;
            cell.accessoryType= UITableViewCellAccessoryNone;
        }
        
        if (indexPath.row == 1) {
            cell.textLabel.text = @"NAME";
            cell.detailTextLabel.text = [rule_pack objectForKey:@"name"];
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"DESCRIPTION";
            cell.detailTextLabel.text = [rule_pack objectForKey:@"description"];
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"CATEGORY";
            cell.detailTextLabel.text = [rule_pack objectForKey:@"category_str"];
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = [rule_pack objectForKey:@"category_str"];
            num_pool = [CYFunctionSet convertStingToNumber:[rule_pack objectForKey:@"discount_category_id"]];
            
            if (num_pool.integerValue == 0) {
                // PERCENTAGE
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%% OFF",[rule_pack objectForKey:@"percentage"]];;
            }
            if (num_pool.integerValue == 1) {
                // CASH BACK
                cell.detailTextLabel.text = [rule_pack objectForKey:@"cashback"];
            }
        }
    }
    if (indexPath.section == 1) {
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
    if (indexPath.section == 0) {
        if (indexPath.row < 3) {
            switch (indexPath.row) {
                case 1:
                    key_pool = @"name";
                    break;
                case 2:
                    key_pool = @"description";
                    break;
                    
                default:
                    break;
            }
            [self performAlertViewTextModifyWithKey:key_pool forValue:[rule_pack objectForKey:key_pool] forTableName:@"aci_discount_rule" forDataID:self.discountRuleID];
        }
        if (indexPath.row == 3) {
                //CHANGE CATEGORY
            if (category_list) {
                
                NSNumber * num = [CYFunctionSet convertStingToNumber:[rule_pack objectForKey:@"discount_category_id"]];
                [self performDataPickerForKey:@"discount_category_id" forDatasource:category_list forOrgIndex:num.integerValue];
            }else{
                [self requestCategoryArray];
            }
        }
        if (indexPath.row == 4) {
            num_pool = [CYFunctionSet convertStingToNumber:[rule_pack objectForKey:@"discount_category_id"]];
            
            if (num_pool.integerValue == 0) {
                // PERCENTAGE
                if (percentageArray) {
                    num_pool = [CYFunctionSet convertStingToNumber:[rule_pack objectForKey:@"percentage"]];
                    [self performDataPickerForKey:@"percentage" forDatasource:percentageArray forOrgIndex:num_pool.integerValue];
                }else{
                    [self preparePercentageList];
                }
            }
            if (num_pool.integerValue == 1) {
                // CASH BACK
               [self performAlertViewTextModifyWithKey:@"cashback" forValue:[rule_pack objectForKey:@"cashback"] forTableName:@"aci_discount_rule" forDataID:self.discountRuleID];
            }
            
        }
        
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self requestUpdateRecordForTable:@"aci_discount_rule" forDataID:self.discountRuleID forKey:@"status" forValue:@"0" withTag:11];
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
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        rule_pack = [CYFunctionSet stripNulls: [resultDic objectForKey:@"record"]];
        [self reloadContentTable];
    }
    if (c_tag == 3) {
        categoryArray =[resultDic objectForKey:@"records"];
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
                                @"table_name" : @"aci_discount_category",
                                @"result_order": @"`id` ASC"
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:3];
    });
}
-(void) prepareCategoryList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in categoryArray) {
        [temp addObject:[dict objectForKey:@"discount_category"]];
    }
    category_list = (NSArray *) temp;
    num_pool = [CYFunctionSet convertStingToNumber:[rule_pack objectForKey:@"discount_category_id"]];
    [self performDataPickerForKey:@"discount_category_id" forDatasource:category_list forOrgIndex:num_pool.integerValue];
}
-(void) preparePercentageList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    
    for (int i= 0; i<21; i++) {
        [temp addObject:[NSString stringWithFormat:@"%d",i]];
    }
    percentageArray = (NSArray *) temp;
    num_pool = [CYFunctionSet convertStingToNumber:[rule_pack objectForKey:@"percentage"]];
    [self performDataPickerForKey:@"percentage" forDatasource:percentageArray forOrgIndex:num_pool.integerValue];
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
    [self requestUpdateRecordForTable:@"aci_discount_rule" forDataID:self.discountRuleID forKey:key forValue:[NSString stringWithFormat:@"%ld",(long)index] withTag:2];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

@end
