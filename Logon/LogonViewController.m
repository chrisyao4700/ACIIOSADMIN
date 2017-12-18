//
//  LogonViewController.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "LogonViewController.h"
#import "LinkPara.h"
@interface LogonViewController ()

@end

@implementation LogonViewController{    
    ACI_CURRENT_USER * defaultUser;
    CurrentUserManager * userManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    [self.versionLabel setText:[LinkPara getVersionCode]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    defaultUser = [CurrentUserManager getCurrentDispatch];
    if (defaultUser) {
        self.usernameField.text = defaultUser.username;
    }
}
- (IBAction)pressedLogon:(id)sender {
    if (!userManager) {
        userManager = [[CurrentUserManager alloc] initWithDelegate:self];
    }
    [userManager loginWithUsername:self.usernameField.text andPassword:self.passwordField.text];
    [self.view endEditing:YES];
}
-(void) currentUserManagerWillStartRequestWithTag:(NSInteger) tag{
    [self loadingStart];
}
-(void) currentUserManagerDidGetResponseWithTag:(NSInteger) tag{
    [self loadingStop];
}
-(void) currentUserManagerError:(NSString *) messsage
                         forTag:(NSInteger)tag{
    [self showAlertWithTittle:@"Error" forMessage:messsage];
}
-(void) currentUserManagerLogonSuccess{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.passwordField.text = @"";
        [self performSegueWithIdentifier:@"logonToMain" sender:self];
    });
    
}



#define kOFFSET_FOR_KEYBOARD 250.0

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


-(void)setViewMoveUp{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        CGRect rect = self.view.frame;
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        
        self.view.frame = rect;
        [UIView commitAnimations];
    });
}
-(void) setViewMoveDown{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        CGRect rect = self.view.frame;
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        self.view.frame = rect;
        [UIView commitAnimations];
    });
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self setViewMoveDown];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self setViewMoveUp];
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
