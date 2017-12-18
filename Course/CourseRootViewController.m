//
//  CourseRootViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CourseRootViewController.h"
#import "CourseRootCollectionViewCell.h"
#import "CurrentUserManager.h"
#import "CourseDetailViewController.h"

@interface CourseRootViewController ()

@end

@implementation CourseRootViewController{
    
    NSArray * course_list;
    NSDictionary * course_pool;
    
    AppDataSocketConnector * connector;
    
    
    ACI_CURRENT_USER * user;
    UIBarButtonItem  *rightItem;
    UIBarButtonItem * leftItem;
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    user = [CurrentUserManager getCurrentDispatch];
    
    [self setNavigationBarString:@"Courses"];
    
    if (![self.mode isEqualToString:@"SELECT"]) {
        self.delegate = nil;
    }
    // Do any additional setup after loading the view.
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightItemDidClick:)];
    leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(leftItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if (!self.delegate) {
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    // Do any additional setup after loading the view.
}
-(IBAction)rightItemDidClick:(id)sender{
    
    if (![self.searchBar.text isEqualToString:@""]) {
        [self requestCourseListWithSearchString: self.searchBar.text];
    }else{
        [self requestCourseList];
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.searchBar.text isEqualToString:@""]) {
        [self requestCourseListWithSearchString: self.searchBar.text];
    }else{
        [self requestCourseList];
    }
}

-(IBAction)leftItemDidClick:(id)sender{
    [self requestAddCourse];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) requestCourseList{
    dispatch_async(dispatch_get_main_queue(), ^{
        course_list = nil;
        NSString * query;
        if (!self.delegate) {
            query= [NSString stringWithFormat:@"SELECT `aci_course`.*, `aci_subject`.`class_name`, `aci_subject`.`class_number`,`aci_subject`.`description` AS `subject_description`,`aci_campus`.`campus_name` FROM `aci_course` LEFT JOIN `aci_subject` ON `aci_subject`.`id` = `aci_course`.`subject_id` LEFT JOIN `aci_campus` ON `aci_campus`.`id` = `aci_course`.`campus_id` WHERE `aci_course`.`course_status_id` IN (1,2) AND `aci_course`.`campus_id` = %@",user.main_campus_id];
        }else{
            query= [NSString stringWithFormat:@"SELECT `aci_course`.*, `aci_subject`.`class_name`, `aci_subject`.`class_number`,`aci_subject`.`description` AS `subject_description`,`aci_campus`.`campus_name` FROM `aci_course` LEFT JOIN `aci_subject` ON `aci_subject`.`id` = `aci_course`.`subject_id` LEFT JOIN `aci_campus` ON `aci_campus`.`id` = `aci_course`.`campus_id` WHERE `aci_course`.`course_status_id` = 2 AND `aci_course`.`campus_id` = %@",user.main_campus_id];
        }
        
        
        NSDictionary * dict = @{
                                @"query":query
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    
    });
}
-(void) requestCourseListWithSearchString:(NSString *) searchStr{
    course_list = nil;
    NSString * query;
    if (!self.delegate) {
        query= [NSString stringWithFormat:@"SELECT `aci_course`.*, `aci_subject`.`class_name`, `aci_subject`.`class_number`,`aci_subject`.`description` AS `subject_description`,`aci_campus`.`campus_name` FROM `aci_course` LEFT JOIN `aci_subject` ON `aci_subject`.`id` = `aci_course`.`subject_id` LEFT JOIN `aci_campus` ON `aci_campus`.`id` = `aci_course`.`campus_id` WHERE `aci_course`.`course_status_id` IN (1,2) AND `aci_course`.`campus_id` = %@ AND (`aci_subject`.`class_name` LIKE '%%%@%%' OR `aci_subject`.`class_number` LIKE '%%%@%%')",user.main_campus_id,searchStr,searchStr];
    }else{
        query= [NSString stringWithFormat:@"SELECT `aci_course`.*, `aci_subject`.`class_name`, `aci_subject`.`class_number`,`aci_subject`.`description` AS `subject_description`,`aci_campus`.`campus_name` FROM `aci_course` LEFT JOIN `aci_subject` ON `aci_subject`.`id` = `aci_course`.`subject_id` LEFT JOIN `aci_campus` ON `aci_campus`.`id` = `aci_course`.`campus_id` WHERE `aci_course`.`course_status_id` = 2 AND `aci_course`.`campus_id` = %@ AND (`aci_subject`.`class_name` LIKE '%%%@%%' OR `aci_subject`.`class_number` LIKE '%%%@%%')",user.main_campus_id,searchStr,searchStr];
    }
    
    
    NSDictionary * dict = @{
                            @"query":query
                            };
    
    [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
}
-(void) requestAddCourse{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict =@{
                               @"table_name":@"aci_course",
                               @"element_array":@[
                                       @{
                                           @"key":@"campus_id",
                                           @"value":user.main_campus_id
                                           },
                                       @{
                                           @"key":@"cdate",
                                           @"value":[CYFunctionSet convertDateToString:[NSDate date]]
                                           },
                                       @{
                                           @"key":@"cby",
                                           @"value":user.data_id
                                           },
                                       @{
                                           @"key":@"course_status_id",
                                           @"value":@"1"
                                           }
                                       ]
                               };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:3];
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
    [self reloadContentTable];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        course_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 2) {
        course_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 3) {
        course_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"courseRootToCourseDetail" sender:self];
        });
    }
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        if (!self.delegate) {
            temp = 1;
        }
    }
    if (section == 1) {
        if (course_list) {
            temp = course_list.count;
        }
    }
    return temp;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell;
    
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"add_cell" forIndexPath:indexPath];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_background"]];
        cell.layer.cornerRadius = 20.0;
    }
    if (indexPath.section == 1) {
        //NORMAL COURSE
        course_pool = [course_list objectAtIndex:indexPath.item];
        CourseRootCollectionViewCell * info_cell = (CourseRootCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"info_cell" forIndexPath:indexPath];
        info_cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_background"]];
        info_cell.layer.cornerRadius = 20.0;
        info_cell.nameLabel.text = [NSString stringWithFormat:@"%@-%@",[course_pool objectForKey:@"class_name"], [course_pool objectForKey:@"class_number"]];
        info_cell.descriptionView.text = [NSString stringWithFormat:@"%@\n$ %@\n%@\n%@\n%@",[course_pool objectForKey:@"subject_description"],[course_pool objectForKey:@"price"],[course_pool objectForKey:@"start_date"],[course_pool objectForKey:@"end_date"],[course_pool objectForKey:@"campus_name"]];
        info_cell.descriptionView.editable = NO;
        
        return info_cell;
    }
    return cell;

}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self requestAddCourse];
        }
    }
    if (indexPath.section == 1) {
        course_pool = [course_list objectAtIndex:indexPath.item];
        if (!self.delegate) {
            [self performSegueWithIdentifier:@"courseRootToCourseDetail" sender:self];
        }else{
            
            [self.delegate courseRootDidSelectCourse:[course_pool objectForKey:@"id"] forPrice:[course_pool objectForKey:@"price"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"courseRootToCourseDetail"]) {
        CourseDetailViewController * cdvc = (CourseDetailViewController *) [segue destinationViewController];
        cdvc.courseID = [course_pool objectForKey:@"id"];
    }
}


@end
