//
//  DataPickerDelegate.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/3/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataPickerDelegate <NSObject>

-(void) didSavePickedDataForKey:(NSString *) key andIndex:(NSInteger) index;
-(void) didCancelPickingDataForKey:(NSString *) key;

@end
