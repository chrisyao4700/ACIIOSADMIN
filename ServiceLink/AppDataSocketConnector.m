//
//  FortuneLinkDataSocketConnector.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "AppDataSocketConnector.h"
#import "LinkPara.h"
#import "AppDelegate.h"
#import "LinkParaDev.h"
#import "CYFunctionSet.h"
@implementation AppDataSocketConnector{
    NSDictionary * linkPara;
}
- (instancetype)initWithDelegate:(id) aDelegate
{
    self = [super init];
    if (self) {
        self.delegate = aDelegate;
    }
    return self;
}

-(NSDictionary *) prepareLinkPara{
    
    //    NSString * linkDirectory = [NSString stringWithFormat:@"%@/%@",
    //                                [LinkParaDev getRootLinkAddress], [LinkParaDev getAPIDirectory]];
    //    NSString * api_key = [LinkParaDev getAPIKey];
    //    NSString * version_code = [LinkParaDev getVersionCode];
    
    
    NSDictionary *temp_dict = @{
                                @"api_key": [LinkPara getAPIKey],
                                @"version_code": [LinkPara getVersionCode],
                                @"link_directory" : [NSString stringWithFormat:@"%@/%@",
                                                     [LinkPara getRootLinkAddress], [LinkPara getAPIDirectory]],
                                @"imageAPI_directory" : [NSString stringWithFormat:@"%@/%@",[LinkPara getRootLinkAddress],[LinkPara getImageSaveAPIDirectory]]};
    
    return temp_dict;
}


-(void) sendVersionAPIVerificationRequest{
    if (!linkPara) {
        linkPara = [self prepareLinkPara];
    }
    NSDictionary * uploadPack = @{
                                  @"api_key":[linkPara objectForKey:@"api_key"],
                                  @"version_code": [linkPara objectForKey:@"version_code"],
                                  @"service_code": @"connection_check"
                                  };
    NSError *jsonError;
    NSURL *postURL = [NSURL URLWithString:[linkPara objectForKey:@"link_directory"]];
    //NSLog(@"Upload Pack:%@", uploadPack.description);
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:uploadPack options:0 error:&jsonError];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:postURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    if (self.delegate) {
        [self.delegate dataSocketWillStartRequestWithTag:0
                                          andCustomerTag:0];
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
        if (self.delegate) {
            [self.delegate dataSocketDidGetResponseWithTag:0
                                            andCustomerTag:0];
        }
        if (data) {
            NSString * resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", resultStr);
            NSError * errorDecode;
            NSDictionary * resultDict= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorDecode];
            
            NSNumber* status = (NSNumber *)[resultDict objectForKey:@"status"];
            NSString * message = [resultDict objectForKey:@"message"];
            
            if (status.boolValue == YES) {
                if (self.delegate) {
                    [self.delegate dataSocketDidFinishConnectionCheckWithMessage:message
                                                                  andCustomerTag:0];
                }
            }
            if (status.boolValue == NO) {
                if (self.delegate) {
                    [self.delegate dataSocketErrorWithTag:0 andMessage:message
                                           andCustomerTag:0];
                }
                [self checkUpdateForMessage:message];
                
            }
        }else{
            if (self.delegate) {
                [self.delegate dataSocketErrorWithTag:0 andMessage:@"INTERNET ERROR, PLEASE CHECK YOUR CONNECTION SETTING."
                                       andCustomerTag:0];
            }
        }
        
    }] resume];
}



-(void) sendRequestForAdminLogonWithPack:(NSDictionary *) dataPack{
    if (!linkPara) {
        linkPara = [self prepareLinkPara];
    }
    NSDictionary * uploadPack = @{
                                  @"api_key":[linkPara objectForKey:@"api_key"],
                                  @"version_code": [linkPara objectForKey:@"version_code"],
                                  @"service_code": @"admin_logon",
                                  @"data_pack" : dataPack
                                  };
    NSError *jsonError;
    NSURL *postURL = [NSURL URLWithString:[linkPara objectForKey:@"link_directory"]];
    NSLog(@"Upload Pack:%@\nURL:%@", uploadPack.description,postURL.description);
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:uploadPack options:0 error:&jsonError];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:postURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    if (self.delegate) {
        [self.delegate dataSocketWillStartRequestWithTag:1
                                          andCustomerTag:0];
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
        if (self.delegate) {
            [self.delegate dataSocketDidGetResponseWithTag:1
                                            andCustomerTag:0];
        }
        if (data) {
            NSString * resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", resultStr);
            NSError * errorDecode;
            NSDictionary * resultDict= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorDecode];
            
            NSNumber* status = (NSNumber *)[resultDict objectForKey:@"status"];
            NSString * message = [resultDict objectForKey:@"message"];
            
            if (status.boolValue == YES) {
                if (self.delegate) {
                    //[self.delegate dataSocketDidFinishConnectionCheckWithMessage:message];
                    [self.delegate dataSocketDidLogonWithMessage:message forUser:[resultDict objectForKey:@"user"]
                                                  andCustomerTag:0];
                }
            }
            if (status.boolValue == NO) {
                if (self.delegate) {
                    [self.delegate dataSocketErrorWithTag:1 andMessage:message
                                           andCustomerTag:0];
                }
                [self checkUpdateForMessage:message];
            }
        }else{
            if (self.delegate) {
                [self.delegate dataSocketErrorWithTag:1 andMessage:@"INTERNET ERROR, PLEASE CHECK YOUR CONNECTION SETTING."
                                       andCustomerTag:0];
            }
        }
        
    }] resume];
}

-(void) sendRequestForInsertAdminRecordWithPack:(NSDictionary *) dataPack{
    if (!linkPara) {
        linkPara = [self prepareLinkPara];
    }
    NSDictionary * uploadPack = @{
                                  @"api_key":[linkPara objectForKey:@"api_key"],
                                  @"version_code": [linkPara objectForKey:@"version_code"],
                                  @"service_code": @"admin_logon",
                                  @"data_pack" : dataPack
                                  };
    NSError *jsonError;
    NSURL *postURL = [NSURL URLWithString:[linkPara objectForKey:@"link_directory"]];
    //NSLog(@"Upload Pack:%@", uploadPack.description);
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:uploadPack options:0 error:&jsonError];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:postURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    if (self.delegate) {
        [self.delegate dataSocketWillStartRequestWithTag:2
                                          andCustomerTag:0];
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
        if (self.delegate) {
            [self.delegate dataSocketDidGetResponseWithTag:2
                                            andCustomerTag:0];
        }
        if (data) {
            NSString * resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", resultStr);
            NSError * errorDecode;
            NSDictionary * resultDict= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorDecode];
            
            NSNumber* status = (NSNumber *)[resultDict objectForKey:@"status"];
            NSString * message = [resultDict objectForKey:@"message"];
            
            if (status.boolValue == YES) {
                if (self.delegate) {
                    //[self.delegate dataSocketDidFinishConnectionCheckWithMessage:message];
                    [self.delegate dataSocketDidInsertUserWithMessage:message forUser:[resultDict objectForKey:@"record"]
                                                       andCustomerTag:0];
                }
            }
            if (status.boolValue == NO) {
                if (self.delegate) {
                    [self.delegate dataSocketErrorWithTag:2 andMessage:message
                                           andCustomerTag:0];
                }
                [self checkUpdateForMessage:message];
            }
        }else{
            if (self.delegate) {
                [self.delegate dataSocketErrorWithTag:2 andMessage:@"INTERNET ERROR, PLEASE CHECK YOUR CONNECTION SETTING."
                                       andCustomerTag:0];
            }
        }
        
    }] resume];
}

-(void) sendImageUploadRequestWithImage:(UIImage *) image
                         andCustomerTag:(NSInteger) c_tag
                            forFileName:(NSString *) file_name
                      andWillStartBlock:(void (^)(NSInteger c_tag)) willStartHandler
                    andGotResponseBlock:(void (^)(NSInteger c_tag)) gotResponseHandler
                          andErrorBlock:(void (^)(NSInteger c_tag, NSString * message)) errorHandler
                        andSuccessBlock:(void (^)(NSInteger c_tag, NSDictionary * resultDict)) successHandler{
    
    if (!linkPara) {
        linkPara = [self prepareLinkPara];
    }
    
    NSData *imageData = UIImagePNGRepresentation([CYFunctionSet imageWithImage:image convertToSize:CGSizeMake(200, 200)]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[linkPara objectForKey:@"imageAPI_directory"]]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449"
    ;
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",file_name]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSLog(@"UPLOAD IMAGE REQUEST: %@",request.description);
    
    willStartHandler(c_tag);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        gotResponseHandler(c_tag);
        if (!data) {
            //Handle No Data
            errorHandler(c_tag,@"INTERNET ERROR, PLEASE CHECK YOUR CONNECTION SETTING.");
            
        }else{
            // Handle Action
            NSError * errorDecode;
            //NSString * resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"%@", resultStr);
            
            NSDictionary * resultDict= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorDecode];
            NSNumber* status = (NSNumber *)[resultDict objectForKey:@"status"];
            NSString * message = [resultDict objectForKey:@"message"];
            if ([status boolValue] == YES) {
                
                
                
                successHandler(c_tag,resultDict);
            }else{
                
                errorHandler(c_tag,message);
            }
        }
        
    }] resume];
    
    
}





-(void) sendNormalRequestWithPack:(NSDictionary *) dataPack
                   andServiceCode:(NSString * )service_code
                   andCustomerTag:(NSInteger) c_tag
                andWillStartBlock:(void (^)(NSInteger c_tag)) willStartHandler
              andGotResponseBlock:(void (^)(NSInteger c_tag)) gotResponseHandler
                    andErrorBlock:(void (^)(NSInteger c_tag, NSString * message)) errorHandler
                  andSuccessBlock:(void (^)(NSInteger c_tag, NSDictionary * resultDict)) successHandler{
    
    if (!linkPara) {
        linkPara = [self prepareLinkPara];
    }
    NSDictionary * uploadPack = @{
                                  @"api_key":[linkPara objectForKey:@"api_key"],
                                  @"version_code": [linkPara objectForKey:@"version_code"],
                                  @"service_code": service_code,
                                  @"data_pack" : dataPack
                                  };
    NSError *jsonError;
    NSURL *postURL = [NSURL URLWithString:[linkPara objectForKey:@"link_directory"]];
    //NSLog(@"Upload Pack:%@", uploadPack.description);
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:uploadPack options:0 error:&jsonError];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:postURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    willStartHandler(c_tag);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
        gotResponseHandler(c_tag);
        if (data) {
            NSString * resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", resultStr);
            NSError * errorDecode;
            NSDictionary * resultDict= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorDecode];
            
            NSNumber* status = (NSNumber *)[resultDict objectForKey:@"status"];
            NSString * message = [resultDict objectForKey:@"message"];
            
            if (status.boolValue == YES) {
                if (self.delegate) {
                    
                    successHandler(c_tag,resultDict);
                }
            }
            if (status.boolValue == NO) {
                
                errorHandler(c_tag,message);
                [self checkUpdateForMessage:message];
            }
        }else{
            errorHandler(c_tag, @"INTERNET ERROR, PLEASE CHECK YOUR CONNECTION SETTING.");
        }
        
    }] resume];
    
    
    
}

-(void) sendNormalRequestWithPack:(NSDictionary *) dataPack
                   andServiceCode:(NSString * ) service_code
                   andCustomerTag:(NSInteger) c_tag{
    if (!linkPara) {
        linkPara = [self prepareLinkPara];
    }
    NSDictionary * uploadPack = @{
                                  @"api_key":[linkPara objectForKey:@"api_key"],
                                  @"version_code": [linkPara objectForKey:@"version_code"],
                                  @"service_code": service_code,
                                  @"data_pack" : dataPack
                                  };
    NSError *jsonError;
    NSURL *postURL = [NSURL URLWithString:[linkPara objectForKey:@"link_directory"]];
    NSLog(@"Upload Pack:%@", uploadPack.description);
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:uploadPack options:0 error:&jsonError];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:postURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    if (self.delegate) {
        [self.delegate dataSocketWillStartRequestWithTag:99
                                          andCustomerTag:c_tag];
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
        if (self.delegate) {
            [self.delegate dataSocketDidGetResponseWithTag:99
                                            andCustomerTag:c_tag];
        }
        if (data) {
            NSString * resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", resultStr);
            NSError * errorDecode;
            NSDictionary * resultDict= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorDecode];
            
            NSNumber* status = (NSNumber *)[resultDict objectForKey:@"status"];
            NSString * message = [resultDict objectForKey:@"message"];
            
            if (status.boolValue == YES) {
                if (self.delegate) {
                    
                    [self.delegate datasocketDidReceiveNormalResponseWithDict:resultDict
                                                               andCustomerTag: c_tag];
                }
            }
            if (status.boolValue == NO) {
                if (self.delegate) {
                    [self.delegate dataSocketErrorWithTag:99 andMessage:message
                                           andCustomerTag:(NSInteger) c_tag];
                }
                [self checkUpdateForMessage:message];
            }
        }else{
            if (self.delegate) {
                [self.delegate dataSocketErrorWithTag:99 andMessage:@"INTERNET ERROR, PLEASE CHECK YOUR CONNECTION SETTING."
                                       andCustomerTag:(NSInteger) c_tag];
            }
        }
        
    }] resume];
}


-(void) checkUpdateForMessage:(NSString *) message{
    if ([message containsString:@"VERSION CHECK RECORD CODE NOT MATCH"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LinkPara getUpdateURL]] options:@{} completionHandler:^(BOOL success){
            exit(0);
        }];
    }
}

- ( NSURLSession * )getURLSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken,
                  ^{
                      NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                      configuration.timeoutIntervalForRequest = 10.00;
                      session = [NSURLSession sessionWithConfiguration:configuration];
                  } );
    
    return session;
}

@end
