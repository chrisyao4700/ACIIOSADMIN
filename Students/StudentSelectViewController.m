//
//  StudentSelectViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "StudentSelectViewController.h"
#import "CurrentUserManager.h"

@interface StudentSelectViewController ()

@end

@implementation StudentSelectViewController{

    AppDataSocketConnector * connector;
    
    NSArray * student_list;
    NSDictionary * student_pool;
    
    NSData * data_container;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    [self setNavigationBarString:@"STUDENTS"];
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
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString * searchText = self.searchBar.text;
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestStudentDataWithSearchStr:searchText forBanList:self.ban_list];
    }else{
        [self requestStudentDataWithBanList:self.ban_list];
    }

}
-(void) requestStudentDataWithBanList:(NSArray *) list{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_student`.`id`, `aci_student`.`birthday`,`aci_student`.`student_category_id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_student_category`.`student_category` AS `student_category_str`,`aci_student_status`.`student_status` AS `student_status_str` FROM `aci_student` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_student`.`contact_id` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_student`.`student_category_id` LEFT JOIN `aci_student_status` ON `aci_student_status`.`id` = `aci_student`.`student_status_id` WHERE `aci_student`.`student_status_id` != 0 %@ ORDER BY `aci_student`.`id` DESC LIMIT 100", [self prepareBanString:list]];
        
        NSDictionary * dict =@{
                               @"query" : query
                               };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
        
    });
}
-(void) requestStudentDataWithSearchStr:(NSString *) searchStr
                             forBanList:(NSArray *) list{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_student`.`id`, `aci_student`.`birthday`,`aci_student`.`student_category_id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_student_category`.`student_category` AS `student_category_str`,`aci_student_status`.`student_status` AS `student_status_str` FROM `aci_student` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_student`.`contact_id` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_student`.`student_category_id` LEFT JOIN `aci_student_status` ON `aci_student_status`.`id` = `aci_student`.`student_status_id` WHERE `aci_student`.`student_status_id` != 0 AND (CONCAT(`aci_contact`.`first_name`,' ', `aci_contact`.`last_name`) LIKE '%%%@%%' OR `aci_contact`.`first_name` LIKE '%%%@%%' OR `aci_contact`.`last_name` LIKE '%%%@%%' ) %@ ORDER BY `aci_student`.`id` DESC LIMIT 20",searchStr,searchStr,searchStr,[self prepareBanString:list]];
        
        NSDictionary * dict =@{
                               @"query" : query
                               };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
        
    });
}

-(void)requestImageAtIndexPath:(NSIndexPath *)indexPath
                    andStudentID:(NSString *) student_id{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"file_name":[NSString stringWithFormat:@"student_%@.png",student_id]
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_image" andCustomerTag:3 andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            //
            if (![message isEqualToString:@"NO RESULT FOUND"]) {
                [self showAlertWithTittle:@"WARNING" forMessage:message];
            }
            
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            data_container = [[NSData alloc] initWithBase64EncodedString:[resultDict objectForKey:@"record"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [CurrentUserManager savePhotoToCoredata:data_container forName:[NSString stringWithFormat:@"student_%@.png",student_id]];
            
            [self reloadContentTableWithIndexPath:indexPath];
        }];
        
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
        NSMutableString * temp = [NSMutableString stringWithFormat:@" AND `aci_student`.`id` NOT IN ("];
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
        student_list = [resultDic objectForKey:@"records"];
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
    if (student_list) {
        return student_list.count;
    }else{
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    
    student_pool = [CYFunctionSet stripNulls:[student_list objectAtIndex:indexPath.row]];
    cell.textLabel.text = [NSString stringWithFormat:@"ID # %@", [student_pool objectForKey:@"id"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[student_pool objectForKey:@"first_name"],[student_pool objectForKey:@"last_name"]];
    data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"student_%@.png",[student_pool objectForKey:@"id"]]];
    if (data_container) {
        cell.imageView.image = [UIImage imageWithData:data_container];
    }else{
        [self requestImageAtIndexPath:indexPath andStudentID:[student_pool objectForKey:@"id"]];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    student_pool = [CYFunctionSet stripNulls:[student_list objectAtIndex:indexPath.row]];
    if (self.delegate) {
        [self.delegate studentSelectionDidSelectStudent:[student_pool objectForKey:@"id"]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestStudentDataWithSearchStr:searchText forBanList:self.ban_list];
    }else{
        [self requestStudentDataWithBanList:self.ban_list];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString * searchText = searchBar.text;
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestStudentDataWithSearchStr:searchText forBanList:self.ban_list];
    }else{
        [self requestStudentDataWithBanList:self.ban_list];
    }
    
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
