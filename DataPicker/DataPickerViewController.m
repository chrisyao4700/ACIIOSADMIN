//
//  DataPickerViewController.m
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/3/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import "DataPickerViewController.h"

@interface DataPickerViewController (){
    NSInteger selectedRow;
}

@end

@implementation DataPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.view.backgroundColor = [UIColor clearColor];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    _keyLabel.text = _key;
    _valueLabel.text = _dataSource[_orgIndex];
    _picker.dataSource = self;
    _picker.delegate = self;
    
    [_picker selectRow:_orgIndex inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didClickSave:(id)sender {
    [_delegate didSavePickedDataForKey:_key andIndex:selectedRow];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didClickCancel:(id)sender {
    [_delegate didCancelPickingDataForKey:_key];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _dataSource.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _dataSource[row];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedRow = row;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_valueLabel setText:_dataSource[row]];
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
