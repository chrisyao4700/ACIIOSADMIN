//
//  OrderAddonRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "OrderAddonRootViewController.h"
#import "OrderDiscountRooCollectionViewCell.h"
#import "AddonRuleDetailViewController.h"
@interface OrderAddonRootViewController ()

@end

@implementation OrderAddonRootViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSArray * rule_list;
    NSDictionary * rule_pool;
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
    [self requestAddonRuleList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestAddonRuleList];
    
}

-(void) requestAddonRuleList{
    dispatch_async(dispatch_get_main_queue(), ^{
        rule_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_addon_rule`.*, CONCAT (`aci_contact`.`first_name`, ' ', `aci_contact`.`last_name`) AS `creator_name` FROM `aci_addon_rule` LEFT JOIN `aci_users` ON `aci_users`.`id` = `aci_addon_rule`.`cby` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` WHERE `aci_addon_rule`.`status` != 0 AND `aci_addon_rule`.`campus_id` = %@ LIMIT 30",user.main_campus_id];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    });
}

-(void) requestInsertAddonRule{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"table_name":@"aci_addon_rule",
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
-(void) requestCreateOrderAddonWithRule:(NSString *) rule_id
                                forOrderID:(NSString *) order_id{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"addon_rule_id":rule_id,
                                @"order_id": order_id,
                                @"cby":user.data_id,
                                @"cdate":[CYFunctionSet convertDateToConstantString:[NSDate date]]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"create_order_addon" andCustomerTag:3];
        
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
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_background"]];
        cell.layer.cornerRadius= 20.0;
    }
    if (indexPath.section == 1) {
        OrderDiscountRooCollectionViewCell * info_cell = (OrderDiscountRooCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"info_cell" forIndexPath:indexPath];
        info_cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_background"]];
        info_cell.layer.cornerRadius= 20.0;
        rule_pool = [CYFunctionSet stripNulls:[rule_list objectAtIndex:indexPath.item]];
        info_cell.idLabel.text = [NSString stringWithFormat:@"RULE # %@",[rule_pool objectForKey:@"id"]];
        info_cell.nameLabel.text = [NSString stringWithFormat:@"%@",[rule_pool objectForKey:@"name"]];
        info_cell.priceLabel.text = [NSString stringWithFormat:@"$ %@",[rule_pool objectForKey:@"price"]];
        return info_cell;
        
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self requestInsertAddonRule];
        }
        
    }
    if (indexPath.section == 1) {
        
        if ([self.mode isEqualToString:@"MANAGE"]) {
            rule_pool = [CYFunctionSet stripNulls:[rule_list objectAtIndex:indexPath.item]];
            [self performSegueWithIdentifier:@"toRuleDetail" sender:self];

        }
        if ([self.mode isEqualToString:@"SELECT"]) {
            rule_pool = [CYFunctionSet stripNulls:[rule_list objectAtIndex:indexPath.item]];
            [self requestCreateOrderAddonWithRule:[rule_pool objectForKey:@"id"] forOrderID:self.order_id];
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
                [self.delegate orderAddonRootDidCreateOrderAddon:[rule_pool objectForKey:@"id"]];
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
        AddonRuleDetailViewController * ardvc = (AddonRuleDetailViewController *)[segue destinationViewController];
        ardvc.addonRuleID = [rule_pool objectForKey:@"id"];
    }
}
@end
