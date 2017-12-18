//
//  ParentActionViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ParentActionViewController.h"

@interface ParentActionViewController ()

@end

@implementation ParentActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didClickViewDetail:(id)sender {
    if (self.delegate) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate actionControllerDidClickViewDetail:self.relation_id forParent:self.parent_id];
        }];
    }
}
- (IBAction)didClickRemoveFromList:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate actionControllerDidClickRemove:self.relation_id forParent:self.parent_id];
    }];

}
- (IBAction)didClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate actionControllerDidClickCancel];
    }];
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
