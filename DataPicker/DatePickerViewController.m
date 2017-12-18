//
//  DatePickerViewController.m
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/25/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import "DatePickerViewController.h"
#import "CYFunctionSet.h"

@interface DatePickerViewController ()

@end

@implementation DatePickerViewController{
    NSDate * currentDate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.view.backgroundColor = [UIColor clearColor];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
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
    }else{
        self.datePicker.date = [NSDate date];
    }
    currentDate = self.datePicker.date;
}
- (IBAction)didClickCancel:(id)sender {
    [self.delegate datePickerDidClickCancel];
   [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)dateDidChange:(id)sender {
    currentDate = self.datePicker.date;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dateLabel setText:[CYFunctionSet convertDateToYearString:currentDate]];
    });
}
- (IBAction)didClickSave:(id)sender {
    [self.delegate datePickerDidSaveDate:currentDate forKey:self.key];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didClickClear:(id)sender {
    currentDate = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dateLabel setText:@"0000/00/00"];
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
