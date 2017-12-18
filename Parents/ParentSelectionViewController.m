//
//  ParentSelectionViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ParentSelectionViewController.h"

@interface ParentSelectionViewController ()

@end

@implementation ParentSelectionViewController{
    
    AppDataSocketConnector * connector;
    
    NSArray * parent_list;
    NSDictionary * parent_pool;
    
    NSData * data_container;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    [self setNavigationBarString:@"PARENT"];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }
    [self reloadContentTable];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString * searchText = self.searchBar.text;
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestParentDataWithSearchStr:searchText forBanList:self.ban_list];
    }else{
        [self requestParentDataWithBanList:self.ban_list];
    }
}
-(void) requestParentDataWithBanList:(NSArray *) list{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_parent`.`id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_contact`.`phone` FROM `aci_parent` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_parent`.`contact_id`  WHERE `aci_parent`.`parent_status_id` != 0 %@ ORDER BY `aci_parent`.`id` DESC LIMIT 100", [self prepareBanString:list]];
        
        NSDictionary * dict =@{
                               @"query" : query
                               };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
        
    });
}
-(void) requestParentDataWithSearchStr:(NSString *) searchStr
                             forBanList:(NSArray *) list{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_parent`.`id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_contact`.`phone` FROM `aci_parent` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_parent`.`contact_id` WHERE `aci_parent`.`parent_status_id` != 0 AND (CONCAT(`aci_contact`.`first_name`,' ', `aci_contact`.`last_name`) LIKE '%%%@%%' OR `aci_contact`.`first_name` LIKE '%%%@%%' OR `aci_contact`.`last_name` LIKE '%%%@%%' OR `aci_contact`.`phone` LIKE '%%%@%%' OR `aci_parent`.`id` LIKE '%%%@%%') %@ ORDER BY `aci_parent`.`id` DESC LIMIT 20",searchStr,searchStr,searchStr,searchStr,searchStr,[self prepareBanString:list]];
        
        NSDictionary * dict =@{
                               @"query" : query
                               };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
        
    });
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

-(NSString *) prepareBanString:(NSArray *) list{
    
    if (list && list.count > 0) {
        NSMutableString * temp = [NSMutableString stringWithFormat:@" AND `aci_parent`.`id` NOT IN ("];
        for (int i = 0; i< list.count - 1; i++) {
            [temp appendFormat:@"%@, ", [list objectAtIndex:i]];
        }
        [temp appendFormat:@"%@ )",[list lastObject]];
        
        return (NSString *) temp;
    }else{
        return @"";
    }
}



-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag  == 1 || c_tag == 2) {
        parent_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (parent_list) {
        return parent_list.count;
    }else{
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    
    parent_pool = [CYFunctionSet stripNulls:[parent_list objectAtIndex:indexPath.row]];
    cell.textLabel.text = [NSString stringWithFormat:@"ID # %@", [parent_pool objectForKey:@"id"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ -- %@",[parent_pool objectForKey:@"first_name"],[parent_pool objectForKey:@"last_name"], [parent_pool objectForKey:@"phone"]];
       
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    parent_pool = [CYFunctionSet stripNulls:[parent_list objectAtIndex:indexPath.row]];
    if (self.delegate) {
        [self.delegate parentSelectionDidSelctParent:[parent_pool objectForKey:@"id"]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestParentDataWithSearchStr:searchText forBanList:self.ban_list];
    }else{
        [self requestParentDataWithBanList:self.ban_list];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString * searchText = searchBar.text;
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestParentDataWithSearchStr:searchText forBanList:self.ban_list];
    }else{
        [self requestParentDataWithBanList:self.ban_list];
    }
    
}

@end
