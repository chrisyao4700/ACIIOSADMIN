//
//  StudentRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "StudentRootViewController.h"
#import "StudentRootCollectionViewCell.h"
#import "StudentDetailViewController.h"
@interface StudentRootViewController ()

@end

@implementation StudentRootViewController{
    AppDataSocketConnector * connector;
    
    NSArray * student_list;
    
    
    NSData * data_container;
    NSMutableDictionary * image_pool;
    
    NSDictionary * person_pool;
    
    UIBarButtonItem * leftItem;
    UIBarButtonItem * rightItem;
    
    ACI_CURRENT_USER * user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarString:@"Students"];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    [self configLoadingView];
    //self.searchBar.userInteractionEnabled = NO;
    image_pool = [[NSMutableDictionary alloc] init];
    // Do any additional setup after loading the view.
    
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightItemDidClick:)];
    leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(leftItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    user = [CurrentUserManager getCurrentDispatch];
    NSNumber * num = [CYFunctionSet convertStingToNumber:user.category_id];
    if (num.integerValue < 3) {
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(IBAction)leftItemDidClick:(id)sender{
    //ADD NEW STUDENT
    [self requestAddStudent];
}
-(IBAction)rightItemDidClick:(id)sender{
    //REFRESH
    [self requestStudentData];
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self requestStudentData];
    NSString * searchText = self.searchBar.text;
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestStudentDataWithSearchStr:searchText];
    }else{
        [self requestStudentData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestStudentData{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_student`.`id`, `aci_student`.`birthday`,`aci_student`.`student_category_id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_student_category`.`student_category` AS `student_category_str`,`aci_student_status`.`student_status` AS `student_status_str` FROM `aci_student` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_student`.`contact_id` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_student`.`student_category_id` LEFT JOIN `aci_student_status` ON `aci_student_status`.`id` = `aci_student`.`student_status_id` WHERE `aci_student`.`student_status_id` != 0 ORDER BY `aci_student`.`id` DESC LIMIT 100"];
        
        NSDictionary * dict =@{
                               @"query" : query
                               };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
        
    });
}
-(void) requestStudentDataWithSearchStr:(NSString *) searchStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_student`.`id`, `aci_student`.`birthday`,`aci_student`.`student_category_id`, `aci_contact`.`first_name`, `aci_contact`.`last_name`, `aci_student_category`.`student_category` AS `student_category_str`,`aci_student_status`.`student_status` AS `student_status_str` FROM `aci_student` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_student`.`contact_id` LEFT JOIN `aci_student_category` ON `aci_student_category`.`id` = `aci_student`.`student_category_id` LEFT JOIN `aci_student_status` ON `aci_student_status`.`id` = `aci_student`.`student_status_id` WHERE `aci_student`.`student_status_id` != 0 AND (CONCAT(`aci_contact`.`first_name`,' ', `aci_contact`.`last_name`) LIKE '%%%@%%' OR `aci_contact`.`first_name` LIKE '%%%@%%' OR `aci_contact`.`last_name` LIKE '%%%@%%' ) ORDER BY `aci_student`.`id` DESC LIMIT 20",searchStr,searchStr,searchStr];
        
        NSDictionary * dict =@{
                               @"query" : query
                               };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
        
    });
}
-(void) requestAddStudent{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{};
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_student" andCustomerTag:4];
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
            }else{
                [image_pool setObject: [UIImage imageNamed:@"NO_RESULT_FOUND"] forKey:[NSString stringWithFormat:@"student_%@.png",student_id]];
                [self reloadContentTableWithIndexPath:indexPath];
            }
            
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            [image_pool setObject: [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:[resultDict objectForKey:@"record"] options:NSDataBase64DecodingIgnoreUnknownCharacters]] forKey:[NSString stringWithFormat:@"student_%@.png",student_id]];
            
            [CurrentUserManager savePhotoToCoredata:[[NSData alloc] initWithBase64EncodedString:[resultDict objectForKey:@"record"] options:NSDataBase64DecodingIgnoreUnknownCharacters] forName:[NSString stringWithFormat:@"student_%@.png",student_id]];
            
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
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        student_list = [resultDic objectForKey:@"records"];
        for (NSDictionary * dict in student_list) {
            data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"student_%@.png",[dict objectForKey:@"id"]]];
            if (data_container) {
                [image_pool setObject:[UIImage imageWithData:data_container] forKey:[NSString stringWithFormat:@"student_%@.png",[dict objectForKey:@"id"]]];
            }
        }
        [self reloadContentTable];
        
    }
    if (c_tag == 2) {
        student_list = [resultDic objectForKey:@"records"];
        for (NSDictionary * dict in student_list) {
            data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"student_%@.png",[dict objectForKey:@"id"]]];
            if (data_container) {
                [image_pool setObject:[UIImage imageWithData:data_container] forKey:[NSString stringWithFormat:@"student_%@.png",[dict objectForKey:@"id"]]];
            }
        }
        [self reloadContentTable];
    }
    if (c_tag == 4) {
        dispatch_async(dispatch_get_main_queue(), ^{
            person_pool = [resultDic objectForKey:@"record"];
            [self performSegueWithIdentifier:@"studentRootToStudentDetail" sender:self];
        });
        
    }
    
}
#pragma mark COLLECTION
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (student_list) {
        temp = student_list.count;
    }
    return temp;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    StudentRootCollectionViewCell * cell = (StudentRootCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"student_background"]];
    cell.layer.cornerRadius = 20.0;
    person_pool = [CYFunctionSet stripNulls:[student_list objectAtIndex:indexPath.item]];
    cell.idLabel.text = [NSString stringWithFormat:@"ID # %@", [person_pool objectForKey:@"id"]];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [person_pool objectForKey:@"first_name"],[person_pool objectForKey:@"last_name"]];
    cell.categoryLabel.text = [NSString stringWithFormat:@"%@", [person_pool objectForKey:@"student_category_str"]];
    cell.statusLabel.text = [NSString stringWithFormat:@"%@", [person_pool objectForKey:@"student_status_str"]];
    cell.birthLabel.text = [NSString stringWithFormat:@"%@",[person_pool objectForKey:@"birthday"]];
    if ([image_pool objectForKey:[NSString stringWithFormat:@"student_%@.png",[person_pool objectForKey:@"id"]]]) {
        cell.studentImage.image = [image_pool objectForKey:[NSString stringWithFormat:@"student_%@.png",[person_pool objectForKey:@"id"]]];
    }else{
        [self requestImageAtIndexPath:indexPath andStudentID:[person_pool objectForKey:@"id"]];
    }
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    person_pool = [CYFunctionSet stripNulls:[student_list objectAtIndex:indexPath.item]];
    
    [self performSegueWithIdentifier:@"studentRootToStudentDetail" sender:self];
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


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestStudentDataWithSearchStr:searchText];
    }else{
        [self requestStudentData];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    NSString * searchText = searchBar.text;
    if (![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && ![searchText isEqualToString:@""]) {
        [self requestStudentDataWithSearchStr:searchText];
    }else{
        [self requestStudentData];
    }

}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    StudentDetailViewController * sdvc = (StudentDetailViewController *) [segue destinationViewController];
    sdvc.studentID = [person_pool objectForKey:@"id"];
}


@end
