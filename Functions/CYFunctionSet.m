//
//  CYFunctionSet.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CYFunctionSet.h"
#import <CommonCrypto/CommonDigest.h>


@implementation CYFunctionSet
+(NSNumber *) convertStingToNumber:(NSString *) str{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:str];
    return myNumber;
}
+(NSDate *) getDateFromTime:(NSDate *)org{
    NSString * temp = [CYFunctionSet convertDateToYearString:org];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init ];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate * aDate = [formatter dateFromString:temp];
    
    return aDate;
    
}

+(NSString *) urlEncode:(NSString *)org{
    NSString * url =  [CYFunctionSet convertStringToURLString:org];
    
    url = [url stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
    return url;
}

+(NSDate *) convertDateFromTwinString:(NSString *) str{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"MM/dd"];
    NSDate* pick_date = [formatter dateFromString:str];
    return pick_date;
    
}
+(NSDate *) convertDateFromThribleString:(NSString *) str{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate* pick_date = [formatter dateFromString:str];
    return pick_date;
}
+(NSDate *) convertRawStringToDate:(NSString *) rawStrin{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSDate* pick_date = [formatter dateFromString:rawStrin];
    return pick_date;
    
}

+(NSString *) convertDateToShortStr:(NSDate *) aDate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init ];
    [formatter setDateFormat:@"MM/dd' 'HH:mm"];
    NSString * dateStr = [formatter stringFromDate:aDate];
    
    
    return dateStr;
}
+(NSString *) convertDateToTimeString:(NSDate *) aDate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString * dateStr = [formatter stringFromDate:aDate];
    return dateStr;
}
+(NSString *) convertDateToString:(NSDate *) aDate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init ];
    [formatter setDateFormat:@"yyyy/MM/dd' 'HH:mm"];
    NSString * dateStr = [formatter stringFromDate:aDate];
    return dateStr;
}
+(NSString *) convertDateToYearString:(NSDate *) aDate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init ];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString * dateStr = [formatter stringFromDate:aDate];
    return dateStr;
}
+(NSString *) convertTimeToHourMinuteSecond:(NSDate *) date{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString * dateStr = [formatter stringFromDate:date];
    return dateStr;
}


+(NSDate *) convertDateFromYearString:(NSString *) str{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* pick_date = [formatter dateFromString:str];
    return pick_date;
}
+(NSString *) convertDateToFormatString:(NSDate *) aDate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init ];
    [formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
    NSString * dateStr = [formatter stringFromDate:aDate];
    return dateStr;
}
+(NSString *) getCurrentFormatString{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init ];
    [formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
    NSString * dateStr = [formatter stringFromDate:[NSDate date]];
    return dateStr;

}
+(NSDate *) convertStringToDate:(NSString *) str{
    if (![str containsString:@"UTC"]) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        [formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
        
        NSDate* pick_date = [formatter dateFromString:str];
        return pick_date;
        
    }
    return nil;
    
}
+ (NSDate *)getFirstDayOfTheWeekFromDate:(NSDate *)givenDate
{
    NSDate *weekDate =givenDate;
    NSCalendar *myCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *currentComps = [myCalendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:weekDate];
    
    
    [currentComps setWeekday:1]; // 1: sunday
    NSDate *firstDayOfTheWeek = [myCalendar dateFromComponents:currentComps];
    return firstDayOfTheWeek;
}
+(NSString *) getWeekdayStringWithNumber:(NSInteger) num{
    NSString * temp = @"";
    //NSNumber * temp_num = [CYFunctionSet convertStingToNumber:num_str];
    switch (num) {
        case 0:
            temp = @"SUNDAY";
            break;
        case 1:
            temp = @"MONDAY";
            break;
        case 2:
            temp = @"TUESDAY";
            break;
        case 3:
            temp = @"WEDNESDAY";
            break;
        case 4:
            temp = @"THURSDAY";
            break;
        case 5:
            temp = @"FRIDAY";
            break;
        case 6:
            temp = @"SATURDAY";
            break;
            
        default:
            break;
    }
    return temp;

}
+(NSArray *) getWeekDayArray{
    NSMutableArray * temp =[[NSMutableArray alloc] init];
    
    for (int i = 0; i<7; i++) {
        [temp addObject:[CYFunctionSet getWeekdayStringWithNumber:i]];
    }
    return (NSArray *) temp;
}

+(NSDate *) getFirstDayOfTheMonthFromDate:(NSDate *) givenDate{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *arbitraryDate = givenDate;
    NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:arbitraryDate];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [gregorian dateFromComponents:comp];
    return  firstDayOfMonthDate;
}
+(NSString *) convertDateToConstantString:(NSDate *)aDate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init ];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr = [formatter stringFromDate:aDate];
    return dateStr;
}

+(NSString *) convertDoubleToString:(double) douNum{
    
    NSString * str= [NSString stringWithFormat:@"$ %.2lf", douNum];
    return str;
}
+(NSDate *) converUTCDateStringToDate:(NSString *) utcStr{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
    
    
    NSDate* pick_date = [formatter dateFromString:utcStr];
    
    
    return pick_date;
}
+ (NSDate *)combineFormatDate:(NSDate *)date withTime:(NSDate *)time {
    
    NSString * strDate = [CYFunctionSet convertDateToConstantString:date];
    NSString * strTime = [CYFunctionSet convertTimeToHourMinuteSecond:time];
    
    NSString * combined = [NSString stringWithFormat:@"%@ %@", strDate,strTime];
    
    
    
    NSDate *combDate = [CYFunctionSet convertStringToDate:combined];
    
    return combDate;
}
+ (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time {
    
    NSString * strDate = [CYFunctionSet convertDateToYearString:date];
    NSString * strTime = [CYFunctionSet convertTimeToHourMinuteSecond:time];
    
    NSString * combined = [NSString stringWithFormat:@"%@ %@", strDate,strTime];
    
    
    
    NSDate *combDate = [CYFunctionSet convertStringToDate:combined];
    
    return combDate;
}
+(NSString *) convertStringToURLString:(NSString *) orgString{
    NSString * temp = [orgString stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
    temp = [temp stringByReplacingOccurrencesOfString:@"_" withString:@"%5F"];
    temp = [temp stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    temp = [temp stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    temp = [temp stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    temp = [temp stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    
    return temp;
}
+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

+(NSDictionary*)stripNulls:(NSDictionary*)dict{
    
    NSMutableDictionary *returnDict = [NSMutableDictionary new];
    NSArray *allKeys = [dict allKeys];
    NSArray *allValues = [dict allValues];
    
    for (int i=0; i<[allValues count]; i++) {
        if([allValues objectAtIndex:i] == (NSString*)[NSNull null]){
            [returnDict setValue:@"" forKey:[allKeys objectAtIndex:i]];
        }
        else
            [returnDict setValue:[allValues objectAtIndex:i] forKey:[allKeys objectAtIndex:i]];
    }
    
    return returnDict;
}
+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}
@end
