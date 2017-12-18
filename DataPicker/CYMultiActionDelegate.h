//
//  CYMultiActionDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CYMultiActionDelegate <NSObject>
-(void) cyMultiActionRequestDetail:(NSIndexPath *) indexPath;
-(void) cyMultiActionRequestDelete:(NSIndexPath *) indexPath;
-(void) cyMultiActionRequestCancel:(NSIndexPath *)indexPath;
@end
