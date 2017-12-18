//
//  OrderDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "ParentDetailViewController.h"
#import "LinkPara.h"

@interface OrderDetailViewController ()

@end

@implementation OrderDetailViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSArray * product_list;
    NSArray * addon_list;
    NSArray * discount_list;
    
    NSDictionary * order_pack;
    NSDictionary * parent_pack;
    
    NSDictionary * data_pool;
    NSDictionary * related_student;
    
    
    NSNumber * num_pool;
    
    NSString * id_pool;
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
    [self requestOrderDetailData:self.orderID];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestOrderDetailData:self.orderID];
    
}
-(void) requestOrderDetailData:(NSString *) orderID{
    dispatch_async(dispatch_get_main_queue(), ^{
        order_pack =nil;
        parent_pack = nil;
        product_list = nil;
        related_student = nil;
        addon_list = nil;
        discount_list = nil;
        NSDictionary * dict = @{
                                @"order_id":orderID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"select_order" andCustomerTag:1];
    });
}
-(void) requestUpdateOrderTotal:(NSString *) orderID{
    dispatch_async(dispatch_get_main_queue(), ^{
        order_pack =nil;
        parent_pack = nil;
        product_list = nil;
        related_student = nil;
        addon_list = nil;
        discount_list = nil;
        NSDictionary * dict = @{
                                @"order_id":orderID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"update_order_total" andCustomerTag:4];
    });
}
-(void) requestAddProduct{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray * elements = [[NSMutableArray alloc]initWithArray:@[
                                                                           @{
                                                                               @"key":@"cby",
                                                                               @"value":user.data_id,
                                                                               },
                                                                           @{
                                                                               @"key":@"cdate",
                                                                               @"value":[CYFunctionSet convertDateToConstantString:[NSDate date]],
                                                                               },
                                                                           @{
                                                                               @"key":@"order_id",
                                                                               @"value":self.orderID,
                                                                               }
                                                                           
                                                                           ]];
        if ([related_student objectForKey:@"id"]) {
            [elements addObject:@{
                                  @"key":@"student_id",
                                  @"value":[related_student objectForKey:@"student_id"]
                                  }];
        }
        NSDictionary * dict = @{
                                @"table_name":@"aci_product",
                                @"element_array":(NSArray*)elements
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:3];
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
                //[self requestStaffInfo];
                [self requestOrderDetailData:self.orderID];
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

-(void) requestPaymentWithSquare{
    NSURL *const callbackURL = [NSURL URLWithString:[LinkPara getCallBackURL]];
    
    //NSLog(@"PAYMENT RUNNING");
    // Specify the amount of money to charge.
    NSNumber * total_amount = [CYFunctionSet convertStingToNumber:[order_pack objectForKey:@"total"]];
    SCCMoney *const amount = [SCCMoney moneyWithAmountCents:total_amount.doubleValue *100 currencyCode:@"USD" error:NULL];
    
    // Your client ID is the same as your Square Application ID.
    // Note: You only need to set your client ID once, before creating your first request.
    
    NSDictionary * dict = @{
                            @"order_id":self.orderID,
                            @"total":[order_pack objectForKey:@"total"]
                            };
    [CurrentUserManager saveCurrentPaymentWithDict:dict];
    [SCCAPIRequest setClientID:[LinkPara getPaymentToken]];
    NSError * error = nil;
    [NSString stringWithFormat:@"%@ ORDER #%@",[order_pack objectForKey:@"campus_name"], self.orderID];
    SCCAPIRequest *request = [SCCAPIRequest requestWithCallbackURL:callbackURL
                                                            amount:amount
                                                    userInfoString:[NSString stringWithFormat:@"%@ STAFF %@ %@ # %@",user.main_campus_name, user.first_name, user.last_name, user.data_id]
                                                        locationID:nil notes:[order_pack objectForKey:@"note"]
                                                        customerID:nil
                                              supportedTenderTypes:SCCAPIRequestTenderTypeAll clearsDefaultFees:NO
                                   returnAutomaticallyAfterPayment:NO
                                                             error:&error];
    
    if (error) {
        [self showAlertWithTittle:@"INVALID REQUEST" forMessage:error.debugDescription];
        return;
    }
    
    if (![SCCAPIConnection performRequest:request error:&error]) {
        [self showAlertWithTittle:@"CANNOT PERFORM REQUEST" forMessage:error.debugDescription];
    }
}
-(void) requestDeleteOrder:(NSString *) orderID{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"order_id":orderID,
                                @"org_status":[order_pack objectForKey:@"order_status_id"]
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"cancel_order" andCustomerTag:11];
    
    });
}



//TABLE FUNCTIONS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //ID CAMPUS
    //TOTAL NOTE
    //PARENT * 2
    
    //PRODUCT * 2
    //ADDON * 2
    //DISCOUNT * 2
    //ACTION
    //DELETE
    
    return order_pack?13:0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    switch (section) {
        case 0:
            //ID CAMPUS
            temp = 2;
            break;
        case 1:
            //NOTE
            temp = ([order_pack objectForKey:@"receipt"] && ![[order_pack objectForKey:@"receipt"] isEqualToString:@""])?2:1;
            break;
        case 2:
            temp = 1;
            break;
            
        case 3:
            temp = [parent_pack objectForKey:@"id"]?1:0;
            break;
            
        case 4:
            //ADD COURSE
            temp = 1;
            break;
            
        case 5:
            //COURSE LIST
            temp = product_list?product_list.count:0;
            break;
            
        case 6:
            //ADDON
            temp = 1;
            break;
            
        case 7:
            //ADDON LIST
            temp = addon_list?addon_list.count:0;
            break;
            
        case 8:
            //DISCOUNT
            temp = 1;
            break;
            
        case 9:
            //DISCOUNT LIST
            temp = discount_list?discount_list.count:0;
            break;
        case 10:
            //TOTAL
            temp = 1;
            break;
        case 11:
            //ACTIONS
            temp = 1;
            break;
            
            
        case 12:
            //DELETE
            temp = 1;
            break;
            
            
        default:
            break;
    }
    
    
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    
    if (section == 0) {
        temp = @"BASIC INFO";
    }
    if (section == 2) {
        temp = @"PARENT";
    }
    if (section == 4) {
        temp = @"COURSE";
    }
    if (section == 6) {
        temp = @"ADD-ON ITEMS";
    }
    if (section == 8) {
        temp = @"DISCOUNT";
    }
    if (section == 10) {
        temp = @"ORDER TOTAL";
    }
    if (section == 11) {
        temp = @"ACTIONS";
    }
    if (section == 12) {
        temp = @" ";
    }
    return temp;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.section == 0) {
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            //ID
            cell.textLabel.text = [NSString stringWithFormat:@"ORDER# %@",self.orderID];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"CREATED BY %@ -- %@",[order_pack objectForKey:@"creator_name"],[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[order_pack objectForKey:@"cdate"]]]];
            
        }
        if(indexPath.row == 1){
            cell.textLabel.text = @"CAMPUS";
            cell.detailTextLabel.text =[order_pack objectForKey:@"campus_name"];
        }
        
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"NOTE";
            cell.detailTextLabel.text = [order_pack objectForKey:@"note"];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"PAID -- %@", [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[order_pack objectForKey:@"pdate"]]]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"RECEIPT#:%@", [order_pack objectForKey:@"receipt"]];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text= @"SELECT PARENT";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"PARENT # %@", [parent_pack objectForKey:@"id"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[parent_pack objectForKey:@"parent_name"]];
        }
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ADD COURSE";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 5) {
        data_pool = [CYFunctionSet stripNulls:[product_list objectAtIndex:indexPath.row]];
        
        cell.textLabel.text = [NSString stringWithFormat:@"COURSE #%@ -- %@",[data_pool objectForKey:@"course_id"], [data_pool objectForKey:@"course_name"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$ %@", [data_pool objectForKey:@"price"]];
        
    }
    if (indexPath.section == 6) {
        if(indexPath.row == 0){
            
            cell.textLabel.text = @"NEW ADD-ON";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 7) {
        data_pool = [CYFunctionSet stripNulls:[addon_list objectAtIndex:indexPath.row]];
        cell.textLabel.text = [NSString stringWithFormat:@"ADD-ON# %@ -- %@",[data_pool objectForKey:@"id"],[data_pool objectForKey:@"name"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$ %@",[data_pool objectForKey:@"price"]];
    }
    if (indexPath.section == 8) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ADD DISCOUNT";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 9) {
        data_pool = [CYFunctionSet stripNulls:[discount_list objectAtIndex:indexPath.row]];
        cell.textLabel.text = [NSString stringWithFormat:@"DISCOUNT# %@ -- %@",[data_pool objectForKey:@"id"], [data_pool objectForKey:@"name"]];
        num_pool = [CYFunctionSet convertStingToNumber:[data_pool objectForKey:@"discount_category_id"]];
        
        if (num_pool.integerValue == 0) {
            // PERCENTAGE
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%% OFF",[data_pool objectForKey:@"percentage"]];;
        }
        if (num_pool.integerValue == 1) {
            // CASH BACK
            cell.detailTextLabel.text = [data_pool objectForKey:@"cashback"];
        }
        
        
    }
    if (indexPath.section == 10) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"TOTAL:";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"$ %@",[order_pack objectForKey:@"total"]];
            cell.userInteractionEnabled = NO;
        }
    }
    if (indexPath.section == 11) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"MAKE PAYMENT";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 12) {
        if (indexPath.row == 0) {
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
            //NOTE
            [self performAlertViewTextModifyWithKey:@"note" forValue:[order_pack objectForKey:@"note"] forTableName:@"aci_order" forDataID:self.orderID];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //SELECT PARENT
            [self performSegueWithIdentifier:@"toParentSelection" sender:self];
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"toParentDetail" sender:self];
            //GO TO PARENT DETAIL
        }
    }
    if (indexPath.section == 4) {
        //NEW PRODUCT
        if (indexPath.row == 0) {
            [self requestAddProduct];
        }
    }
    if (indexPath.section == 5) {
        //PRODUCTS
        data_pool = [product_list objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"toProductDetail" sender:self];
    }
    if (indexPath.section == 6) {
        //NEW ADDON
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"toAddonSelection" sender:self];
        }
    }
    if (indexPath.section == 7) {
        //ADDONS
        data_pool = [addon_list objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"toAddonDetail" sender:self];
    }
    
    if (indexPath.section == 8) {
        //NEW DISCOUNT
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"toDiscountSelection" sender:self];
        }
    }
    if (indexPath.section == 9) {
        //DISCOUNTS
        data_pool = [discount_list objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"toDiscountDetail" sender:self];
    }
    if (indexPath.section == 11) {
        
        if (indexPath.row == 0) {
            if (![[order_pack objectForKey:@"order_status_id"] isEqualToString:@"3"]) {
                [self requestPaymentWithSquare];
            }else{
                [self showAlertWithTittle:@"PAID" forMessage:@"THIS ORDER HAS BEEN PAID"];
            }
            
        }
    }
    if(indexPath.section == 12){
        if (indexPath.row == 0) {
            [self requestDeleteOrder:self.orderID];
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
    if (c_tag == 1 || c_tag == 4) {
        order_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"order"]];
        product_list = [resultDic objectForKey:@"product_list"];
        addon_list = [resultDic objectForKey:@"addon_list"];
        discount_list = [resultDic objectForKey:@"discount_list"];
        parent_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"parent"]];
        related_student = [CYFunctionSet stripNulls:[resultDic objectForKey:@"related_student"]];
        [self reloadContentTable];
    }
    if (c_tag == 3) {
        data_pool = [resultDic objectForKey:@"record"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"toProductDetail" sender:self];
        });
    }
    if (c_tag == 11) {
        //ACTIVE || DELETED
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            
        });
        
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

-(void)parentSelectionDidSelctParent:(NSString *)parentID{
    [self requestUpdateRecordForTable:@"aci_order" forDataID:self.orderID forKey:@"parent_id" forValue:parentID withTag:2];
}
-(void)orderProductDidRequestUpdateOrderPrice{
    [self requestUpdateOrderTotal:self.orderID];
}
-(void)orderAddonRequestUpdateOrderPrice{
    [self requestUpdateOrderTotal:self.orderID];
}
-(void)orderDiscountRequestUpdateOrderPrice{
    [self requestUpdateOrderTotal:self.orderID];
}
-(void)orderAddonRootDidCreateOrderAddon:(NSString *)order_discountID{
    [self requestUpdateOrderTotal:self.orderID];
}
-(void)orderDiscountRootDidCreateOrderDiscount:(NSString *)order_discountID{
    [self requestUpdateOrderTotal:self.orderID];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toParentSelection"]) {
        ParentSelectionViewController * psvc = (ParentSelectionViewController *)[segue destinationViewController];
        psvc.mode = @"SELECT";
        psvc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"toParentDetail"]) {
        ParentDetailViewController * pdvc = (ParentDetailViewController *)[segue destinationViewController];
        pdvc.parentID = [parent_pack objectForKey:@"id"];
    }
    if([segue.identifier isEqualToString:@"toProductDetail"]){
        OrderProductDetailViewController * opdvc = (OrderProductDetailViewController *)[segue destinationViewController];
        opdvc.delegate = self;
        opdvc.productID = [data_pool objectForKey:@"id"];
    }
    if([segue.identifier isEqualToString:@"toAddonSelection"]){
        OrderAddonRootViewController * oarvc = (OrderAddonRootViewController *)[segue destinationViewController];
        oarvc.delegate = self;
        oarvc.mode = @"SELECT";
        oarvc.order_id = self.orderID;
    }
    if([segue.identifier isEqualToString:@"toDiscountSelection"]){
        OrderDiscountRootViewController * odrvc = (OrderDiscountRootViewController *)[segue destinationViewController];
        odrvc.delegate = self;
        odrvc.mode = @"SELECT";
        odrvc.order_id = self.orderID;
        
    }
    if([segue.identifier isEqualToString:@"toAddonDetail"]){
        OrderAddonDetailViewController * oadvc = (OrderAddonDetailViewController *)[segue destinationViewController];
        oadvc.delegate = self;
        oadvc.addonID = [data_pool objectForKey:@"id"];
    }
    if([segue.identifier isEqualToString:@"toDiscountDetail"]){
        OrderDiscountDetailViewController * oddvc = (OrderDiscountDetailViewController *)[segue destinationViewController];
        oddvc.delegate = self;
        oddvc.discountID = [data_pool objectForKey:@"id"];
    }
}

-(void) refreshOrderDetail{
    [self showAlertWithTittle:@"SUCCESS" forMessage:@"PAY MENT WENT THROUGHT"];
    [self requestOrderDetailData:self.orderID];
}
-(void) showErrorMessage:(NSString *)message{
    [self showAlertWithTittle:@"ERROR" forMessage:message];
}
@end
