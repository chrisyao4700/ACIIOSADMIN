//
//  OrderProductDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "OrderProductDetailViewController.h"
#import "CourseDetailDPTableViewCell.h"
#import "CourseDetailViewController.h"
#import "StudentDetailViewController.h"
@interface OrderProductDetailViewController ()

@end

@implementation OrderProductDetailViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSDictionary * product_pack;
    NSDictionary * course_pack;
    NSDictionary * student_pack;
    NSDictionary * student_contact_pack;
    
    NSString * key_pool;
    
    NSData * data_container;
    
    NSNumber * num_pool;
    
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
    if (course_pack && student_pack) {
        [self requestUpdateRecordForTable:@"aci_product" forDataID:self.productID forKey:@"status" forValue:@"1" withTag:11];
    }else{
        [self showAlertWithTittle:@"ERROR" forMessage:@"PLEASE SELECT COURSE AND STUDENT FIRST"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestProductDetailWithTag:1];
}
-(void) requestProductDetailWithTag:(NSInteger) c_tag{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"product_id":self.productID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"select_product" andCustomerTag:c_tag];
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
                [self requestProductDetailWithTag:1];
            }
            if (c_tag == 3) {
                [self.delegate orderProductDidRequestUpdateOrderPrice];
                [self requestProductDetailWithTag:2];
            }
     
            
            if (c_tag == 11) {
                //ACTIVE || DELETED
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate orderProductDidRequestUpdateOrderPrice];
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
    if ([key isEqualToString:@"price"]) {
        [self requestUpdateRecordForTable:table_name forDataID:data_id forKey:key forValue:f_value withTag:3];
    }else{
        [self requestUpdateRecordForTable:table_name forDataID:data_id forKey:key forValue:f_value withTag:2];
    }
    
}



//TABLE FUNCTIONS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 1;
    }
    if (section == 1) {
        if (product_pack) {
            temp = 2;
        }
    }
    if (section == 2) {
        temp = 1;
    }
    if (section == 3) {
        if (student_contact_pack && [student_pack objectForKey:@"id"]) {
            temp = 1;
        }
    }
    if (section == 4) {
        temp = 1;
    }
    if (section == 5) {
        if ([course_pack objectForKey:@"id"]) {
            temp = 1;
        }
    }
    if (section == 6) {
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
        
    }
    if (section == 2) {
        str = @"STUDENT";
    }
    if (section == 4) {
        str = @"COURSE";
    }
    
    if (section == 6) {
        str = @" ";
    }
    
    return str;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell;
    if (indexPath.section != 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
        if (indexPath.section == 0) {
            //ID
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (indexPath.row == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"PRODUCT #%@",self.productID];
                if (product_pack) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"CREATED BY %@ -- %@",[product_pack objectForKey:@"creator_name"], [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[product_pack objectForKey:@"cdate"]]]];
                }else{
                    cell.detailTextLabel.text = @"";
                }
            }
            
        }
        if (indexPath.section == 1) {
            switch (indexPath.row) {
                case 0:
                    key_pool = @"note";
                    break;
                case 1:
                    key_pool = @"price";
                    break;
                    
                default:
                    break;
            }
            cell.textLabel.text = [key_pool.uppercaseString stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            cell.detailTextLabel.text = [product_pack objectForKey:key_pool];
        }
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"SELECT STUDENT";
                cell.detailTextLabel.text = @"";
            }
        }
        if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"STUDENT # %@",[student_pack objectForKey:@"id"]];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[student_contact_pack objectForKey:@"first_name"],[student_contact_pack objectForKey:@"last_name"]];
                data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"student_%@.png", [student_pack objectForKey:@"id"]]];
                if (data_container) {
                    cell.imageView.image = [UIImage imageWithData:data_container];
                }
            }
        }
        if (indexPath.section == 4) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"SELECT COURSE";
                cell.detailTextLabel.text = @"";
            }
        }
        if (indexPath.section == 6) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"DELETE";
                cell.detailTextLabel.text = @"";
                cell.backgroundColor = [UIColor redColor];
            }
        }
        
    }else{
        
        CourseDetailDPTableViewCell * dp_cell = (CourseDetailDPTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"dp_cell" forIndexPath:indexPath];
        
        dp_cell.titleLabel.text = [NSString stringWithFormat:@"%@ -- %@", [course_pack objectForKey:@"class_name"],[course_pack objectForKey:@"class_number"]];
        dp_cell.dpView.text = [NSString stringWithFormat:@"%@    $ %@\nFROM:%@ TO:%@\n%@",[course_pack objectForKey:@"subject_description"],[course_pack objectForKey:@"price"],[course_pack objectForKey:@"start_date"],[course_pack objectForKey:@"end_date"],[course_pack objectForKey:@"campus_name"]];
        dp_cell.dpView.editable = NO;
        dp_cell.dpImageView.image = [UIImage imageNamed:@"dp_course"];
        
        return dp_cell;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                key_pool = @"note";
                break;
            case 1:
                key_pool = @"price";
                break;
                
            default:
                break;
        }
        [self performAlertViewTextModifyWithKey:key_pool forValue:[product_pack objectForKey:key_pool] forTableName:@"aci_product" forDataID:self.productID];
    }
    if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"toStudentSelection" sender:self];
    }
    if (indexPath.section == 3) {
        [self performSegueWithIdentifier:@"toStudentDetail" sender:self];
    }
    if (indexPath.section == 4) {
        [self performSegueWithIdentifier:@"toCourseSelection" sender:self];
    }
    if (indexPath.section == 5) {
        [self performSegueWithIdentifier:@"toCourseDetail" sender:self];
    }
    if (indexPath.section == 6) {
        if (indexPath.row == 0) {
            [self requestUpdateRecordForTable:@"aci_product" forDataID:self.productID forKey:@"status" forValue:@"0" withTag:11];
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
    
    return indexPath.section== 5?120:65;
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
        product_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"product_info"]];
        student_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"student_info"]];
        course_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"course_info"]];
        student_contact_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"student_contact"]];
        [self reloadContentTable];
    }
    if (c_tag == 2) {
        [self requestProductDetailWithTag:1];
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
-(void)courseRootDidSelectCourse:(NSString *)courseID forPrice:(NSString *)price{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray * elements = @[
                               @{
                                   @"key":@"course_id",
                                   @"value":courseID
                                   },
                               @{
                                   @"key":@"price",
                                   @"value":price
                                   }];
        NSDictionary * dict = @{
                                @"table_name":@"aci_product",
                                @"data_id":self.productID,
                                @"element_array":elements
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"update_record" andCustomerTag:2];
    });
}
-(void)studentSelectionDidSelectStudent:(NSString *)studentID{
    [self requestUpdateRecordForTable:@"aci_product" forDataID:self.productID forKey:@"student_id" forValue:studentID withTag:2];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toCourseSelection"]) {
        CourseRootViewController * crvc =(CourseRootViewController *)[segue destinationViewController];
        crvc.mode = @"SELECT";
        crvc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"toStudentSelection"]) {
        StudentSelectViewController * ssvc = (StudentSelectViewController *)[segue destinationViewController];
        ssvc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"toCourseDetail"]) {
        CourseDetailViewController * cdvc = (CourseDetailViewController *)[segue destinationViewController];
        cdvc.courseID = [course_pack objectForKey:@"id"];
    }
    if ([segue.identifier isEqualToString:@"toStudentDetail"]) {
        StudentDetailViewController * sdvc = (StudentDetailViewController *)[segue destinationViewController];
        sdvc.studentID = [student_pack objectForKey:@"id"];
    }
    if ([segue.identifier isEqualToString:@"toAddonSelection"]) {
        
    }
    
}
@end
