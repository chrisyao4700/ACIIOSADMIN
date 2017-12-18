//
//  GradeRecordDisplayViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "GradeRecordDisplayViewController.h"
#import "GradeRecordCollectionViewCell.h"
#import "GradeRecordDetailViewController.h"
@interface GradeRecordDisplayViewController ()

@end

@implementation GradeRecordDisplayViewController{
    AppDataSocketConnector * connector;
    UIAlertController * text_alert;
    
    ACI_CURRENT_USER * user;
    
    UIBarButtonItem * rightItem;
    
    
    NSArray * record_list;
    NSDictionary * record_pool;
    NSArray * detail_list;
    NSMutableString * info_pool;
    
    NSIndexPath * indexPathPool;
    
    
    
    
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
    [self requestGradeList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestGradeList];
    
}
-(void) requestUpdateRecordForTable:(NSString *) table_name
                          forDataID:(NSString *) data_id
                             forKey:(NSString *) key
                           forValue:(NSString *) value
                            withTag:(NSInteger) c_tag{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        NSArray * elements = @[
                               @{
                                   @"key" : key,
                                   @"value": value
                                   }
                               ];
        NSDictionary * dict = @{
                                @"table_name":table_name,
                                @"data_id":data_id,
                                @"element_array":elements
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"update_record" andCustomerTag:c_tag andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            //[self requestStaffInfo];
            if (c_tag == 2) {
                //[self requestClassDetailData:self.classID];
                [self requestGradeList];
            }
            
            if (c_tag == 11) {
                //ACTIVE
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                    
                });
                
            }
        }];
        
        
    });
}
-(void) requestGradeList{
    dispatch_async(dispatch_get_main_queue(), ^{
        record_list = nil;
        NSDictionary * dict = @{
                              @"student_id":self.studentID,
                              @"campus_id":user.main_campus_id
                              };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_grade" andCustomerTag:1];
    });
}
-(void) requestInsertGradeRecord{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"cby":user.data_id,
                                @"campus_id":user.main_campus_id,
                                @"student_id":self.studentID,
                                @"cdate":[CYFunctionSet getCurrentFormatString]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_grade" andCustomerTag:3];
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
        temp = record_list?record_list.count:0;
    }
    return temp;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GradeRecordCollectionViewCell * cell;
    if (indexPath.section == 0) {
        cell = ( GradeRecordCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"add_cell" forIndexPath:indexPath];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subject_bk_2"]];
        cell.layer.cornerRadius = 20.0;
    }
    if (indexPath.section == 1) {
        record_pool = [CYFunctionSet stripNulls:[record_list objectAtIndex:indexPath.item]];
        cell = (GradeRecordCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"info_cell" forIndexPath:indexPath];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subject_bk_2"]];
        cell.layer.cornerRadius = 20.0;
        cell.gradeLabel.text = [NSString stringWithFormat:@"GRADE %@", [record_pool objectForKey:@"grade"]];
        detail_list = [record_pool objectForKey:@"detail_list"];
        info_pool = [[NSMutableString alloc] init];
        for (NSDictionary * detailItem in detail_list) {
            [info_pool appendFormat:@"%@: %@\n",[detailItem objectForKey:@"grade_subject_str"],[detailItem objectForKey:@"grade_score_str"]];
        }
        cell.infoTextView.text = (NSString *)info_pool;
        
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [self requestInsertGradeRecord];
    }
    if (indexPath.section == 1) {
        //record_pool = [CYFunctionSet stripNulls:[record_list objectAtIndex:indexPath.item]];
        indexPathPool = indexPath;
        [self performSegueWithIdentifier:@"toAction" sender:self];
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
        record_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 3) {
        record_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"toDetail" sender:self];
        });
    }
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toDetail"]) {
        GradeRecordDetailViewController * grdvc = (GradeRecordDetailViewController *)[segue destinationViewController];
        grdvc.gradeRecordID = [record_pool objectForKey:@"id"];
    }
    if ([segue.identifier isEqualToString:@"toAction"]) {
        CYMultiActionViewController * cymavc = (CYMultiActionViewController *)[segue destinationViewController];
        cymavc.indexPath = indexPathPool;
        cymavc.delegate = self;
    }
}

-(void)cyMultiActionRequestDelete:(NSIndexPath *)indexPath{
    
    [self confirmActionForTitle:@"WARNING" forMessage:[NSString stringWithFormat:@"DELETE SCORE RECORD GRADE %@ ?",[record_pool objectForKey:@"grade"]] forConfirmationHandler:^(UIAlertAction * action){
        [self requestUpdateRecordForTable:@"aci_grade_record" forDataID:[record_pool objectForKey:@"id"] forKey:@"status" forValue:@"0" withTag:2];
    }];
}
-(void)cyMultiActionRequestCancel:(NSIndexPath *)indexPath{
    [self reloadContentTable];
    
}
-(void)cyMultiActionRequestDetail:(NSIndexPath *)indexPath{
    record_pool = [CYFunctionSet stripNulls:[record_list objectAtIndex:indexPath.item]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"toDetail" sender:self];
    });
    
}
@end
