//
//  LinkPara.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "LinkPara.h"

@implementation LinkPara
+(NSString *) getRootLinkAddress{
    return @"https://chrisyao4700.com";
}
+(NSString *) getChildBranchFolderName{
    return @"aci_hacienda";
}
+(NSString *) getAPIDirectory{
    return @"aci_hacienda/aci_hacienda_api.php";
}
+(NSString *) getAPIKey{
    return @"chrisyao4700";
}
+(NSString *) getImageSaveAPIDirectory{
    return @"aci_hacienda/aci_hacienda_image.php";
}
+(NSString *) getVersionCode{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *erped_version = [NSString stringWithFormat:@"ios.admin.%@",version];
    return erped_version;
}
+(NSString *) getUpdateURL{
    NSString * temp = [NSString stringWithFormat:@"%@/%@/Apps/Admin/Install/excute.html",[LinkPara getRootLinkAddress],[LinkPara getChildBranchFolderName]];
    return temp;
}
+(NSString *) getCompanyEmail{
    return @"chrisyao900908@gmail.com";
}
+(NSString *) getPaymentToken{
    return @"sq0idp-CPBfdCJx-5AGWpWo2Rs7yg";
}
+(NSString *) getCallBackURL{
    return @"ACI-Hacienda://";
    
    
}




@end
