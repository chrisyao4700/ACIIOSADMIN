//
//  CYMultiActionViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CYMultiActionViewController.h"

@interface CYMultiActionViewController ()

@end

@implementation CYMultiActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate cyMultiActionRequestCancel:self.indexPath];
        }
    }];
}
- (IBAction)didClickViewDetail:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate cyMultiActionRequestDetail:self.indexPath];
        }
    }];

}
- (IBAction)didClickDelete:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate cyMultiActionRequestDelete:self.indexPath];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
