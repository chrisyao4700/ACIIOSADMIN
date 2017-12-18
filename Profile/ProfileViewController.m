//
//  ProfileViewController.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ProfileViewController.h"
#import "OrderDiscountRootViewController.h"
#import "OrderAddonRootViewController.h"
#import "GradeSubjectRootViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController{
    ACI_CURRENT_USER * defaultUser;
    BOOL passcode_edited;
    UIAlertController * alert;
    CurrentUserManager * userManager;
    UIActivityIndicatorView * loadingView;
    
    NSString * temp_passcode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    defaultUser = [CurrentUserManager getCurrentDispatch];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadTableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 7;
    }
    if (section == 1) {
        temp = 5;
    }
    if (section == 2) {
        temp = 1;
    }
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
        temp = @"USER INFO";
    }
    if (section == 1) {
        temp = @"CAMPUS SETTINGS";
    }
    if (section == 2) {
        temp = @" ";
    }
    return temp;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"profile_cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.section == 0) {
        cell.userInteractionEnabled = YES;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"FIRST NAME:";
            cell.detailTextLabel.text = defaultUser.first_name;
            cell.userInteractionEnabled = NO;
            
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"LAST NAME:";
            cell.detailTextLabel.text = defaultUser.last_name;
            cell.userInteractionEnabled = NO;
            
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"PHONE:";
            cell.detailTextLabel.text = defaultUser.phone;
            cell.userInteractionEnabled = NO;
            
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"EMAIL:";
            cell.detailTextLabel.text = defaultUser.email;
            cell.userInteractionEnabled = NO;
            
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = @"USERNAME:";
            cell.detailTextLabel.text = defaultUser.username;
        }
        if (indexPath.row == 5) {
            cell.textLabel.text = @"PASSWORD:";
            if (passcode_edited == YES) {
                cell.detailTextLabel.text = temp_passcode;
            }else{
                cell.detailTextLabel.text = @"**##**";
            }
            
        }
        if (indexPath.row == 6) {
            cell.textLabel.text= @"MAIN CAMPUS";
            cell.detailTextLabel.text = defaultUser.main_campus_name;
            cell.userInteractionEnabled =NO;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"MANAGE SUBJECTS";
            cell.detailTextLabel.text = @"";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"MANAGE STAFF";
            cell.detailTextLabel.text = @"";
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"MANAGE DISCOUNT";
            cell.detailTextLabel.text = @"";
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"MANAGE ADDON";
            cell.detailTextLabel.text = @"";
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = @"MANAGE STUDENT SUBJECT";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.userInteractionEnabled = YES;
            cell.textLabel.text = @"LOG OUT";
            cell.detailTextLabel.text = @" ";
            cell.backgroundColor = [UIColor redColor];
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performAlertViewTextModifyWithKey:@"first_name" forValue:defaultUser.first_name forCustomerTag:5];
        }
        if (indexPath.row == 1) {
            [self performAlertViewTextModifyWithKey:@"last_name" forValue:defaultUser.last_name forCustomerTag:5];
        }
        if (indexPath.row == 2) {
            [self performAlertViewTextModifyWithKey:@"phone" forValue:defaultUser.phone forCustomerTag:5];
        }
        if (indexPath.row == 3) {
            [self performAlertViewTextModifyWithKey:@"email" forValue:defaultUser.email forCustomerTag:5];
        }
        if (indexPath.row == 4) {
            
            [self performAlertViewTextModifyWithKey:@"username" forValue:defaultUser.username forCustomerTag:5];
        }
        if (indexPath.row == 5) {
            [self performAlertViewTextModifyWithKey:@"password" forValue:@"**##**" forCustomerTag:6];
        }

    }

    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"toSubjects" sender:self];
        }
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"toStaff" sender:self];
        }
        if (indexPath.row == 2) {
            [self performSegueWithIdentifier:@"toDiscount" sender:self];
        }
        if (indexPath.row == 3) {
            [self performSegueWithIdentifier:@"toAddon" sender:self];
        }
        if (indexPath.row == 4) {
            [self performSegueWithIdentifier:@"toGradeSubject" sender:self];
        }
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //[self.navigationController popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
-(void) reloadTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.profileTable reloadData];
    });
}
-(void) performAlertViewTextModifyWithKey:(NSString *) key
                                 forValue:(NSString *) value
                           forCustomerTag:(NSInteger) c_tag{
  
    
    dispatch_async(dispatch_get_main_queue(), ^{
        alert = [UIAlertController
                 alertControllerWithTitle:key
                 message:value
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self reloadTableView];
                                                             }];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             //[locationHandler updateGasPoint];
                                                             NSString * value = [[alert.textFields objectAtIndex:0] text];
                                                             [self didSaveTextForKey:key andValue:value andCustomerTag:c_tag];                                                         }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            //textField.placeholder = @"New information here...";
            textField.text = value;
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
    });
}
-(void) didSaveTextForKey:(NSString *) key
                 andValue:(NSString *) value
           andCustomerTag:(NSInteger) c_tag{
    if (!userManager) {
        userManager = [[CurrentUserManager alloc] initWithDelegate:self];
    }
    if (c_tag == 6) {
        temp_passcode = value;
        value = [CYFunctionSet md5:value];
        passcode_edited = YES;
    }
    
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    [temp addObject:@{
                      @"key" : key,
                      @"value": value}];
    NSDictionary * uploadpack = @{
                                  @"table_name": @"aci_users",
                                  @"element_array":(NSArray *)temp,
                                  @"data_id": defaultUser.data_id
                                  };
    [userManager updateCurrentUserWithPack:uploadpack];
}

-(void) currentUserManagerWillStartRequestWithTag:(NSInteger) tag{
    [self loadingStart];
}
-(void) currentUserManagerDidGetResponseWithTag:(NSInteger) tag{
    [self loadingStop];
}
-(void) currentUserManagerError:(NSString *) messsage
                         forTag:(NSInteger)tag{
    [self showAlertWithTittle:@"Error" forMessage:messsage];
}
-(void) currentUserManagerDidUpdateCurrentUser{
    defaultUser = [CurrentUserManager getCurrentDispatch];
    [self reloadTableView];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toDiscount"]) {
        OrderDiscountRootViewController * odrvc = (OrderDiscountRootViewController *)[segue destinationViewController];
        odrvc.mode = @"MANAGE";
    }
    if ([segue.identifier isEqualToString:@"toAddon"]) {
        OrderAddonRootViewController * oadrvc = (OrderAddonRootViewController *)[segue destinationViewController];
        oadrvc.mode = @"MANAGE";
    }
    if ([segue.identifier isEqualToString:@"toGradeSubject"]) {
        GradeSubjectRootViewController * gsrvc = (GradeSubjectRootViewController *)[segue destinationViewController];
        gsrvc.mode = @"MANAGE";
    }
    
    
    
}


@end
