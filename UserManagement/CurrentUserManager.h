//
//  CurrentUserManager.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/8/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDataSocketConnector.h"
#import "CurrentUserDelegate.h"
#import "ACI_CURRENT_USER+CoreDataClass.h"


#import "ACI_PHOTO+CoreDataClass.h"
#import "ACI_ORDER_PAYMENT+CoreDataClass.h"

@interface CurrentUserManager : NSObject<AppDataSocketDelegate>
@property id <CurrentUserDelegate> delegate;
- (instancetype)initWithDelegate:(id)aDelegate;

+(ACI_CURRENT_USER *) getCurrentDispatch;
+(ACI_ORDER_PAYMENT *) getCurrentPayment;
+(void) saveCurrentPaymentWithDict:(NSDictionary *) info_dict;
+(void) savePhotoToCoredata:(NSData *) data forName:(NSString *) str;
+(NSData *) searchPhotoforName:(NSString *) str;
-(void) loginWithUsername:(NSString *) username
              andPassword:(NSString *) password;
-(void) updateCurrentUserWithPack:(NSDictionary *) pack;
@end
