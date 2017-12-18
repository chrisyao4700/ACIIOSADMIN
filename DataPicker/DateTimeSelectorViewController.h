//
//  DateTimeSelectorViewController.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 9/12/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateTimeSelectorDelegate.h"

@interface DateTimeSelectorViewController : UIViewController
@property NSString * key;
@property NSDate * org_date;
@property (strong, nonatomic) IBOutlet UILabel *keyLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *timePicker;
@property id<DateTimeSelectorDelegate> delegate;
@end
