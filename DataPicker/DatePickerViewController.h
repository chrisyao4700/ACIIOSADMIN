//
//  DatePickerViewController.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/25/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerDelegate.h"

@interface DatePickerViewController : UIViewController
@property NSDate * org_date;
@property NSString * key;

@property id<DatePickerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *keyLabel;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@end
