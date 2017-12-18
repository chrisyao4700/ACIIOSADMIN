//
//  LinkParaDev.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/8/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkParaDev : NSObject
+(NSString *) getRootLinkAddress;
+(NSString *) getAPIDirectory;
+(NSString *) getAPIKey;
+(NSString *) getVersionCode;
+(NSString *) getUpdateURL;
+(NSString *) getCompanyEmail;
@end
