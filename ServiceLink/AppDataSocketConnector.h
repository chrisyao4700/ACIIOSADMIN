//
//  AppDataSocketConnector.h
//  AppAdmin
//
//  Created by 姚远 on 4/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataSocketDelegate.h"
#import "CurrentUserManager.h"

@interface AppDataSocketConnector : NSObject

@property id <AppDataSocketDelegate> delegate;
- (instancetype)initWithDelegate:(id) aDelegate;

-(void) sendVersionAPIVerificationRequest;
-(void) sendRequestForAdminLogonWithPack:(NSDictionary *) dataPack;
-(void) sendRequestForInsertAdminRecordWithPack:(NSDictionary *) dataPack;
-(void) sendNormalRequestWithPack:(NSDictionary *) dataPack
                   andServiceCode:(NSString * ) service_code
                   andCustomerTag:(NSInteger) c_tag;

-(void) sendNormalRequestWithPack:(NSDictionary *) dataPack
                   andServiceCode:(NSString * )service_code
                   andCustomerTag:(NSInteger) c_tag
                andWillStartBlock:(void (^)(NSInteger c_tag)) willStartHandler
              andGotResponseBlock:(void (^)(NSInteger c_tag)) gotResponseHandler
                    andErrorBlock:(void (^)(NSInteger c_tag, NSString * message)) errorHandler
                  andSuccessBlock:(void (^)(NSInteger c_tag, NSDictionary * resultDict)) successHandler;

-(void) sendImageUploadRequestWithImage:(UIImage *) image
                         andCustomerTag:(NSInteger) c_tag
                            forFileName:(NSString *) file_name
                      andWillStartBlock:(void (^)(NSInteger c_tag)) willStartHandler
                    andGotResponseBlock:(void (^)(NSInteger c_tag)) gotResponseHandler
                          andErrorBlock:(void (^)(NSInteger c_tag, NSString * message)) errorHandler
                        andSuccessBlock:(void (^)(NSInteger c_tag, NSDictionary * resultDict)) successHandler;
@end
