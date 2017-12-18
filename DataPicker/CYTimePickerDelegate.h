//
//  CYTimePickerDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CYTimePickerDelegate <NSObject>

-(void) cyTimePickerDidSaveDate:(NSDate *) date
                         forKey:(NSString *) key
                         forTag:(NSInteger) c_tag;
-(void) cyTimePickerDidCancelForKey:(NSString *) key
                             forTag:(NSInteger) c_tag;

@end
