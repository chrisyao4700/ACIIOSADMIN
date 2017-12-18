//
//  WeekItemDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "WeekItemDetailViewController.h"

@interface WeekItemDetailViewController ()

@end

@implementation WeekItemDetailViewController{
    NSDictionary * courseItem_pack;
    
    
    DataPickerViewController * dpvc;
    
    
    AppDataSocketConnector * connector;
    
    UIBarButtonItem * rightItem;
    NSNumber * num_pool;
    
    NSString * key_pool;
    NSDate * date_pool;
    NSInteger tag_pool;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestCourseItemDetailData];
    
}
-(void) requestCourseItemDetailData{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * query = [NSString stringWithFormat:@"SELECT `aci_course_item`.*, CONCAT(`aci_contact`.`first_name`, ' ', `aci_contact`.`last_name`) AS `creator_name` FROM `aci_course_item` LEFT JOIN `aci_users` ON `aci_users`.`id` = `aci_course_item`.`cby` LEFT JOIN `aci_contact` ON `aci_contact`.`id` = `aci_users`.`contact_id` WHERE `aci_course_item`.`id` = %@",self.courseItemID];
        NSDictionary * dict = @{
                                @"query":query
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:1 andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            if (c_tag == 1) {
                courseItem_pack = [CYFunctionSet stripNulls:[resultDict objectForKey:@"record"]];
                [self reloadContentTable];
            }
        }];
    });
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
-(void) requestUpdateRecordForTable:(NSString *) table_name
                          forDataID:(NSString *) data_id
                             forKey:(NSString *) key
                           forValue:(NSString *) value
                            withTag:(NSInteger) c_tag{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
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
            if (c_tag == 11) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }
            if (c_tag == 2) {
                [self requestCourseItemDetailData];
            }
        }];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self configBackgroundView];
    // Do any additional setup after loading the view.
}
-(IBAction)rightItemDidClick:(id)sender{
    [self requestUpdateRecordForTable:@"aci_course_item" forDataID:self.courseItemID forKey:@"status" forValue:@"1" withTag:11];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (courseItem_pack) {
        return 2;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 4;
    }
    if (section == 1) {
        temp = 1;
    }
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    
    if (section == 0) {
        temp = @"BASIC INFO";
    }
    if (section == 1) {
        temp = @"ACTIONS";
    }
    
    return temp;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    
    cell.userInteractionEnabled = YES;
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        //BASIC
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"ID # %@",self.courseItemID];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"CREATED BY: %@ -- %@",[courseItem_pack objectForKey:@"creator_name"],[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[courseItem_pack objectForKey:@"cdate"]]]];
            //cell.backgroundColor = [UIColor grayColor];
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (indexPath.row == 1) {
            //WEEK DAY
            cell.textLabel.text =@"WEEK DAY";
            num_pool = [CYFunctionSet convertStingToNumber:[courseItem_pack objectForKey:@"weekday"]];
            cell.detailTextLabel.text = [CYFunctionSet getWeekdayStringWithNumber:num_pool.integerValue];
        }
        if (indexPath.row == 2) {
            //START DATE
            cell.textLabel.text =  @"START TIME";
            cell.detailTextLabel.text =  [CYFunctionSet convertDateToTimeString:[CYFunctionSet convertStringToDate:[courseItem_pack objectForKey:@"start_time"]]];
        }
        if (indexPath.row == 3) {
            //END DATE
            cell.textLabel.text =  @"END TIME";
            cell.detailTextLabel.text =  [CYFunctionSet convertDateToTimeString:[CYFunctionSet convertStringToDate:[courseItem_pack objectForKey:@"end_time"]]];
        }
    }
    if (indexPath.section == 1) {
        //DELETE
        if (indexPath.row == 0) {
            cell.textLabel.text = @"DELETE";
            cell.detailTextLabel.text = @"";
            cell.backgroundColor = [UIColor redColor];
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 1) {
            //WEEK DAY
            key_pool = @"weekday";
            tag_pool = 2;
            [self performDataPicker];
        }
        if (indexPath.row == 2) {
            key_pool = @"start_time";
            tag_pool = 2;
            [self performSegueWithIdentifier:@"toTimePicker" sender:self];
        }
        if (indexPath.row == 3) {
            key_pool = @"end_time";
            tag_pool = 2;
            [self performSegueWithIdentifier:@"toTimePicker" sender:self];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //DELETE
            [self requestUpdateRecordForTable:@"aci_course_item" forDataID:self.courseItemID forKey:@"status" forValue:@"0" withTag:11];
        }
    }
}

-(void)cyTimePickerDidCancelForKey:(NSString *)key forTag:(NSInteger)c_tag{
    [self reloadContentTable];
}
-(void) cyTimePickerDidSaveDate:(NSDate *)date forKey:(NSString *)key forTag:(NSInteger)c_tag{
    [self requestUpdateRecordForTable:@"aci_course_item" forDataID:self.courseItemID forKey:key forValue:[CYFunctionSet convertDateToString:date] withTag:c_tag];
}

-(void) performDataPicker{
    if (!dpvc) {
        dpvc = [[DataPickerViewController alloc]init];
    }
    dpvc.delegate = self;
    dpvc.key = key_pool;
    dpvc.dataSource = [CYFunctionSet getWeekDayArray];
    num_pool = [CYFunctionSet convertStingToNumber:[courseItem_pack objectForKey:key_pool]];
    dpvc.orgIndex= num_pool.intValue;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showDetailViewController:dpvc sender:self];
    });
}
-(void)didCancelPickingDataForKey:(NSString *)key{
    [self reloadContentTable];
}
-(void) didSavePickedDataForKey:(NSString *)key andIndex:(NSInteger)index{
    [self requestUpdateRecordForTable:@"aci_course_item" forDataID:self.courseItemID forKey:key forValue:[NSString stringWithFormat:@"%ld",(long)index] withTag:tag_pool];
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toTimePicker"]) {
        CYTimePickerViewController * cytpc = (CYTimePickerViewController *)[segue destinationViewController];
        cytpc.key = key_pool;
        cytpc.org_date = [CYFunctionSet convertStringToDate:[courseItem_pack objectForKey:key_pool]];
        cytpc.delegate = self;
        cytpc.c_tag = tag_pool;
    }
}


@end
