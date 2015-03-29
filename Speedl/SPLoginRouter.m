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

@implementation SPLoginRouter

+ (UIViewController *) getLoggedInViewController {
    
    SPComposeViewController *composeViewController = [[SPComposeViewController alloc] init];
    SPMessageViewController *leftViewController  = [[SPMessageViewController alloc] init];

    NSArray *views = @[leftViewController, composeViewController];
    
    SPContainerViewController *contrainterViewController = [[SPContainerViewController alloc] init];
    [contrainterViewController setViewControllerArray:views.mutableCopy];
    
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    contrainterViewController.pageController = pageViewController;
    
    return contrainterViewController;
}

+ (void) gotoLoggedOutView {
    kAppDel.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    kAppDel.window.rootViewController = [[SPSignupViewController alloc] init];
    [kAppDel.window makeKeyAndVisible];
}

@end
