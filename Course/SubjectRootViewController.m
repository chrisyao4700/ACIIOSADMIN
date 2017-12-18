//
//  SubjectRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "SubjectRootViewController.h"
#import "SubjectRootCollectionViewCell.h"
#import "SubjectDetailViewController.h"
@interface SubjectRootViewController ()

@end

@implementation SubjectRootViewController{
    AppDataSocketConnector * connector;
    
    NSArray * subject_list;
    
    NSDictionary * subject_pool;
    
    UIBarButtonItem  *rightItem;
    UIBarButtonItem * leftItem;
    
    ACI_CURRENT_USER * user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self setNavigationBarString:@"Sujects"];
    if (![self.mode isEqualToString:@"SELECT"]) {
        self.delegate = nil;
    }
    user = [CurrentUserManager getCurrentDispatch];
    
    
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightItemDidClick:)];
    leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(leftItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if (!self.delegate) {
        //self.navigationItem.leftBarButtonItem = leftItem;
    }
    // Do any additional setup after loading the view.
}
-(IBAction)rightItemDidClick:(id)sender{
    
    if (![self.searchBar.text isEqualToString:@""]) {
        [self requestSearchSubjectWithString:self.searchBar.text];
    }else{
        [self requestSubjectList];
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.searchBar.text isEqualToString:@""]) {
        [self requestSearchSubjectWithString:self.searchBar.text];
    }else{
        [self requestSubjectList];
    }

}

-(IBAction)leftItemDidClick:(id)sender{
    [self requestAddSubject];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark REQUESTS
-(void) requestSubjectList{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        NSString * query;
        subject_list = nil;
        if (!self.delegate) {
             query = [NSString stringWithFormat:@"SELECT `aci_subject`.`id`, `aci_subject`.`class_number`, `aci_subject`.`class_name`, `aci_subject`.`description`, `aci_student_category`.`student_category` AS `student_category_str`, `aci_subject_status`.`subject_status` AS `subject_status_str` FROM `aci_subject` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_subject`.`student_category_id` LEFT JOIN `aci_subject_status` ON `aci_subject_status`.`id` = `aci_subject`.`subject_status_id` WHERE `aci_subject`.`subject_status_id` != 0 AND `aci_subject`.`campus_id` = %@ ORDER BY `aci_subject`.`id` DESC LIMIT 35",user.main_campus_id];
        }else{
            query = [NSString stringWithFormat:@"SELECT `aci_subject`.`id`, `aci_subject`.`class_number`, `aci_subject`.`class_name`, `aci_subject`.`description`, `aci_student_category`.`student_category` AS `student_category_str`, `aci_subject_status`.`subject_status` AS `subject_status_str` FROM `aci_subject` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_subject`.`student_category_id` LEFT JOIN `aci_subject_status` ON `aci_subject_status`.`id` = `aci_subject`.`subject_status_id` WHERE `aci_subject`.`subject_status_id` = 2 AND `aci_subject`.`campus_id` = %@ ORDER BY `aci_subject`.`id` DESC LIMIT 35",user.main_campus_id];
        }
        
        
        NSDictionary * dict = @{
                                @"query":query
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    });
}

-(void) requestAddSubject{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        
        
        subject_pool = nil;
        NSDictionary * dict = @{
                                @"table_name":@"aci_subject",
                                @"element_array":@[
                                        @{
                                            @"key": @"subject_status_id",
                                            @"value":@"1"
                                            },
                                        @{
                                            @"key": @"student_category_id",
                                            @"value": @"0"
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


-(void) requestSearchSubjectWithString:(NSString *) searchStr{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        NSString * query;
        subject_list = nil;
        if (!self.delegate) {
             query = [NSString stringWithFormat:@"SELECT `aci_subject`.`id`, `aci_subject`.`class_number`, `aci_subject`.`class_name`, `aci_subject`.`description`, `aci_student_category`.`student_category` AS `student_category_str`, `aci_subject_status`.`subject_status` AS `subject_status_str` FROM `aci_subject` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_subject`.`student_category_id` LEFT JOIN `aci_subject_status` ON `aci_subject_status`.`id` = `aci_subject`.`subject_status_id` WHERE `aci_subject`.`subject_status_id` != 0 AND `aci_subject`.`campus_id` = %@ AND (`aci_student_category`.`student_category` LIKE '%%%@%%' OR `aci_subject`.`class_number` LIKE '%%%@%%' OR `aci_subject`.`class_name` LIKE '%%%@%%' OR `aci_subject`.`description` LIKE '%%%@%%') ORDER BY `aci_subject`.`id` DESC LIMIT 20",user.main_campus_id, searchStr,searchStr,searchStr,searchStr];
        }else{
        query = [NSString stringWithFormat:@"SELECT `aci_subject`.`id`, `aci_subject`.`class_number`, `aci_subject`.`class_name`, `aci_subject`.`description`, `aci_student_category`.`student_category` AS `student_category_str`, `aci_subject_status`.`subject_status` AS `subject_status_str` FROM `aci_subject` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_subject`.`student_category_id` LEFT JOIN `aci_subject_status` ON `aci_subject_status`.`id` = `aci_subject`.`subject_status_id` WHERE `aci_subject`.`subject_status_id` = 2 AND AND `aci_subject`.`campus_id` = %@ AND (`aci_student_category`.`student_category` LIKE '%%%@%%' OR `aci_subject`.`class_number` LIKE '%%%@%%' OR `aci_subject`.`class_name` LIKE '%%%@%%' OR `aci_subject`.`description` LIKE '%%%@%%') ORDER BY `aci_subject`.`id` DESC LIMIT 20",user.main_campus_id, searchStr,searchStr,searchStr,searchStr];
        }
        
        
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:3];
    });
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
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        // NORMAL
        subject_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    
    if (c_tag == 2) {
        //ADD
        subject_pool = [CYFunctionSet stripNulls: [resultDic objectForKey:@"record"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"subjectRootToSubjectDetail" sender:self];
        });
    }
    
    if (c_tag == 3) {
        // SEARCH
        subject_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
}



#pragma mark COLLECTION

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger temp = 0 ;
    
    if (section == 0) {
        if (!self.delegate) {
            temp = 1;
        }
    }
    if (section == 1) {
        if (subject_list) {
            temp = subject_list.count;
        }
    }
    return temp;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell;
    
    if (indexPath.section == 0) {
        //ADD
        if (indexPath.row == 0) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"add_cell" forIndexPath:indexPath];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subject_bk_2"]];
            cell.layer.cornerRadius = 20.0;
        }
        
        
    }
    if (indexPath.section == 1) {
        SubjectRootCollectionViewCell * info_cell = (SubjectRootCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"info_cell" forIndexPath:indexPath];
        info_cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subject_bk_2"]];
        info_cell.layer.cornerRadius = 20.0;
        
        subject_pool = [CYFunctionSet stripNulls:[subject_list objectAtIndex:indexPath.item]];
        
        info_cell.idLabel.text = [NSString stringWithFormat:@"ID # %@",[subject_pool objectForKey:@"id"]];
        info_cell.nameLabel.text = [NSString stringWithFormat:@"%@ - %@", [subject_pool objectForKey:@"class_name"], [subject_pool objectForKey:@"class_number"]];
        info_cell.categoryLabel.text =[NSString stringWithFormat:@"%@", [subject_pool objectForKey:@"description"]];
        
        return info_cell;
        
    }
    
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        //ADD
        [self requestAddSubject];
    }
    if (indexPath.section == 1) {
        subject_pool = [CYFunctionSet stripNulls:[subject_list objectAtIndex:indexPath.item]];
        
        if (self.delegate) {
            [self.delegate subjectSelectionDidPickSubject:[subject_pool objectForKey:@"id"]];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self performSegueWithIdentifier:@"subjectRootToSubjectDetail" sender:self];
            
        }
        
    }
    
}

#pragma mark SEARCH
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""]) {
        // NO SEARCH
        [self requestSubjectList];
    }else{
        [self requestSearchSubjectWithString:searchText];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([searchBar.text isEqualToString:@""]) {
        // NO SEARCH
        [self requestSubjectList];
    }else{
        [self requestSearchSubjectWithString:searchBar.text];
    }
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"subjectRootToSubjectDetail"]){
        SubjectDetailViewController * sdvc = (SubjectDetailViewController *) [segue destinationViewController];
        sdvc.subjectID = [subject_pool objectForKey:@"id"];
    }
    
}


@end
