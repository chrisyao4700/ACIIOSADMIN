//
//  ParentActionDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParentActionDelegate <NSObject>
@required
-(void) actionControllerDidClickViewDetail:(NSString *) relation_id
                                 forParent:(NSString *) parent_id;
-(void) actionControllerDidClickRemove:(NSString *) relation_id
                             forParent:(NSString *) parent_id;
-(void) actionControllerDidClickCancel;

@end
