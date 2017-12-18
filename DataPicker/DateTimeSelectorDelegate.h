//
//  DateTimeSelectorDelegate.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 9/12/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DateTimeSelectorDelegate <NSObject>
-(void) datetimePickerDidCancelWithKey:(NSString *) key;
-(void) datetimePickerDidSaveWithKey:(NSString *) key
                            andValue:(NSString *) selectedDate;

@end
