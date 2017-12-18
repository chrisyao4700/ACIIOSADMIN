//
//  CYFunctionSet.h
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYFunctionSet : NSObject
+(NSNumber *) convertStingToNumber:(NSString *) str;

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;
+(NSDate *) getDateFromTime:(NSDate *) org;
+(NSString *) urlEncode:(NSString *) org;
+(NSDate *) convertDateFromYearString:(NSString *) str;

+(NSString *) getCurrentFormatString;
+(NSString *) convertDateToTimeString:(NSDate *) aDate;
+(NSDate *) converUTCDateStringToDate:(NSString *) utcStr;
+ (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time;
+ (NSDate *)combineFormatDate:(NSDate *)date withTime:(NSDate *)time;
+(NSString *) convertTimeToHourMinuteSecond:(NSDate *) date;
+(NSDate *)getFirstDayOfTheWeekFromDate:(NSDate *)givenDate;

+(NSString *) getWeekdayStringWithNumber:(NSInteger) num;
+(NSArray *) getWeekDayArray;

+(NSDate *) getFirstDayOfTheMonthFromDate:(NSDate *) givenDate;
+(NSString *) convertDateToFormatString:(NSDate *) aDate;
+(NSString *) convertDateToShortStr:(NSDate *) aDate;
+(NSDate *) convertStringToDate:(NSString *) str;
+(NSString *) convertDateToString:(NSDate *) aDate;
+(NSString *) convertDoubleToString:(double) douNum;
+(NSString *) convertDateToYearString:(NSDate *) aDate;
+(NSString *) convertDateToConstantString:(NSDate *)aDate;

+(NSDate *) convertDateFromTwinString:(NSString *) str;
+(NSDate *) convertDateFromThribleString:(NSString *) str;
+(NSString *) convertStringToURLString:(NSString *) orgString;
+ (NSString *) md5:(NSString *) input;
+(NSDictionary*)stripNulls:(NSDictionary*)dict;
@end
