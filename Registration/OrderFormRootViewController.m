//
//  OrderFormRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "OrderFormRootViewController.h"
#import "OrderDetailViewController.h"
#import "OrderRootCollectionViewCell.h"
@interface OrderFormRootViewController ()

@end

@implementation OrderFormRootViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    NSArray * order_list;
    NSDictionary * order_pool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    //[self configBackgroundView];
    user = [CurrentUserManager getCurrentDispatch];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didClickRightItem:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // Do any additional setup after loading the view.
}
-(IBAction)didClickRightItem:(id)sender{
    NSString * searchText = self.searchBar.text;
    if (![searchText isEqualToString:@""]) {
        [self requestOrderListWithSearchStr:searchText];
    }else{
        [self requestOrderList];
    }
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![searchText isEqualToString:@""]) {
        [self requestOrderListWithSearchStr:searchText];
    }else{
        [self requestOrderList];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString * searchText = searchBar.text;
    if (![searchText isEqualToString:@""]) {
        [self requestOrderListWithSearchStr:searchText];
    }else{
        [self requestOrderList];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString * searchText = self.searchBar.text;
    if (![searchText isEqualToString:@""]) {
        [self requestOrderListWithSearchStr:searchText];
    }else{
        [self requestOrderList];
    }
    
    
}
-(void) requestOrderList{
    dispatch_async(dispatch_get_main_queue(), ^{
        order_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_order`.*, `aci_order_status`.`order_status` AS `order_status_str`, CONCAT(`aci_contact`.`first_name`,' ', `aci_contact`.`last_name`) AS `parent_name` FROM `aci_order` LEFT JOIN `aci_parent` ON `aci_parent`.`id` = `aci_order`.`parent_id` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_parent`.`contact_id` LEFT JOIN `aci_order_status` ON `aci_order_status`.`id` = `aci_order`.`order_status_id`  WHERE `aci_order`.`order_status_id` != 0 ORDER BY `aci_order`.`id` DESC LIMIT 30"];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    });
}
-(void) requestOrderListWithSearchStr:(NSString *) searchStr{
    dispatch_async(dispatch_get_main_queue(), ^{
        order_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_order`.*, `aci_order_status`.`order_status` AS `order_status_str`, CONCAT(`aci_contact`.`first_name`,' ', `aci_contact`.`last_name`) AS `parent_name` FROM `aci_order` LEFT JOIN `aci_parent` ON `aci_parent`.`id` = `aci_order`.`parent_id` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_parent`.`contact_id` LEFT JOIN `aci_order_status` ON `aci_order_status`.`id` = `aci_order`.`order_status_id`  WHERE `aci_order`.`order_status_id` != 0 AND (CONCAT(`aci_contact`.`first_name`,' ', `aci_contact`.`last_name`) LIKE '%%%@%%' OR `aci_order`.`id` LIKE '%%%@%%') ORDER BY `aci_order`.`id` DESC LIMIT 30",searchStr,searchStr];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
    });
}
-(void) requestInsertOrder{
    dispatch_async(dispatch_get_main_queue(), ^{
        order_pool = nil;
        NSDictionary * dict = @{
                                @"table_name":@"aci_order",
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
                                            @"key":@"order_status_id",
                                            @"value":@"1"
                                            },
                                        @{
                                            @"key":@"campus_id",
                                            @"value":user.main_campus_id
                                            }
                                        ]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:3];
    });
}
//TABLE FUNCTIONS

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 1;
    }
    if (section == 1) {
        if (order_list) {
            temp = order_list.count;
        }
    }
    return temp;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"add_cell" forIndexPath:indexPath];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subject_background"]];
            cell.layer.cornerRadius= 20.0;
        }
    }
    if (indexPath.section == 1) {
        OrderRootCollectionViewCell * info_cell = (OrderRootCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"info_cell" forIndexPath:indexPath];
        info_cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subject_background"]];
        info_cell.layer.cornerRadius= 20.0;
        order_pool = [CYFunctionSet stripNulls:[order_list objectAtIndex:indexPath.item]];
        info_cell.idLabel.text = [NSString stringWithFormat:@"ORDER# %@",[order_pool objectForKey:@"id"]];
        info_cell.statusLabel.text = [NSString stringWithFormat:@"%@",[order_pool objectForKey:@"order_status_str"]];
        info_cell.cbyLabel.text = [NSString stringWithFormat:@"%@",[order_pool objectForKey:@"parent_name"]];
        info_cell.totalLabel.text = [NSString stringWithFormat:@"$ %@",[order_pool objectForKey:@"total"]];
        return info_cell;
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self requestInsertOrder];
        }
    }
    if (indexPath.section == 1) {
        order_pool = [CYFunctionSet stripNulls:[order_list objectAtIndex:indexPath.item]];
        [self performSegueWithIdentifier:@"toOrderDetail" sender:self];
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
    if (c_tag == 1 || c_tag == 2) {
        order_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 3) {
        order_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"toOrderDetail" sender:self];
        });
    }
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"toOrderDetail"]) {
        OrderDetailViewController * odvc = (OrderDetailViewController *) [segue destinationViewController];
        odvc.orderID = [order_pool objectForKey:@"id"];
    }
}

@end
