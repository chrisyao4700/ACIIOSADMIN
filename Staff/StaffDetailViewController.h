//
//  StaffDetailViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import <RSKImageCropper/RSKImageCropper.h>
#import "DataPickerViewController.h"
@interface StaffDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppDataSocketDelegate, UIImagePickerControllerDelegate,RSKImageCropViewControllerDelegate,UINavigationControllerDelegate,DataPickerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;

@property NSString * staffID;

@end
