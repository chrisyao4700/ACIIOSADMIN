//
//  StudentListActionViewController.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "StudentListActionViewController.h"

@interface StudentListActionViewController ()

@end

@implementation StudentListActionViewController{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickCancel:(id)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate studentListActionDidCancel];
        }
    }];
}

- (IBAction)didClickViewDetail:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate studentListActionRequestDetail:self.studentID];
        }
    }];
}
- (IBAction)didClickRemoveFromList:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate studentListActionRequestDelete:self.studentID];
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end
