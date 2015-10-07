//
//  AppDelegate.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-15.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPAppDelegate.h"
#import "SPMessageViewController.h"
#import "SPSignupViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "SPSorryViewController.h"
#import "SPDeviceToken.h"

@import CoreTelephony;

@interface SPAppDelegate ()

@end

@implementation SPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize Crashlytics
    [Crashlytics startWithAPIKey:@"a842d2a25e2a337bce79b6737d757ad5fc3c0df0"];
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    [[UITextView appearance] setTintColor:[UIColor whiteColor]];
    
    if ([SPUser currentUser]) {
        if ([SPUser currentUser].token != nil || [SPUser currentUser].goToken == nil) {
            [SPLoginRouter gotoLoggedOutView];
            
        } else {
            [SPLoginRouter gotoLoggedInViewAndNewUser:NO];
        }
        
    } else {
        [SPLoginRouter gotoLoggedOutView];
    }
    
    return YES;
}

// Called on sending side when a data transfer operation finished successfully or because of an error.
- (void)session:(WCSession * __nonnull)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(nullable NSError *)error {
    NSLog(@"Finished transfer");
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {    
    NSString *deviceTokenString = [deviceToken description];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[SPUser currentUser] postDeviceTokenInBackground:deviceTokenString block:nil];
    
    [SPDeviceToken saveDeviceToken:deviceTokenString];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary*)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    UIApplicationState state = [application applicationState];
    
    NSString *message = userInfo[@"aps"][@"alert"];
    
    if ([userInfo[@"type"] isEqualToString:@"new_message"] && [SPUser currentUser]) {
        if (state != UIApplicationStateActive) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSPGotoMessageListNotification
                                                                object:nil];
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            if (message) {
                [SPNotification showSuccessNotificationWithMessage:message inViewController:nil];
            }
            [[SPUser currentUser] getMessagesInBackground:^(NSArray *messages, NSString *serverMessage) {
                completionHandler(UIBackgroundFetchResultNewData);
            }];
        }
    } else if ([userInfo[@"type"] isEqualToString:@"new_friend"] && [SPUser currentUser]) {
        [SPNotification showSuccessNotificationWithMessage:message inViewController:nil];
        [[SPUser currentUser] getFriendsInBackground:^(NSArray *friends, NSString *serverMessage) {
            completionHandler(UIBackgroundFetchResultNewData);
        }];
    } else {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Decriment badge number.
    application.applicationIconBadgeNumber = 0;
    if ([SPUser currentUser] && [SPUser currentUser].token == nil) {
        [[SPUser currentUser] getMessagesInBackground:nil];
        [[SPUser currentUser] getFriendsInBackground:nil];
    }
    
    if ([WCSession isSupported]) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
        SPUser *currentUser = [SPUser currentUser];
        if (currentUser) {
            [SPUser sendUserDataToWatch:currentUser];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
