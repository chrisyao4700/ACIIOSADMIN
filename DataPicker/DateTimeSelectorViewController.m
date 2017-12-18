//
//  DateTimeSelectorViewController.m
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 9/12/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import "DateTimeSelectorViewController.h"
#import "CYFunctionSet.h"

@interface DateTimeSelectorViewController ()

@end

@implementation DateTimeSelectorViewController{
    NSDate * selectedDate;
    NSDate * selectedTime;
    NSDate * currentDate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.view.backgroundColor = [UIColor clearColor];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.keyLabel.text = self.key;
    if (self.org_date) {
        self.datePicker.date = self.org_date;
        self.timePicker.date = self.org_date;
    }else{
        self.datePicker.date = [NSDate date];
        self.timePicker.date = [NSDate date];
    }
    selectedDate = self.datePicker.date;
    selectedTime = self.timePicker.date;
    currentDate = self.datePicker.date;
    [self updateDatetimeLabel];
}
- (IBAction)datePickerDidChange:(id)sender {
    selectedDate = self.datePicker.date;
    currentDate = [CYFunctionSet combineFormatDate:selectedDate withTime:selectedTime];
    [self updateDatetimeLabel];
}
- (IBAction)timePickerDidChange:(id)sender {
    selectedTime = self.timePicker.date;
    currentDate = [CYFunctionSet combineFormatDate:selectedDate withTime:selectedTime];
    [self updateDatetimeLabel];
}

- (IBAction)didClickSave:(id)sender {
    if (currentDate) {
        [self.delegate datetimePickerDidSaveWithKey:self.key andValue:[CYFunctionSet convertDateToFormatString:currentDate]];
    }else{
        [self.delegate datetimePickerDidSaveWithKey:self.key andValue: @"0000:00:00 00:00:00"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didClickClear:(id)sender {
    currentDate = nil;
    [self clearDatetimeLabel];
    
}
- (IBAction)didClickCancel:(id)sender {
    [self.delegate datetimePickerDidCancelWithKey:self.key];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) updateDatetimeLabel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dateLabel.text = [CYFunctionSet convertDateToString:currentDate];
    });
}
-(void) clearDatetimeLabel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dateLabel.text = @"0000:00:00 00:00:00";
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
