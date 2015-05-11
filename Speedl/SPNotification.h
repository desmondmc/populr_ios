//
//  SPNotification.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-11.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPNotification : NSObject

+ (void)showErrorNotificationWithMessage:(NSString *)message inViewController:(UIViewController *)viewController;
+ (void)showSuccessNotificationWithMessage:(NSString *)message inViewController:(UIViewController *)viewController;

@end
