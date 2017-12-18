//
//  CYTimePickerViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CYTimePickerViewController.h"
#import "CYFunctionSet.h"
@interface CYTimePickerViewController ()

@end

@implementation CYTimePickerViewController{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.org_date) {
        [self updateDateLabelWithDate:self.org_date];
    }else{
        [self updateDateLabelWithDate:[NSDate date]];
    }
    
    self.keyLabel.text = self.key;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didClickSave:(id)sender {
    if (self.delegate) {
        [self.delegate cyTimePickerDidSaveDate:self.datePicker.date forKey:self.key forTag:self.c_tag];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
- (IBAction)didClickCancel:(id)sender {
    if (self.delegate) {
        [self.delegate cyTimePickerDidCancelForKey:self.key forTag:self.c_tag];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)timePickerDidChange:(id)sender {
    [self updateDateLabelWithDate:self.datePicker.date];
}

-(void) updateDateLabelWithDate:(NSDate *) aDate{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.displayLabel.text = [CYFunctionSet convertDateToTimeString:aDate];
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
