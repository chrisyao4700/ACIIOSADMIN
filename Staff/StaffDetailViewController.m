//
//  StaffDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "StaffDetailViewController.h"
#import "ImageDetailViewController.h"
@interface StaffDetailViewController ()

@end

@implementation StaffDetailViewController{
    NSDictionary * currentStaff;
    
    AppDataSocketConnector * connector;
    NSDictionary * contact_pack;
    NSDictionary * address_pack;
    
    UIAlertController * text_alert;
    
    NSString * key_pool;
    
    ACI_CURRENT_USER * user;
    
    
    UIBarButtonItem * rightItem;
    
    NSNumber * user_category;
    NSNumber * staff_category;
    
    NSArray * category_array;
    NSArray * category_list;
    
    
    DataPickerViewController * dpvc;
    
    NSData * data_container;
    
    
    UIImage * image_pool;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    [self setNavigationBarString:[NSString stringWithFormat:@"USER ID# %@",self.staffID]];
    
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightItemDidClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    
    // Do any additional setup after loading the view.
}
-(IBAction)rightItemDidClick:(id)sender{
    //REFRESH
    //[self configViewData];
    [self requestUpdateRecordForTable:@"aci_users" forDataID:self.staffID forKey:@"user_status_id" forValue:@"2" withTag:11];
}
-(IBAction)didClickImage:(id)sender{
    [self requestImageWithTag:3];
}

-(void) requestImageWithTag:(NSInteger) c_tag{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"file_name":[NSString stringWithFormat:@"staff_%@.png",self.staffID]
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_image" andCustomerTag:c_tag andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            //
            if (![message isEqualToString:@"NO RESULT FOUND"]) {
                [self showAlertWithTittle:@"WARNING" forMessage:message];
            }else{
                //[self reloadContentTableWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            
            if (c_tag == 3) {
                data_container = [[NSData alloc] initWithBase64EncodedString:[resultDict objectForKey:@"record"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                [CurrentUserManager savePhotoToCoredata:data_container forName:[NSString stringWithFormat:@"staff_%@.png",self.staffID]];
                image_pool = [UIImage imageWithData:data_container];
                [self performSegueWithIdentifier:@"toImageDetail" sender:self];
                [self reloadContentTableWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            if (c_tag == 4) {
                data_container = [[NSData alloc] initWithBase64EncodedString:[resultDict objectForKey:@"record"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                [CurrentUserManager savePhotoToCoredata:data_container forName:[NSString stringWithFormat:@"staff_%@.png",self.staffID]];
                //image_pool = [UIImage imageWithData:data_container];
                //[self performSegueWithIdentifier:@"toImageDetail" sender:self];
                [self reloadContentTableWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            
        }];
        
    });


}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!user) {
        user = [CurrentUserManager getCurrentDispatch];
    }
    
    [self requestStaffInfo];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestStaffInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        currentStaff = nil;
        contact_pack = nil;
        address_pack = nil;
        
        NSDictionary * dict = @{
                                @"id": self.staffID
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"select_staff" andCustomerTag:1 andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            currentStaff = [CYFunctionSet stripNulls:[resultDict objectForKey:@"user"]];
            
            user_category = [CYFunctionSet convertStingToNumber:user.category_id];
            staff_category = [CYFunctionSet convertStingToNumber:[currentStaff objectForKey:@"user_category_id"]];
            
            contact_pack = [CYFunctionSet stripNulls:[resultDict objectForKey:@"contact"]];
            address_pack = [CYFunctionSet stripNulls:[resultDict objectForKey:@"address"]];
            [self reloadContentTable];
        }];
    });
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
                [self requestStaffInfo];
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
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        //ID
        temp = 1;
    }
    if (section == 1) {
        //LOG IN INFO
        temp = 3;
    }
    if (section == 2) {
        //CONTACT INFO
        temp = 5;
    }
    if (section == 3) {
        //ADDRESS INFO
        temp = 6;
    }
    if (section == 4) {
        //ACTIONS
        temp = 1;
    }
    
    return temp;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
        temp = @"STAFF";
    }
    if (section == 1) {
        temp = @"LOG IN";
    }
    if (section == 2) {
        temp = @"CONTACT INFO";
    }
    if (section == 3) {
        temp = @"ADDRESS INFO";
    }
    if (section == 4) {
        temp = @" ";
    }
    return temp;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat temp = 65.0;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        temp = 100.0;
    }
    return temp;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"id_cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        if (indexPath.row == 0) {
            data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"staff_%@.png", self.staffID]];
            if (data_container) {
                cell.imageView.image = [UIImage imageWithData:data_container];
                
            }else{
                [self requestImageWithTag:4];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"ID # %@", self.staffID];
            cell.imageView.userInteractionEnabled =YES;
            UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickImage:)];
            tapped.numberOfTapsRequired = 1;
            [cell.imageView addGestureRecognizer:tapped];
        }
        
    }
    
    if (indexPath.section != 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
    }
    if (indexPath.section == 1) {
        //LOG IN INFO
        if (indexPath.row == 0) {
            cell.textLabel.text = @"USERNAME:";
            cell.detailTextLabel.text = [currentStaff objectForKey:@"username"];
            
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"PASSWORD:";
          cell.detailTextLabel.text = @"****";
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"USER CATEGORY";
            cell.detailTextLabel.text = [currentStaff objectForKey:@"user_category_str"];
        }
        
    }
    if (indexPath.section == 2) {
        //CONTACT INFO
        switch (indexPath.row) {
            case 0:
                key_pool = @"first_name";
                break;
            case 1:
                key_pool = @"last_name";
                break;
            case 2:
                key_pool = @"phone";
                break;
            case 3:
                key_pool = @"email";
                break;
            case 4:
                key_pool = @"emergency_phone";
                break;
            default:
                break;
        }

        cell.textLabel.text = [NSString stringWithFormat:@"%@:",[key_pool.uppercaseString stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
        cell.detailTextLabel.text = [contact_pack objectForKey:key_pool];
    }
    if (indexPath.section == 3) {
        //ADDRESS INFO
        
        switch (indexPath.row) {
            case 0:
                key_pool = @"street_frist_line";
                break;
            case 1:
                key_pool = @"street_second_line";
                break;
            case 2:
                key_pool = @"zipcode";
                break;
            case 3:
                key_pool = @"city";
                break;
            case 4:
                key_pool = @"state";
                break;
            case 5:
                key_pool = @"country";
                break;
            default:
                break;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@:",[key_pool.uppercaseString stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
        cell.detailTextLabel.text = [address_pack objectForKey:key_pool];
    }
    
    if (indexPath.section == 4) {
        cell.textLabel.text = [NSString stringWithFormat:@"DELETE"];
        cell.detailTextLabel.text = @"";
        cell.backgroundColor = [UIColor redColor];
    }
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (staff_category.integerValue > user_category.integerValue || user_category.integerValue == 0) {
        if (indexPath.section == 0) {
            //ID;
            [self performGetPictureFromCamera];
            
        }
        if (indexPath.section == 1) {
            //LOG IN
            if (indexPath.row != 2) {
                switch (indexPath.row) {
                    case 0:
                        key_pool = @"username";
                        break;
                    case 1:
                        key_pool = @"password";
                        break;
                        
                    default:
                        break;
                }
                [self performAlertViewTextModifyWithKey:key_pool forValue:[currentStaff objectForKey:key_pool] forTableName:@"aci_users" forDataID:self.staffID];
                
            }
            if (indexPath.row == 2) {
                //CATEGORY
                
                if (category_list) {
                    [self performDataPickerForKey:@"user_category_id" forDatasource:category_list forOrgIndex:staff_category.integerValue];
                }else{
                    [self requestCategoryArray];
                }
            }
        }
        if (indexPath.section == 2) {
            //CONTACT
            switch (indexPath.row) {
                case 0:
                    key_pool = @"first_name";
                    break;
                case 1:
                    key_pool = @"last_name";
                    break;
                case 2:
                    key_pool = @"phone";
                    break;
                case 3:
                    key_pool = @"email";
                    break;
                case 4:
                    key_pool = @"emergency_phone";
                    break;
                default:
                    break;
            }
            [self performAlertViewTextModifyWithKey:key_pool forValue:[contact_pack objectForKey:key_pool] forTableName:@"aci_contact" forDataID:[contact_pack objectForKey:@"id"]];
        }
        if (indexPath.section == 3) {
            //ADDRESS
            switch (indexPath.row) {
                case 0:
                    key_pool = @"street_frist_line";
                    break;
                case 1:
                    key_pool = @"street_second_line";
                    break;
                case 2:
                    key_pool = @"zipcode";
                    break;
                case 3:
                    key_pool = @"city";
                    break;
                case 4:
                    key_pool = @"state";
                    break;
                case 5:
                    key_pool = @"country";
                    break;
                default:
                    break;
            }
            [self performAlertViewTextModifyWithKey:key_pool forValue:[address_pack objectForKey:key_pool] forTableName:@"aci_contact_address" forDataID:[address_pack objectForKey:@"id"]];
            
        }
        if (indexPath.section == 4) {
            //action
            if (indexPath.row == 0) {
                if ([self.staffID isEqualToString:@"0"]) {
                    [self showAlertWithTittle:@"ERROR" forMessage:@"YOU CANNOT DELETE ROOT USER"];
                }else{
                    
                    [self requestUpdateRecordForTable:@"aci_users" forDataID:self.staffID forKey:@"user_status_id" forValue:@"0" withTag:11];
                }
                
            }
        }

    }else{
        [self showAlertWithTittle:@"ERROR" forMessage:@"YOU DON'T HAVE AUTHORITY TO MODIFY THIS USER"];
    }
    
}
-(void) performAlertViewTextModifyWithKey:(NSString *) key
                                 forValue:(NSString *) value
                             forTableName:(NSString *) table_name
                                forDataID:(NSString *) data_id{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        text_alert = [UIAlertController
                      alertControllerWithTitle:key
                      message:value
                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self reloadContentTable];
                                                             }];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             //[locationHandler updateGasPoint];
                                                             NSString * value = [[text_alert.textFields objectAtIndex:0] text];
                                                             [self didSaveTextForKey:key
                                                                            andValue:value
                                                                        forTableName: table_name
                                                                           forDataID: data_id];                                                         }];
        
        [text_alert addAction:okAction];
        [text_alert addAction:cancelAction];
        [text_alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            //textField.placeholder = @"New information here...";
            textField.text = value;
            
        }];
        [self presentViewController:text_alert animated:YES completion:nil];
    });
}
-(void) didSaveTextForKey:(NSString *) key
                 andValue:(NSString *) value
             forTableName:(NSString *) table_name
                forDataID:(NSString *) data_id{
    NSString * f_value = value;
    if ([key isEqualToString:@"password"]) {
        f_value = [CYFunctionSet md5:value];
    }
    [self requestUpdateRecordForTable:table_name forDataID:data_id forKey:key forValue:f_value withTag:2];
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

-(void) performGetPictureFromCamera{
    
    if (! [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        [self showAlertWithTittle:@"Error" forMessage:@"CAMERA NOT ALLOWED"];
    } else {
        
        UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
        //cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        //cameraPicker.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.0);
        cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraPicker.showsCameraControls = YES;
        cameraPicker.delegate =self;
        // Show image picker
        [self presentViewController:cameraPicker animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //self.imageView.image = chosenImage;
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:chosenImage];
    imageCropVC.delegate = self;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController pushViewController:imageCropVC animated:YES];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.imageView.image= croppedImage;
        //image_pool = croppedImage;
        [CurrentUserManager savePhotoToCoredata:UIImagePNGRepresentation(croppedImage) forName:[NSString stringWithFormat:@"staff_%@.png",self.staffID]];
        
        [connector sendImageUploadRequestWithImage:croppedImage andCustomerTag:5 forFileName:[NSString stringWithFormat:@"staff_%@.png",self.staffID] andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            
            [self reloadContentTable];
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.imageView.image= croppedImage;NSData *imageData = ;
        //image_pool = croppedImage;
        [CurrentUserManager savePhotoToCoredata:UIImagePNGRepresentation(croppedImage) forName:[NSString stringWithFormat:@"staff_%@.png",self.staffID]];
        
        [connector sendImageUploadRequestWithImage:croppedImage andCustomerTag:5 forFileName:[NSString stringWithFormat:@"staff_%@.png",self.staffID] andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            
            [self reloadContentTable];
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    });}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage
{
    // Use when `applyMaskToCroppedImage` set to YES.
    //[SVProgressHUD show];
}


#pragma mark CONNECTOR
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    [self showAlertWithTittle:@"ERROR" forMessage:message];
}
-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{

    if (c_tag == 2) {
        [self requestStaffInfo];
    }
    if (c_tag == 4) {
        category_array = [resultDic objectForKey:@"records"];
        [self prepareCategoryList];
    }
    
}


#pragma mark CATEGORY

-(void) requestCategoryArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        category_array = nil;
        
        NSDictionary * dict = @{
                                @"table_name" : @"aci_user_category",
                                @"result_order": @"`id` ASC"
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:4];
    });
}
-(void) prepareCategoryList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in category_array) {
        [temp addObject:[dict objectForKey:@"user_category"]];
    }
    category_list = (NSArray *) temp;
    [self performDataPickerForKey:@"user_category_id" forDatasource:category_list forOrgIndex:staff_category.integerValue];
}
-(void) performDataPickerForKey:(NSString *) key
                  forDatasource:(NSArray *)datasource
                    forOrgIndex:(NSInteger) orgIndex{

    if (!dpvc) {
        dpvc = [[DataPickerViewController alloc] init];
    }
    dpvc.key = key;
    dpvc.dataSource = datasource;
    dpvc.delegate = self;
    dpvc.orgIndex = orgIndex;
    
    dispatch_async(dispatch_get_main_queue(), ^{
     [self showDetailViewController:dpvc sender:self];
    });
    
    
}
-(void)didCancelPickingDataForKey:(NSString *)key{
    [self reloadContentTable];
}
-(void)didSavePickedDataForKey:(NSString *)key andIndex:(NSInteger)index{
    
    if (user_category.integerValue < index) {
        if (staff_category.integerValue == 0 && index != 0) {
            [self showAlertWithTittle:@"ERROR" forMessage:@"YOU CANNOT REMOVE A ROOT USER"];
        }else{
            [self requestUpdateRecordForTable:@"aci_users" forDataID:self.staffID forKey:key forValue:[NSString stringWithFormat:@"%ld",(long)index] withTag:2];

        }
           }else{
        [self showAlertWithTittle:@"ERROR" forMessage:@"YOU DON'T HAVE AUTHORITY TO DO THIS"];
    }
    
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"toImageDetail"]) {
         ImageDetailViewController * imdvc = (ImageDetailViewController *)[segue destinationViewController];
         imdvc.image = image_pool;
     }
     
 }


@end
