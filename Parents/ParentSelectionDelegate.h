//
//  ParentSelectionDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/13/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParentSelectionDelegate <NSObject>

-(void) parentSelectionDidSelctParent:(NSString *) parentID;

@end
