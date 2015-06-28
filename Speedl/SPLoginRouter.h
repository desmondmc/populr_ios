//
//  LoginRouter.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-03-29.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPLoginRouter : NSObject

+ (void) gotoLoggedInViewAndShowMessages:(BOOL)showMessages;
+ (void) gotoLoggedOutView;

@end
