//
//  UIViewController+CYViewController.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 6/29/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "UIViewController+CYViewController.h"

@implementation UIViewController (CYViewController)


UIActivityIndicatorView * loadingView;
UIAlertController * alert;


-(void) configBackgroundView{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
        backgroundView.image = [UIImage imageNamed:@"view_background"];
        backgroundView.alpha = 0.6;
        [self.view insertSubview:backgroundView atIndex:0];
    });
}

-(void) loadingStart{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView startAnimating];
    });
    
}
-(void) loadingStop{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView stopAnimating];
    });
}
-(void) configLoadingView{
    dispatch_async(dispatch_get_main_queue(), ^{
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingView setHidesWhenStopped:YES];
        loadingView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        [self.view addSubview:loadingView];
    });
    
}
-(void) showAlertWithTittle:(NSString *) tittle
                 forMessage:(NSString *) message{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        alert = [UIAlertController
                 alertControllerWithTitle:tittle
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             
                                                         }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    });
    
}
-(void) confirmActionForTitle:(NSString *) title
                   forMessage:(NSString *) message
       forConfirmationHandler: (void (^)(UIAlertAction * action)) handler {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        alert = [UIAlertController
                 alertControllerWithTitle:title
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:handler];
        [alert addAction:okAction];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    });
}

-(void) cyDismissViewControllerInNav{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });

}
-(void) setNavigationBarString:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.topViewController.title = str;
    });
}



@end
