//
//  UIViewController+CYViewController.h
//  FortuneLinkAdmin
//
//  Created by 姚远 on 6/29/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CYFunctionSet.h"

@interface UIViewController (CYViewController)


-(void) configBackgroundView;
-(void) loadingStart;
-(void) loadingStop;
-(void) showAlertWithTittle:(NSString *) tittle
                 forMessage:(NSString *) message;
-(void) configLoadingView;
-(void) cyDismissViewControllerInNav;
-(void) setNavigationBarString:(NSString *) str;
-(void) confirmActionForTitle:(NSString *) title
                   forMessage:(NSString *) message
       forConfirmationHandler: (void (^)(UIAlertAction * action)) handler;

@end
