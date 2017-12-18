//
//  StudentDetailViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "StudentDetailViewController.h"
#import "ImageDetailViewController.h"
#import "ParentDisplayViewController.h"
#import "GradeRecordDisplayViewController.h"
@interface StudentDetailViewController ()

@end

@implementation StudentDetailViewController{
    UIBarButtonItem * rightItem;
    
    
    NSDictionary * student_pack;
    NSDictionary * contact_pack;
    NSDictionary * address_pack;
    
    NSArray * status_list;
    NSArray * statusArray;
    
    NSArray * category_list;
    NSArray * categoryArray;
    
    AppDataSocketConnector * connector;
    
    UIAlertController * text_alert;
    DataPickerViewController * dpvc;
    DatePickerViewController * dtvc;
    NSData * data_container;
    NSString * key_pool;
    
    
    UIImage * image_pool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    [self setNavigationBarString:[NSString stringWithFormat:@"STUDENT # %@",self.studentID]];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightItemDidClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    // Do any additional setup after loading the view.
}

-(IBAction)rightItemDidClick:(id)sender{
    //REFRESH
    //[self configViewData];
    [self requestUpdateRecordForTable:@"aci_student" forDataID:self.studentID forKey:@"student_status_id" forValue:@"2" withTag:11];
}

-(IBAction)didClickImage:(id)sender{
    [self requestImageWithTag:3];
}

-(void) requestImageWithTag:(NSInteger) c_tag{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"file_name":[NSString stringWithFormat:@"student_%@.png",self.studentID]
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
                
                [CurrentUserManager savePhotoToCoredata:data_container forName:[NSString stringWithFormat:@"student_%@.png",self.studentID]];
                image_pool = [UIImage imageWithData:data_container];
                [self performSegueWithIdentifier:@"toImageDetail" sender:self];
                [self reloadContentTableWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            if (c_tag == 4) {
                data_container = [[NSData alloc] initWithBase64EncodedString:[resultDict objectForKey:@"record"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                [CurrentUserManager savePhotoToCoredata:data_container forName:[NSString stringWithFormat:@"student_%@.png",self.studentID]];
                //image_pool = [UIImage imageWithData:data_container];
                //[self performSegueWithIdentifier:@"toImageDetail" sender:self];
                [self reloadContentTableWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            
        }];
        
    });
    
    
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestStudentDetailData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestStudentDetailData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
        }
        student_pack = nil;
        contact_pack = nil;
        address_pack = nil;
        
        NSDictionary * dict = @{
                                @"id": self.studentID
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"select_student" andCustomerTag:1 andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            student_pack = [CYFunctionSet stripNulls:[resultDict objectForKey:@"student"]];
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
            if (c_tag == 2) {
                [self requestStudentDetailData];
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
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp  = 0;
    if (section == 0) {
        // ID
        temp = 1;
    }
    if (section == 1) {
        //BASIC INFO
        temp = 6;
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
        temp = 1;
    }
    if (section == 5) {
        temp = 1;
    }
    if (section == 6) {
        //ACTIONS
        temp = 1;
    }
    return  temp;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat temp = 65.0;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        temp = 100.0;
    }
    return temp;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
         temp = @"BASIC INFO";
    }
    if (section == 1) {
       
    }
    if (section == 2) {
        temp = @"CONTACT INFO";
    }
    if (section == 3) {
        temp = @"ADDRESS INFO";
    }
    if (section == 4) {
        temp = @"PARENT";
    }

    if (section == 5) {
        temp = @"GRADE SCORE";
    }
    
    if (section == 6) {
        temp = @" ";
    }
    return temp;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"id_cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        if (indexPath.row == 0) {
            data_container = [CurrentUserManager searchPhotoforName:[NSString stringWithFormat:@"student_%@.png", self.studentID]];
            if (data_container) {
                cell.imageView.image = [UIImage imageWithData:data_container];
                
            }else{
                [self requestImageWithTag:4];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"STUDENT ID # %@", self.studentID];
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
            cell.detailTextLabel.text = [student_pack objectForKey:@"username"];
            
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"PASSWORD:";
            cell.detailTextLabel.text = @"****";
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"SCHOOL";
            cell.detailTextLabel.text = [student_pack objectForKey:@"school_name"];
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"STUDENT CATEGORY";
            cell.detailTextLabel.text = [student_pack objectForKey:@"student_category_str"];
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = @"STUDENT STATUS";
            cell.detailTextLabel.text = [student_pack objectForKey:@"student_status_str"];
        }
        if (indexPath.row == 5) {
            cell.textLabel.text = @"BIRTHDAY";
            cell.detailTextLabel.text = [student_pack objectForKey:@"birthday"];
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
        if (indexPath.row == 0) {
            cell.textLabel.text = @"VIEW LINKED PARENT";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"VIEW GRADE SCORE";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 6) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"DELETE"];
            cell.detailTextLabel.text = @"";
            cell.backgroundColor = [UIColor redColor];
        }
        
        
    }
    

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        //ID;
        [self performGetPictureFromCamera];
        
    }
    if (indexPath.section == 1) {
        if (indexPath.row < 3) {
            //USERNAME & PASS
            switch (indexPath.row) {
                case 0:
                    key_pool = @"username";
                    break;
                case 1:
                    key_pool = @"password";
                    break;
                case 2:
                    key_pool = @"school_name";
                    break;
                default:
                    break;
            }
            [self performAlertViewTextModifyWithKey:key_pool forValue:[student_pack objectForKey:key_pool] forTableName:@"aci_student" forDataID:self.studentID];
            
        }
        if (indexPath.row == 3) {
            //CATEGORY
            if (category_list) {
                NSNumber * num = [CYFunctionSet convertStingToNumber:[student_pack objectForKey:@"student_category_id"]];
                [self performDataPickerForKey:@"student_category_id" forDatasource:category_list forOrgIndex:num.integerValue];
                
            }else{
                [self requestCategoryArray];
            }
        }
        if (indexPath.row == 4) {
            //STATUS
            if (status_list) {
                NSNumber * num = [CYFunctionSet convertStingToNumber:[student_pack objectForKey:@"student_status_id"]];
                [self performDataPickerForKey:@"student_status_id" forDatasource:status_list forOrgIndex:num.integerValue];
                
            }else{
                [self requestStatusArray];
            }
        }
        if (indexPath.row == 5) {
            //BIRTHDAY
            [self performDatePickForKey:@"birthday" forOrgDate:[CYFunctionSet convertDateFromYearString:[student_pack objectForKey:@"birthday"]]];
            
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
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"studentDetailToParentDisplay" sender:self];
        }
    }
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"toGradeRoot" sender:self];
        }
    }
    if(indexPath.section == 6){
        if (indexPath.row == 0) {
            [self confirmActionForTitle:@"WARNING" forMessage:[NSString stringWithFormat:@"DELETE STUDENT '%@ %@' #%@?",[contact_pack objectForKey:@"first_name"],[contact_pack objectForKey:@"last_name"], self.studentID] forConfirmationHandler:^(UIAlertAction * action){
                [self requestUpdateRecordForTable:@"aci_student" forDataID:self.studentID forKey:@"student_status_id" forValue:@"0" withTag:11];
            }];
        }
        
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
        [CurrentUserManager savePhotoToCoredata:UIImagePNGRepresentation(croppedImage) forName:[NSString stringWithFormat:@"student_%@.png",self.studentID]];
        
        [connector sendImageUploadRequestWithImage:croppedImage andCustomerTag:5 forFileName:[NSString stringWithFormat:@"student_%@.png",self.studentID] andWillStartBlock:^(NSInteger c_tag){
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
        [CurrentUserManager savePhotoToCoredata:UIImagePNGRepresentation(croppedImage) forName:[NSString stringWithFormat:@"student_%@.png",self.studentID]];
        
        [connector sendImageUploadRequestWithImage:croppedImage andCustomerTag:5 forFileName:[NSString stringWithFormat:@"student_%@.png",self.studentID] andWillStartBlock:^(NSInteger c_tag){
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

-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    [self showAlertWithTittle:@"ERROR" forMessage:message];
}
-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    
    if (c_tag == 2) {
        [self requestStudentDetailData];
    }
    if (c_tag == 4) {
        categoryArray = [resultDic objectForKey:@"records"];
        [self prepareCategoryList];
    }
    if (c_tag == 5) {
        statusArray = [resultDic objectForKey:@"records"];
        [self prepareStatusList];
    }
    
}


#pragma mark CATEGORY

-(void) requestCategoryArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        categoryArray = nil;
        
        NSDictionary * dict = @{
                                @"table_name" : @"aci_student_category",
                                @"result_order": @"`id` ASC"
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:4];
    });
}
-(void) prepareCategoryList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in categoryArray) {
        [temp addObject:[dict objectForKey:@"student_category"]];
    }
    category_list = (NSArray *) temp;
    NSNumber * num = [CYFunctionSet convertStingToNumber:[student_pack objectForKey:@"student_category_id"]];
    [self performDataPickerForKey:@"student_category_id" forDatasource:category_list forOrgIndex:num.integerValue];
}

#pragma mark STATUS

-(void) requestStatusArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        statusArray = nil;
        
        NSDictionary * dict = @{
                                @"table_name" : @"aci_student_status",
                                @"result_order": @"`id` ASC"
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:5];
    });
}
-(void) prepareStatusList{
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in statusArray) {
        [temp addObject:[dict objectForKey:@"student_status"]];
    }
    status_list = (NSArray *) temp;
    NSNumber * num = [CYFunctionSet convertStingToNumber:[student_pack objectForKey:@"student_status_id"]];
    [self performDataPickerForKey:@"student_status_id" forDatasource:status_list forOrgIndex:num.integerValue];
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
    [self requestUpdateRecordForTable:@"aci_student" forDataID:self.studentID forKey:key forValue:[NSString stringWithFormat:@"%ld",(long)index] withTag:2];
}

#pragma mark DATE PICKER

-(void) performDatePickForKey:(NSString *) key
                   forOrgDate:(NSDate *) org_date{

    if (!dtvc) {
        dtvc = [[DatePickerViewController alloc] init];
    }
    dtvc.delegate = self;
    dtvc.key = key;
    dtvc.org_date = org_date;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showDetailViewController:dtvc sender:self];
    });
    
}
-(void)datePickerDidSaveDate:(NSDate *)aDate forKey:(NSString *)key{
    [self requestUpdateRecordForTable:@"aci_student" forDataID:self.studentID forKey:key forValue:[CYFunctionSet convertDateToConstantString:aDate] withTag:2];
}
-(void)datePickerDidClickCancel{
    [self reloadContentTable];
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
    if ([segue.identifier isEqualToString:@"studentDetailToParentDisplay"]) {
        ParentDisplayViewController * pdvc = (ParentDisplayViewController *) [segue destinationViewController];
        pdvc.data_id = self.studentID;
        pdvc.mode = @"STUDENT";
    }
    if([segue.identifier isEqualToString:@"toGradeRoot"]){
        GradeRecordDisplayViewController * grdvc = (GradeRecordDisplayViewController *)[segue destinationViewController];
        grdvc.studentID = self.studentID;
    }
}


@end
