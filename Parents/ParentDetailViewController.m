//
//  ParentDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ParentDetailViewController.h"
#import "StudentListDisplayViewController.h"
@interface ParentDetailViewController ()

@end

@implementation ParentDetailViewController{
    UIBarButtonItem * rightItem;
    
    
    NSDictionary * parent_pack;
    NSDictionary * contact_pack;
    NSDictionary * address_pack;
    

    
    AppDataSocketConnector * connector;
    
    UIAlertController * text_alert;

    NSData * data_container;
    NSString * key_pool;
    
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    [self setNavigationBarString:[NSString stringWithFormat:@"PARENT # %@",self.parentID]];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightItemDidClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    // Do any additional setup after loading the view.
}

-(IBAction)rightItemDidClick:(id)sender{
    //REFRESH
    //[self configViewData];
    [self requestUpdateRecordForTable:@"aci_parent" forDataID:self.parentID forKey:@"parent_status_id" forValue:@"1" withTag:11];
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestParentDetailData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestParentDetailData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        parent_pack = nil;
        contact_pack = nil;
        address_pack = nil;
        
        NSDictionary * dict = @{
                                @"parent_id": self.parentID
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"select_parent" andCustomerTag:1 andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            parent_pack = [CYFunctionSet stripNulls:[resultDict objectForKey:@"parent"]];
            contact_pack = [CYFunctionSet stripNulls:[resultDict objectForKey:@"contact"]];
            address_pack = [CYFunctionSet stripNulls:[resultDict objectForKey:@"address"]];
            [self reloadContentTable];
        }];
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
                [self requestParentDetailData];
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
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp  = 0;
    if (section == 0) {
        // ID
        temp = 1;
    }
    if (section == 1) {
        //BASIC INFO
        temp = 2;
    }
    
    if (section == 2) {
        //CONTACT INFO
        temp = 5;
    }
    if (section == 3) {
        //ADDRESS INFO
        temp = 6;
    }
    if (section == 4) {
        temp = 1;
    }
    if (section == 5) {
        //ACTIONS
        temp = 1;
    }
    return  temp;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat temp = 65.0;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        temp = 100.0;
    }
    return temp;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
        temp = @"BASIC INFO";
    }
    if (section == 1) {
        
    }
    if (section == 2) {
        temp = @"CONTACT INFO";
    }
    if (section == 3) {
        temp = @"ADDRESS INFO";
    }
    if (section == 4) {
        temp = @"RELATED STUDENT";
    }
    if (section == 5) {
        temp = @" ";
    }
    return temp;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;
        if (indexPath.row == 0) {
            cell.userInteractionEnabled = NO;
            cell.textLabel.text = [NSString stringWithFormat:@"PARENT ID # %@", self.parentID];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"CREATED BY %@ -- %@", [parent_pack objectForKey:@"creator_name"],[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[parent_pack objectForKey:@"cdate"]]]];
            
        }
        
    }
    
    if (indexPath.section != 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
    }
    if (indexPath.section == 1) {
        //LOG IN INFO
        if (indexPath.row == 0) {
            cell.textLabel.text = @"USERNAME:";
            cell.detailTextLabel.text = [parent_pack objectForKey:@"username"];
            
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"PASSWORD:";
            cell.detailTextLabel.text = @"****";
        }
        
    }
    
    
    if (indexPath.section == 2) {
        //CONTACT INFO
        switch (indexPath.row) {
            case 0:
                key_pool = @"first_name";
                break;
            case 1:
                key_pool = @"last_name";
                break;
            case 2:
                key_pool = @"phone";
                break;
            case 3:
                key_pool = @"email";
                break;
            case 4:
                key_pool = @"emergency_phone";
                break;
            default:
                break;
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@:",[key_pool.uppercaseString stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
        cell.detailTextLabel.text = [contact_pack objectForKey:key_pool];
    }
    if (indexPath.section == 3) {
        //ADDRESS INFO
        
        switch (indexPath.row) {
            case 0:
                key_pool = @"street_frist_line";
                break;
            case 1:
                key_pool = @"street_second_line";
                break;
            case 2:
                key_pool = @"zipcode";
                break;
            case 3:
                key_pool = @"city";
                break;
            case 4:
                key_pool = @"state";
                break;
            case 5:
                key_pool = @"country";
                break;
            default:
                break;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@:",[key_pool.uppercaseString stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
        cell.detailTextLabel.text = [address_pack objectForKey:key_pool];
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"VIEW STUDENT LIST";
            cell.detailTextLabel.text = @"";
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"DELETE"];
            cell.detailTextLabel.text = @"";
            cell.backgroundColor = [UIColor redColor];

        }
        
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        //ID;
        
        
    }
    if (indexPath.section == 1) {
        if (indexPath.row < 2) {
            //USERNAME & PASS
            switch (indexPath.row) {
                case 0:
                    key_pool = @"username";
                    break;
                case 1:
                    key_pool = @"password";
                    break;
                default:
                    break;
            }
            [self performAlertViewTextModifyWithKey:key_pool forValue:[parent_pack objectForKey:key_pool] forTableName:@"aci_parent" forDataID:self.parentID];
            
        }
        
    }
    
    
    if (indexPath.section == 2) {
        //CONTACT
        switch (indexPath.row) {
            case 0:
                key_pool = @"first_name";
                break;
            case 1:
                key_pool = @"last_name";
                break;
            case 2:
                key_pool = @"phone";
                break;
            case 3:
                key_pool = @"email";
                break;
            case 4:
                key_pool = @"emergency_phone";
                break;
            default:
                break;
        }
        [self performAlertViewTextModifyWithKey:key_pool forValue:[contact_pack objectForKey:key_pool] forTableName:@"aci_contact" forDataID:[contact_pack objectForKey:@"id"]];
    }
    if (indexPath.section == 3) {
        //ADDRESS
        switch (indexPath.row) {
            case 0:
                key_pool = @"street_frist_line";
                break;
            case 1:
                key_pool = @"street_second_line";
                break;
            case 2:
                key_pool = @"zipcode";
                break;
            case 3:
                key_pool = @"city";
                break;
            case 4:
                key_pool = @"state";
                break;
            case 5:
                key_pool = @"country";
                break;
            default:
                break;
        }
        [self performAlertViewTextModifyWithKey:key_pool forValue:[address_pack objectForKey:key_pool] forTableName:@"aci_contact_address" forDataID:[address_pack objectForKey:@"id"]];
        
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"parentDetailToStudentDisplay" sender:self];
        }
    }
    if(indexPath.section == 5){
        if (indexPath.row == 0) {
            [self requestUpdateRecordForTable:@"aci_parent" forDataID:self.parentID forKey:@"parent_status_id" forValue:@"0" withTag:11];
        }
        
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





// The original image has been cropped. Additionally provides a rotation angle used to produce image.



#pragma mark CONNECTOR

-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    [self showAlertWithTittle:@"ERROR" forMessage:message];
}
-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 2) {
        [self requestParentDetailData];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"parentDetailToStudentDisplay"]) {
        StudentListDisplayViewController * sldvc = (StudentListDisplayViewController *)[segue destinationViewController];
        sldvc.mode = @"PARENT";
        sldvc.data_id = self.parentID;
    }
    
}


@end
