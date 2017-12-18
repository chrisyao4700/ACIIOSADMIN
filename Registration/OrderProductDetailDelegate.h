//
//  OrderProductDetailDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/14/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OrderProductDetailDelegate <NSObject>
@required
-(void) orderProductDidRequestUpdateOrderPrice;
@end
