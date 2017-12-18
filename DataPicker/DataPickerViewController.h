//
//  DataPickerViewController.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/3/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataPickerDelegate.h"
@interface DataPickerViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>

@property NSString * key;
@property NSInteger orgIndex;

@property NSArray * dataSource;
@property id<DataPickerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UILabel *keyLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;

@end
