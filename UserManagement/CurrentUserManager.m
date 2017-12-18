//
//  CurrentUserManager.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/8/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CurrentUserManager.h"
#import "AppDelegate.h"

@implementation CurrentUserManager{
    AppDataSocketConnector * connector;
}
- (instancetype)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self) {
        self.delegate = aDelegate;
    }
    return self;
}

/* Coredata */
-(NSManagedObjectContext *) configCoredataContext{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    return managedObjectContext;
}

+(void) savePhotoToCoredata:(NSData *) data forName:(NSString *) str{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [ACI_PHOTO fetchRequest];
    [request setPredicate:[NSPredicate predicateWithFormat:@"photo_name == %@",str]];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 0) {
        ACI_PHOTO * photo = (ACI_PHOTO *)[NSEntityDescription insertNewObjectForEntityForName:@"ACI_PHOTO" inManagedObjectContext:managedObjectContext];
        photo.photo_name = str;
        photo.image_data = data;
    }

    if (array.count == 1) {
        ACI_PHOTO * photo = array[0];
        photo.photo_name = str;
        photo.image_data = data;
    }
    if (array.count > 1) {
        for (ACI_PHOTO * photo in array) {
            [managedObjectContext deleteObject:photo];
        }
        ACI_PHOTO * photo = (ACI_PHOTO *)[NSEntityDescription insertNewObjectForEntityForName:@"ACI_PHOTO" inManagedObjectContext:managedObjectContext];
        photo.photo_name = str;
        photo.image_data = data;
    }
    NSError * s_error;
    [managedObjectContext save:&s_error];
}

+(NSData *) searchPhotoforName:(NSString *) str{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [ACI_PHOTO fetchRequest];
    [request setPredicate:[NSPredicate predicateWithFormat:@"photo_name == %@",str]];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 0) {
        return nil;
    }
    
    if (array.count == 1) {
        ACI_PHOTO * photo = array[0];
        return photo.image_data;
    }
    return nil;
}
-(void) saveCurrentUserWithMap:(NSDictionary *) dict{
    NSManagedObjectContext* managedObjectContext = [self configCoredataContext];
    ACI_CURRENT_USER * dispatch = [self searchCurrentDispatch];
    if (dispatch) {
        dispatch.first_name = [dict objectForKey:@"first_name"];
        dispatch.last_name = [dict objectForKey:@"last_name"];
        dispatch.data_id = [dict objectForKey:@"id"];
        dispatch.phone = [dict objectForKey:@"phone"];
        dispatch.email = [dict objectForKey:@"email"];
        dispatch.username = [dict objectForKey:@"username"];
        dispatch.password = [dict objectForKey:@"password"];
        dispatch.category_id = [dict objectForKey:@"user_category_id"];
        dispatch.main_campus_id = [dict objectForKey:@"main_campus_id"];
        dispatch.main_campus_name = [dict objectForKey:@"main_campus_name"];
    }else{
        dispatch = (ACI_CURRENT_USER *)[NSEntityDescription insertNewObjectForEntityForName:@"ACI_CURRENT_USER" inManagedObjectContext:managedObjectContext];
        dispatch.first_name = [dict objectForKey:@"first_name"];
        dispatch.last_name = [dict objectForKey:@"last_name"];
        dispatch.data_id = [dict objectForKey:@"id"];
        dispatch.email = [dict objectForKey:@"email"];
        dispatch.phone = [dict objectForKey:@"phone"];
        dispatch.username = [dict objectForKey:@"username"];
        dispatch.password = [dict objectForKey:@"password"];
        dispatch.category_id = [dict objectForKey:@"user_category_id"];
        dispatch.main_campus_id = [dict objectForKey:@"main_campus_id"];
        dispatch.main_campus_name = [dict objectForKey:@"main_campus_name"];
        
    }
    NSError * error;
    [managedObjectContext save:&error];
}
-(ACI_CURRENT_USER *) searchCurrentDispatch{
    NSManagedObjectContext* managedObjectContext = [self configCoredataContext];
    NSFetchRequest *request = [ACI_CURRENT_USER fetchRequest];
    
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return [array objectAtIndex:0];
    }else{
        return nil;
    }
    
}
+(ACI_CURRENT_USER *) getCurrentDispatch{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [ACI_CURRENT_USER fetchRequest];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return [array objectAtIndex:0];
    }else{
        return nil;
    }
}

+(ACI_ORDER_PAYMENT *) getCurrentPayment{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [ACI_ORDER_PAYMENT fetchRequest];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return [array objectAtIndex:0];
    }else{
        return nil;
    }
}
+(void) saveCurrentPaymentWithDict:(NSDictionary *) info_dict{

    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    ACI_ORDER_PAYMENT * payment = [CurrentUserManager getCurrentPayment];
    if (payment) {
        payment.data_id = [info_dict objectForKey:@"order_id"];
     
        payment.total = [info_dict objectForKey:@"total"];
       
    }else{
        payment = (ACI_ORDER_PAYMENT *)[NSEntityDescription insertNewObjectForEntityForName:@"ACI_ORDER_PAYMENT" inManagedObjectContext:managedObjectContext];
        payment.data_id = [info_dict objectForKey:@"order_id"];
       
        payment.total = [info_dict objectForKey:@"total"];
    }
    NSError * error;
    [managedObjectContext save:&error];
}
-(void) updateCurrentUserWithPack:(NSDictionary *) pack{
    if (!connector) {
        connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    }
    [connector sendNormalRequestWithPack:pack andServiceCode:@"update_record" andCustomerTag:12];
}

-(void) loginWithUsername:(NSString *) username
              andPassword:(NSString *) password{
    NSDictionary * uploadpack =@{
                                 @"username": username,
                                 @"password": password,
                                 @"type": @"RAW"};
    if (!connector) {
        connector = [[AppDataSocketConnector alloc] initWithDelegate:self];
    }
    [connector sendRequestForAdminLogonWithPack:uploadpack];
    
    
}
-(void) dataSocketWillStartRequestWithTag:(NSInteger) tag
                           andCustomerTag:(NSInteger) c_tag{
    if (self.delegate) {
        [self.delegate currentUserManagerWillStartRequestWithTag:tag];
    }
    
}
-(void) dataSocketDidGetResponseWithTag:(NSInteger)tag
                         andCustomerTag:(NSInteger) c_tag{
    if (self.delegate) {
        [self.delegate currentUserManagerDidGetResponseWithTag:tag];
    }
    
}
-(void) dataSocketErrorWithTag:(NSInteger)tag andMessage: (NSString *) message
                andCustomerTag:(NSInteger) c_tag{
    if (self.delegate) {
        [self.delegate currentUserManagerError:message forTag:tag];
    }
    
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 12) {
        [self saveCurrentUserWithMap:[resultDic objectForKey:@"record"]];
        if (self.delegate) {
            [self.delegate currentUserManagerDidUpdateCurrentUser];
        }
    }
}
-(void) dataSocketDidLogonWithMessage:(NSString *)message
                              forUser:(NSDictionary *) anUser
                       andCustomerTag:(NSInteger) c_tag{
    [self saveCurrentUserWithMap:anUser];
    if (self.delegate) {
        [self.delegate currentUserManagerLogonSuccess];
    }
}

@end
