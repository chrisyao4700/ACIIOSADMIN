//
//  LinkParaDev.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/8/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "LinkParaDev.h"

@implementation LinkParaDev
+(NSString *) getRootLinkAddress{
    return @"https://169.254.90.7:3000";
}
+(NSString *) getChildBranchFolderName{
    return @"fortunelink";
}
+(NSString *) getAPIDirectory{
    return @"app_api";
}
+(NSString *) getAPIKey{
    return @"chrisyao4700";
}
+(NSString *) getVersionCode{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *erped_version = [NSString stringWithFormat:@"ios.admin.%@",version];
    return erped_version;
}
+(NSString *) getUpdateURL{
    NSString * temp = [NSString stringWithFormat:@"%@/%@/Apps/Admin/Install/excute.html",[LinkParaDev getRootLinkAddress],[LinkParaDev getChildBranchFolderName]];
    return temp;
}
+(NSString *) getCallBackURL{
    return @"ACI-Hacienda://";
}
+(NSString *) getCompanyEmail{
    return @"fortune9988@icloud.com";
}

@end
