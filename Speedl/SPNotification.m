//
//  SPNotification.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-11.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPNotification.h"
#import "CSNotificationView.h"
#import "TSMessage.h"
#import <TSMessages/TSMessageView.h>

@implementation SPNotification

+ (void)showErrorNotificationWithMessage:(NSString *)message inViewController:(UIViewController *)viewController {
    [self setupAppearance];
    
    [TSMessage showNotificationInViewController:viewController
                                          title:message
                                       subtitle:@""
                                           type:TSMessageNotificationTypeError
                                       duration:1.5];
}

+ (void)showSuccessNotificationWithMessage:(NSString *)message inViewController:(UIViewController *)viewController {
    [self setupAppearance];
    if (!viewController) {
        viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    [TSMessage showNotificationInViewController:viewController
                                          title:message
                                       subtitle:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:0.5];
}

+ (void)setupAppearance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{

    });
}

@end
