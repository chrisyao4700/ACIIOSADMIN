//
//  TeacherRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "TeacherRootViewController.h"
#import "CurrentUserManager.h"

@interface TeacherRootViewController ()

@end

@implementation TeacherRootViewController{
    
    
    NSArray * teacher_list;
    NSDictionary * person_pool;
    
    AppDataSocketConnector * connector;
    
    NSData * data_container;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    [self setNavigationBarString:@"TEACHERS"];
    if (![self.mode isEqualToString:@"SELECT"]) {
        self.delegate = nil;
    }
    //NEWT FUKER ;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestTeacherData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestTeacherData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector =[[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        teacher_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_users`.`id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_user_category`.`user_category` AS `category_str`, `aci_user_status`.`user_status` AS `status_str` FROM `aci_users` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` LEFT JOIN `aci_user_category` ON `aci_user_category`.`id` = `aci_users`.`user_category_id` LEFT JOIN `aci_user_status` ON `aci_user_status`.`id` = `aci_users`.`user_status_id` WHERE `aci_users`.`user_status_id` != 0 AND `aci_users`.`user_category_id` = 3"];
        NSDictionary * dict = @{
                                @"query" : query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
    });
    
}
-(void)requestImageAtIndexPath:(NSIndexPath *)indexPath
                    andStaffID:(NSString *) staff_id{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"file_name":[NSString stringWithFormat:@"staff_%@.png",staff_id]
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_image" andCustomerTag:3 andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            //
            if (![message isEqualToString:@"NO RESULT FOUND"]) {
                [self showAlertWithTittle:@"WARNING" forMessage:message];
            }else{
                
                //[self reloadContentTableWithIndexPath:indexPath];
            }
            
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            data_container = [[NSData alloc] initWithBase64EncodedString:[resultDict objectForKey:@"record"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [CurrentUserManager savePhotoToCoredata:data_container forName:[NSString stringWithFormat:@"staff_%@.png",staff_id]];
            
            [self reloadContentTableWithIndexPath:indexPath];
        }];
        
    });
}


-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
    }
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
    }
-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    if(![message isEqualToString:@"NO RESULT FOUND"]){
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }else{
        [self reloadContentTable];
    }
    
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    
    
       if (c_tag == 2) {
        //HANDLE TEACHER
        teacher_list = [resultDic objectForKey:@"records"];
        
        [self reloadContentTable];
    }
    //fucker = response;
    
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
    if (teacher_list) {
        return teacher_list.count;
    }else{
        return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  65;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    
    person_pool = [CYFunctionSet stripNulls:[teacher_list objectAtIndex:indexPath.row]];
    cell.textLabel.text = [NSString stringWithFormat:@"ID # %@", [person_pool objectForKey:@"id"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[person_pool objectForKey:@"first_name"],[person_pool objectForKey:@"last_name"]];
    data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png",[person_pool objectForKey:@"id"]]];
    if (data_container) {
        cell.imageView.image = [UIImage imageWithData:data_container];
    }else{
        [self requestImageAtIndexPath:indexPath andStaffID:[person_pool objectForKey:@"id"]];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    person_pool = [CYFunctionSet stripNulls:[teacher_list objectAtIndex:indexPath.row]];
    if (self.delegate) {
        [self.delegate teacherSelectionDidSelectTeacher:[person_pool objectForKey:@"id"]];
        [self.navigationController popViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
