//
//  DatePickerDelegate.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/25/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DatePickerDelegate <NSObject>
-(void) datePickerDidClickCancel;
-(void) datePickerDidSaveDate:(NSDate *) aDate
                       forKey:(NSString *) key;

@end
