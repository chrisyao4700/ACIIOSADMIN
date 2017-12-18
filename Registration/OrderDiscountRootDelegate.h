//
//  OrderDiscountRootDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/16/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OrderDiscountRootDelegate <NSObject>
@required
-(void) orderDiscountRootDidCreateOrderDiscount:(NSString *) order_discountID;
@end
