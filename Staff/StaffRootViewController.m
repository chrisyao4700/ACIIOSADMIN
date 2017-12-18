//
//  StaffRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "StaffRootViewController.h"
#import "StaffRootCollectionViewCell.h"
#import "StaffDetailViewController.h"

@interface StaffRootViewController ()

@end

@implementation StaffRootViewController{
    AppDataSocketConnector * connector;
    
    BOOL has_root;
    BOOL has_staff;
    BOOL has_teacher;
    
    
    NSArray * root_list;
    
    NSArray * staff_list;
    NSArray * teacher_list;
    
    NSDictionary * person_pool;
    
    NSMutableDictionary * image_pool;
    
    NSData * data_container;
    
    UIBarButtonItem * leftItem;
    UIBarButtonItem * rightItem;
    
    ACI_CURRENT_USER * user;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    self.contentTable.delegate = self;
    self.contentTable.dataSource = self;
    image_pool = [[NSMutableDictionary alloc] init];
   
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightItemDidClick:)];
    leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(leftItemDidClick:)];
    self.navigationItem.rightBarButtonItem = leftItem;
    
    
    user = [CurrentUserManager getCurrentDispatch];
    
    //self.navigationItem.rightBarButtonItem = rightItem;
}
-(IBAction)leftItemDidClick:(id)sender{
    //ADD NEW STAFF
    [self requestAddStaff];
}
-(IBAction)rightItemDidClick:(id)sender{
    //REFRESH
    [self configViewData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configViewData];
    [self setNavigationBarString:@"Staff"];
    
}
-(void) configViewData{
    [self requestRootData];
    [self requestStaffData];
    [self requestTeacherData];
}
-(void) requestRootData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector =[[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        root_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_users`.`id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_user_category`.`user_category` AS `category_str`, `aci_user_status`.`user_status` AS `status_str` FROM `aci_users` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` LEFT JOIN `aci_user_category` ON `aci_user_category`.`id` = `aci_users`.`user_category_id` LEFT JOIN `aci_user_status` ON `aci_user_status`.`id` = `aci_users`.`user_status_id` WHERE `aci_users`.`user_status_id` != 0 AND `aci_users`.`user_category_id` = 0"];
        NSDictionary * dict = @{
                                @"query" : query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:0];
        
        
    });

}
-(void) requestStaffData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector =[[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        staff_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_users`.`id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_user_category`.`user_category` AS `category_str`, `aci_user_status`.`user_status` AS `status_str` FROM `aci_users` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` LEFT JOIN `aci_user_category` ON `aci_user_category`.`id` = `aci_users`.`user_category_id` LEFT JOIN `aci_user_status` ON `aci_user_status`.`id` = `aci_users`.`user_status_id` WHERE `aci_users`.`user_status_id` != 0 AND `aci_users`.`user_category_id` IN (1,2) AND `main_campus_id` = %@",user.main_campus_id];
        NSDictionary * dict = @{
                                @"query" : query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
        
        
    });

}
-(void) requestTeacherData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector =[[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        teacher_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_users`.`id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_user_category`.`user_category` AS `category_str`, `aci_user_status`.`user_status` AS `status_str` FROM `aci_users` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` LEFT JOIN `aci_user_category` ON `aci_user_category`.`id` = `aci_users`.`user_category_id` LEFT JOIN `aci_user_status` ON `aci_user_status`.`id` = `aci_users`.`user_status_id` WHERE `aci_users`.`user_status_id` != 0 AND `aci_users`.`user_category_id` = 3 AND `main_campus_id` = %@",user.main_campus_id];
        NSDictionary * dict = @{
                                @"query" : query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
    });

}

-(void) requestAddStaff{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        
        NSDictionary * dict = @{
                                @"campus_id":user.main_campus_id
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_staff" andCustomerTag:4];
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
                [image_pool setObject: [UIImage imageNamed:@"NO_RESULT_FOUND"] forKey:[NSString stringWithFormat:@"staff_%@.png",staff_id]];
                [self reloadContentTableWithIndexPath:indexPath];
            }
        
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            data_container = [[NSData alloc] initWithBase64EncodedString:[resultDict objectForKey:@"record"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [image_pool setObject:[UIImage imageWithData:data_container] forKey:[NSString stringWithFormat:@"staff_%@.png",staff_id]];
            
            [CurrentUserManager savePhotoToCoredata:data_container forName:[NSString stringWithFormat:@"staff_%@.png",staff_id]];
            
            [self reloadContentTableWithIndexPath:indexPath];
        }];
    
    });
}

#pragma MARK COLLECTION
-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
    
    if (c_tag == 0) {
        has_root = NO;
    }
    if (c_tag == 1) {
        has_staff = NO;
    }
    if (c_tag == 2) {
        has_teacher = NO;
    }
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
    if (c_tag == 0) {
        has_root = YES;
    }
    if (c_tag == 1) {
        has_staff = YES;
    }
    if (c_tag == 2) {
        has_teacher = YES;
    }
}
-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    if(![message isEqualToString:@"NO RESULT FOUND"]){
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }
    if (c_tag <3) {
        [self checkListResponse];
    }
    
    
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 0) {
        //HANDLE ROOT
        
        root_list = [resultDic objectForKey:@"records"];
        for (NSDictionary * dict in root_list) {
            data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png",[dict objectForKey:@"id"]]];
            if (data_container) {
                [image_pool setObject:[UIImage imageWithData:data_container] forKey:[NSString stringWithFormat:@"staff_%@.png",[dict objectForKey:@"id"]]];
            }
        }
        [self checkListResponse];
        
    }

    
    if (c_tag == 1) {
        //HANDLE NORMAL STAFF
       
        staff_list = [resultDic objectForKey:@"records"];
        for (NSDictionary * dict in staff_list) {
            data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png",[dict objectForKey:@"id"]]];
            if (data_container) {
                [image_pool setObject:[UIImage imageWithData:data_container] forKey:[NSString stringWithFormat:@"staff_%@.png",[dict objectForKey:@"id"]]];
            }
        }
        [self checkListResponse];
        
    }
    if (c_tag == 2) {
        //HANDLE TEACHER
        
        teacher_list = [resultDic objectForKey:@"records"];
        for (NSDictionary * dict in teacher_list) {
            data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png",[dict objectForKey:@"id"]]];
            if (data_container) {
                [image_pool setObject:[UIImage imageWithData:data_container] forKey:[NSString stringWithFormat:@"staff_%@.png",[dict objectForKey:@"id"]]];
            }

        }
        [self checkListResponse];
    }
    if (c_tag == 4) {
        //INSERT STAFF
        person_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"staffRootToStaffDetail" sender:self];
        });
        
    }
    
}
-(void) checkListResponse{
    if (has_root == YES && has_teacher == YES && has_staff == YES) {
        [self reloadContentTable];
    }
}

#pragma mark COLLECTINS
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 3;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        if (root_list) {
            temp = root_list.count;
        }
    }
    if (section == 1) {
        if (staff_list) {
            temp = staff_list.count;
        }
    }
    if (section == 2) {
        if (teacher_list) {
            temp = teacher_list.count;
        }
    }
    
    return temp;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    StaffRootCollectionViewCell * cell = (StaffRootCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"staff_background"]];
    cell.layer.cornerRadius = 20.0;
    if (indexPath.section == 0) {
        //STAFF
        person_pool  = [CYFunctionSet stripNulls:[root_list objectAtIndex:indexPath.item]];
    }
    
    if (indexPath.section == 1) {
        //STAFF
        person_pool  = [CYFunctionSet stripNulls:[staff_list objectAtIndex:indexPath.item]];
    }
    if (indexPath.section == 2) {
        person_pool = [CYFunctionSet stripNulls:[teacher_list objectAtIndex:indexPath.item]];
    }

    
    cell.idLabel.text = [NSString stringWithFormat:@"ID # %@", [person_pool objectForKey:@"id"]];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [person_pool objectForKey:@"first_name"],[person_pool objectForKey:@"last_name"]];
    cell.categoryLabel.text = [NSString stringWithFormat:@"%@", [person_pool objectForKey:@"category_str"]];
    cell.statusLabel.text = [NSString stringWithFormat:@"%@", [person_pool objectForKey:@"status_str"]];
    
    if ([image_pool objectForKey:[NSString stringWithFormat:@"staff_%@.png",[person_pool objectForKey:@"id"]]]) {
        cell.staffImage.image = [image_pool objectForKey:[NSString stringWithFormat:@"staff_%@.png",[person_pool objectForKey:@"id"]]];
        cell.staffImage.layer.cornerRadius = 15.0;
    }else{
        [self requestImageAtIndexPath:indexPath andStaffID:[person_pool objectForKey:@"id"]];
    }
    
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //STAFF
        person_pool  = [CYFunctionSet stripNulls:[root_list objectAtIndex:indexPath.item]];
    }
    if (indexPath.section == 1) {
        //STAFF
        person_pool  = [CYFunctionSet stripNulls:[staff_list objectAtIndex:indexPath.item]];
    }
    if (indexPath.section == 2) {
        person_pool = [CYFunctionSet stripNulls:[teacher_list objectAtIndex:indexPath.item]];
    }
    [self performSegueWithIdentifier:@"staffRootToStaffDetail" sender:self];
}
-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}

-(void) reloadContentTableWithIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadItemsAtIndexPaths:@[indexPath]];
    });
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"staffRootToStaffDetail"]) {
        StaffDetailViewController * sdvc = (StaffDetailViewController *)[segue destinationViewController];
        sdvc.staffID = [person_pool objectForKey:@"id"];
    }
}


@end
