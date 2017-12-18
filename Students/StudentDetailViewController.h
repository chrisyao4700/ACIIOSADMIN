//
//  StudentDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "DataPickerViewController.h"
#import <RSKImageCropper/RSKImageCropper.h>
#import "DatePickerViewController.h"
@interface StudentDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate,DataPickerDelegate,UIImagePickerControllerDelegate,RSKImageCropViewControllerDelegate,UINavigationControllerDelegate,DatePickerDelegate>

@property NSString * studentID;
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@end
