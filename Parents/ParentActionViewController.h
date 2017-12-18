//
//  ParentActionViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentActionDelegate.h"

@interface ParentActionViewController : UIViewController
@property id<ParentActionDelegate> delegate;

@property NSString * relation_id;
@property NSString * parent_id;
@end
