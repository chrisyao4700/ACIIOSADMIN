//
//  StudentListActionViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentListActionDelegate.h"

@interface StudentListActionViewController : UIViewController

@property NSString * studentID;
@property id<StudentListActionDelegate> delegate;

@end
