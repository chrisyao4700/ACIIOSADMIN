//
//  OrderDiscountRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "OrderDiscountRootViewController.h"
#import "OrderDiscountRooCollectionViewCell.h"
#import "DiscountRuleDetailViewController.h"
@interface OrderDiscountRootViewController ()

@end

@implementation OrderDiscountRootViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSArray * rule_list;
    NSDictionary * rule_pool;
    
    
    NSNumber * num_pool;
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
    [self requestDiscountRuleList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestDiscountRuleList];
    
}
-(void) requestDiscountRuleList{
    dispatch_async(dispatch_get_main_queue(), ^{
        rule_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_discount_rule`.*, `aci_discount_category`.`discount_category` AS `category_str`, CONCAT (`aci_contact`.`first_name`, ' ', `aci_contact`.`last_name`) AS `creator_name` FROM `aci_discount_rule` LEFT JOIN `aci_discount_category` ON `aci_discount_category`.`id` = `aci_discount_rule`.`discount_category_id` LEFT JOIN `aci_users` ON `aci_users`.`id` = `aci_discount_rule`.`cby` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` WHERE `aci_discount_rule`.`status` != 0 AND `aci_discount_rule`.`campus_id` = %@ LIMIT 30",user.main_campus_id];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    });
}

-(void) requestInsertDiscountRule{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"table_name":@"aci_discount_rule",
                                @"element_array":@[
                                        @{
                                            @"key":@"cdate",
                                            @"value":[CYFunctionSet convertDateToConstantString:[NSDate date]]
                                            },
                                        @{
                                            @"key":@"cby",
                                            @"value":user.data_id
                                            },
                                        @{
                                            @"key":@"campus_id",
                                            @"value":user.main_campus_id
                                            }
                                        
                                        
                                        ]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:2];
    
    });

}
-(void) requestCreateOrderDiscountWithRule:(NSString *) rule_id
                             forOrderID:(NSString *) order_id{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                              @"discount_rule_id":rule_id,
                              @"order_id": order_id,
                              @"cby":user.data_id,
                              @"cdate":[CYFunctionSet convertDateToConstantString:[NSDate date]]
                              };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"create_order_discount" andCustomerTag:3];
    
    });
}

//TABLE FUNCTIONS


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        if ([self.mode isEqualToString:@"MANAGE"]) {
            temp = 1;
        }
    }
    if (section == 1) {
        if (rule_list) {
            temp = rule_list.count;
        }
    }
    
    return temp;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"add_cell" forIndexPath:indexPath];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subject_background"]];
        cell.layer.cornerRadius= 20.0;
    }
    if (indexPath.section == 1) {
        OrderDiscountRooCollectionViewCell * info_cell = (OrderDiscountRooCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"info_cell" forIndexPath:indexPath];
        info_cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subject_background"]];
        info_cell.layer.cornerRadius= 20.0;
        rule_pool = [CYFunctionSet stripNulls:[rule_list objectAtIndex:indexPath.item]];
        info_cell.idLabel.text = [NSString stringWithFormat:@"RULE # %@",[rule_pool objectForKey:@"id"]];
        info_cell.nameLabel.text = [NSString stringWithFormat:@"%@",[rule_pool objectForKey:@"name"]];
        num_pool = [CYFunctionSet convertStingToNumber:[rule_pool objectForKey:@"discount_category_id"]];
        
        if (num_pool.integerValue == 0) {
            // PERCENTAGE
            
            info_cell.priceLabel.text = [NSString stringWithFormat:@"%@%% OFF",[rule_pool objectForKey:@"percentage"]];
        }
        if (num_pool.integerValue == 1) {
            // CASH BACK
            info_cell.priceLabel.text = [NSString stringWithFormat:@"$ %@ OFF",[rule_pool objectForKey:@"cashback"]];
        }
        
        return info_cell;
        
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if ([self.mode isEqualToString:@"MANAGE"]) {
            [self requestInsertDiscountRule];
        }
    }
    if (indexPath.section == 1) {
        if ([self.mode isEqualToString:@"MANAGE"]) {
            
            
            

        }
        if ([self.mode isEqualToString:@"SELECT"]) {
            rule_pool = [CYFunctionSet stripNulls:[rule_list objectAtIndex:indexPath.item]];
            [self requestCreateOrderDiscountWithRule:[rule_pool objectForKey:@"id"] forOrderID:self.order_id];
            //[self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }
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
        rule_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 2) {
        rule_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"toRuleDetail" sender:self];
        });
    }
    if (c_tag == 3) {
        rule_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate) {
                [self.delegate orderDiscountRootDidCreateOrderDiscount:[rule_pool objectForKey:@"id"]];
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        });
    }
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if ([segue.identifier isEqualToString:@"toRuleDetail"]) {
        DiscountRuleDetailViewController * drdvc = (DiscountRuleDetailViewController *)[segue destinationViewController];
        drdvc.discountRuleID = [rule_pool objectForKey:@"id"];
    }
   
}
@end
