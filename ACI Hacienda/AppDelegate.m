//
//  AppDelegate.m
//  ACI Hacienda
//
//  Created by 姚远 on 7/8/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "AppDelegate.h"
@import SquarePointOfSaleSDK;
#import "AppDataSocketConnector.h"
#import "CYFunctionSet.h"
#import "OrderDetailViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options;
{
    NSString *const sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    // Make sure the URL comes from Square Register; fail if it doesn't.
    if (![sourceApplication hasPrefix:@"com.squareup.square"]) {
        return NO;
    }
    
    // The response data is encoded in the URL and can be decoded as an SCCAPIResponse.
    NSError *decodeError = nil;
    SCCAPIResponse *const response = [SCCAPIResponse responseWithResponseURL:url error:&decodeError];
    
    NSString *message = nil;
    //NSString *title = nil;
    
    OrderDetailViewController * odvc = (OrderDetailViewController *) [self topViewController];
    
    if (response.isSuccessResponse && !decodeError) {
        //title = @"Success!";
        message = [NSString stringWithFormat:@"Request succeeded: %@", response];
        AppDataSocketConnector * connector = [[AppDataSocketConnector alloc] initWithDelegate:self];

        ACI_ORDER_PAYMENT * payment = [CurrentUserManager getCurrentPayment];
        ACI_CURRENT_USER * user = [CurrentUserManager getCurrentDispatch];
        NSDictionary * dict = @{
                                @"order_id":payment.data_id,
                                @"receipt":response.transactionID,
                                @"cby":user.data_id,
                                @"pdate":[CYFunctionSet getCurrentFormatString]
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"set_order_paid" andCustomerTag:1 andWillStartBlock:^(NSInteger c_tag){
            //[self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            //[self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            //[self showAlertWithTittle:@"ERROR" forMessage:message];
            [odvc showErrorMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            //[self requestStaffInfo];
            [odvc refreshOrderDetail];
        }];
        
        


                
        
    } else {
        //title = @"Error!";
        
        // An invalid response message error is distinct from a successfully decoded error.
        NSError *const errorToPresent = response ? response.error : decodeError;
        message = [NSString stringWithFormat:@"Request failed: %@", [errorToPresent localizedDescription]];
        [odvc showErrorMessage:message];
    }
    
    
    NSLog(@"PAYMENT RESPONSE: %@",message);
    
    return YES;
}

- (UIViewController *)topViewController{
    UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    UINavigationController * navController = (UINavigationController *) tabBarController.selectedViewController;
    UIViewController *lastViewController = [[navController viewControllers] lastObject];
    return [self topViewController:lastViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewController:tabBarController.selectedViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"ACI_Hacienda"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
