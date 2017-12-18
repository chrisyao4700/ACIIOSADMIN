//
//  CYTimePickerViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYTimePickerDelegate.h"

@interface CYTimePickerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *displayLabel;
@property (strong, nonatomic) IBOutlet UILabel *keyLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property NSString * key;
@property NSDate * org_date;
@property NSInteger c_tag;
@property id<CYTimePickerDelegate> delegate;

@end
