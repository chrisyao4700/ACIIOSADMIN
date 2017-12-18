//
//  ParentDisplayViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ParentDisplayViewController.h"
#import "ParentDetailViewController.h"

@interface ParentDisplayViewController ()

@end

@implementation ParentDisplayViewController{
    
    NSString * relation_id_pool;
    NSString * parent_id_pool;
    
    NSArray * relation_parent_list;
    NSDictionary * relation_parent_pool;
    
    NSDictionary * parent_data_pool;
    
    NSData * data_container;
    
    ACI_CURRENT_USER * user;
    
    AppDataSocketConnector * connector;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    user = [CurrentUserManager getCurrentDispatch];
    [self configBackgroundView];
    [self setNavigationBarString:@"PARENTS"];
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.mode isEqualToString:@"STUDENT"]) {
        [self requestSearchParentStudentWithStudent:self.data_id];
    }
    
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
            if (c_tag == 2) {
                if ([self.mode isEqualToString:@"STUDENT"]) {
                    [self requestSearchParentStudentWithStudent:self.data_id];
                }
                
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



-(void) requestSearchParentStudentWithStudent:(NSString *) studentID{
    dispatch_async(dispatch_get_main_queue(), ^{
        relation_parent_list = nil;
        NSDictionary * dict = @{
                                @"student_id":studentID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_ps_student" andCustomerTag:1];
    });
}


-(void) requestInsertParentStudentRelationWith:(NSString *) studentID
                         forParent:(NSString *) parentID{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary * dict = @{
                                
                                @"parent_id":parentID,
                                @"student_id":studentID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_ps_relation" andCustomerTag:3];
    });
}

-(void) requestInsertParentWithStudent:(NSString *) studentID
                             {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary * dict = @{
                                @"student_id":studentID,
                                @"cby":user.data_id,
                                @"cdate":[CYFunctionSet convertDateToConstantString:[NSDate date]]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_parent" andCustomerTag:4];
    });

}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 2;
    }
    if (section == 1) {
        if (relation_parent_list) {
            temp = relation_parent_list.count;
        }
    }
    return temp;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell ;
    
    if (indexPath.section == 0) {
        //ADD
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"action_cell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ADD NEW PARENT";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"LINK PARENT";
        }
        
        
        
    }
    if (indexPath.section == 1) {
        //NORMAL LIST ITEM
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        relation_parent_pool = [CYFunctionSet stripNulls:[relation_parent_list objectAtIndex:indexPath.row]];
        cell.textLabel.text = [NSString stringWithFormat:@"PARENT ID # %@", [relation_parent_pool objectForKey:@"parent_id"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@",[relation_parent_pool objectForKey:@"parent_name"],[relation_parent_pool objectForKey:@"phone"]];
        
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self requestInsertParentWithStudent:self.data_id];
        }
        if (indexPath.row == 1) {
            //ADD STUDENT
            [self performSegueWithIdentifier:@"parentDisplayToParentSelect" sender:self];
        }
    }
    if (indexPath.section == 1) {
        relation_parent_pool = [CYFunctionSet stripNulls:[relation_parent_list objectAtIndex:indexPath.row]];
        relation_id_pool = [relation_parent_pool objectForKey:@"id"];
        parent_id_pool = [relation_parent_pool objectForKey:@"parent_id"];
        [self performSegueWithIdentifier:@"toAction" sender:self];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //CGFloat temp = 60;
    return 65;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    
    if (section == 0) {
        temp = @" ";
    }
    if (section == 1) {
        temp = @"PARENT(S)";
    }
    return temp;
}
-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
    
    
}
-(void) actionControllerDidClickViewDetail:(NSString *) relation_id
                                 forParent:(NSString *) parent_id{
    dispatch_async(dispatch_get_main_queue(), ^{
        relation_id_pool = relation_id;
        parent_id_pool = parent_id;
        [self performSegueWithIdentifier:@"parentDisplayToParentDetail" sender:self];
    });
}
-(void) actionControllerDidClickRemove:(NSString *) relation_id
                             forParent:(NSString *) parent_id{
    [self requestUpdateRecordForTable:@"aci_parent_student" forDataID:relation_id forKey:@"status" forValue:@"0" withTag:2];
}
-(void) actionControllerDidClickCancel{
    [self reloadContentTable];
}



-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        [self showAlertWithTittle:@"ERROR" forMessage:message];
        
    }
    [self reloadContentTable];
    
}
-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        relation_parent_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    
    if (c_tag == 3) {
        if ([self.mode isEqualToString:@"STUDENT"]) {
            [self requestSearchParentStudentWithStudent:self.data_id];
        }
    }
    if (c_tag == 4) {
        parent_data_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"parent"]];
        parent_id_pool =[parent_data_pool objectForKey:@"id"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"parentDisplayToParentDetail" sender:self];
        });
    }
}
-(void)parentSelectionDidSelctParent:(NSString *)parentID{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestInsertParentStudentRelationWith:self.data_id forParent:parentID];
    });
}
-(NSArray *) prepareBanlist{
    if (relation_parent_list) {
        NSMutableArray * temp = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in relation_parent_list) {
            [temp addObject:[dict objectForKey:@"parent_id"]];
        }
        return (NSArray *) temp;
    }
    return nil;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"parentDisplayToParentDetail"]) {
        ParentDetailViewController * pdvc = (ParentDetailViewController *)[segue destinationViewController];
        pdvc.parentID = parent_id_pool;
    }
    if ([segue.identifier isEqualToString:@"parentDisplayToParentSelect"]) {
        ParentSelectionViewController * psvc = (ParentSelectionViewController *) [segue destinationViewController];
        psvc.delegate = self;
        psvc.mode = @"SELECT";
        psvc.ban_list = [self prepareBanlist];
    }
    if ([segue.identifier isEqualToString:@"toAction"]) {
        ParentActionViewController * pavc = (ParentActionViewController *)[segue destinationViewController];
        pavc.delegate = self;
        pavc.parent_id = parent_id_pool;
        pavc.relation_id = relation_id_pool;
        
    }
    
}

@end
