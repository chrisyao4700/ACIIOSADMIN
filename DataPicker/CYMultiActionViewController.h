//
//  CYMultiActionViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYMultiActionDelegate.h"

@interface CYMultiActionViewController : UIViewController

@property id<CYMultiActionDelegate> delegate;

@property NSIndexPath * indexPath;

@end
