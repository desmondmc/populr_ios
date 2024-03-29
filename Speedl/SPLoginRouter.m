//
//  LoginRouter.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-03-29.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPLoginRouter.h"
#import "SPSignupViewController.h"
#import "SPContainerViewController.h"
#import "SPComposeViewController.h"
#import "SPMessageViewController.h"
#import "SPFriendsViewController.h"
#import "SPMessageListViewController.h"
#import "SPSorryViewController.h"
#import "SPPhoneNumberViewController.h"

@implementation SPLoginRouter

+ (SPContainerViewController *) getLoggedInViewController {
    
    SPComposeViewController *composeViewController = [[SPComposeViewController alloc] init];
    SPMessageListViewController *leftViewController  = [[SPMessageListViewController alloc] init];
    SPFriendsViewController *rightViewController = [[SPFriendsViewController alloc] init];

    SPContainerViewController *contrainterViewController = [[SPContainerViewController alloc] init];
    
    composeViewController.containerViewController = contrainterViewController;
    leftViewController.containerViewController = contrainterViewController;
    rightViewController.containerViewController = contrainterViewController;
    
    [contrainterViewController addDelegate:composeViewController];
    [contrainterViewController addDelegate:leftViewController];
    [contrainterViewController addDelegate:rightViewController];
    
    NSArray *views = @[leftViewController, composeViewController, rightViewController];
    
    [contrainterViewController setViewControllerArray:views.mutableCopy];
    
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    contrainterViewController.pageController = pageViewController;
    contrainterViewController.pageController.delegate = contrainterViewController;
    
    return contrainterViewController;
}

+ (void) gotoLoggedInViewAndNewUser:(BOOL)newUser {
    UIApplication *application = [UIApplication sharedApplication];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    if (kAppDel.window == nil) {
        kAppDel.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    // This is to setup the notification block.
    [[SPUser currentUser] getMessagesInBackground:nil];
    [[SPUser currentUser] getFriendsInBackground:nil];
    
    SPContainerViewController *containerViewController = [self getLoggedInViewController];
    [containerViewController goToMessageViewController];
    kAppDel.window.rootViewController = containerViewController;
    [kAppDel.window makeKeyAndVisible];
    
    if (newUser) {
        SPPhoneNumberViewController *phoneViewController = [[SPPhoneNumberViewController alloc] initWithType:SPPhoneNumberViewTypeModel];
        
        
        [kAppDel.window.rootViewController presentViewController:phoneViewController animated:YES completion:nil];
    }
}



+ (void) gotoLoggedOutView {
    if (kAppDel.window == nil) {
        kAppDel.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    kAppDel.window.rootViewController = [[SPSignupViewController alloc] init];
    [kAppDel.window makeKeyAndVisible];
    
    // This is here for the transition from 1.x -> 2.0 when we wiped the database.
    // If they have a token and they are logging out it means we've kicked them
    // out of the app.
    if ([SPUser currentUser].token != nil) {
        [kAppDel.window.rootViewController presentViewController:[SPSorryViewController new] animated:YES completion:nil];
    }
}

@end
