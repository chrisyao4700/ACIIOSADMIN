//
//  StudentSelectDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StudentSelectDelegate <NSObject>
@required

-(void) studentSelectionDidSelectStudent:(NSString *) studentID;
@end
