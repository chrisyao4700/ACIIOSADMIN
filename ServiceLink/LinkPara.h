//
//  LinkPara.h
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkPara : NSObject

+(NSString *) getRootLinkAddress;
+(NSString *) getAPIDirectory;
+(NSString *) getAPIKey;
+(NSString *) getVersionCode;
+(NSString *) getUpdateURL;
+(NSString *) getCompanyEmail;
+(NSString *) getImageSaveAPIDirectory;
+(NSString *) getPaymentToken;
+(NSString *) getCallBackURL;
@end
