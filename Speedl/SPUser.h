//
//  SPUser.h
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNetworkObject.h"



@interface SPUser : SPNetworkObject

typedef void (^SPUserResultBlock)(SPUser *user, NSString *message);

// JSON values

/* Warning! This is an objective-c representation of json objects. The way the code is currently structured,
 variabel names of this object must match their corresponding json properties.*/

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

/* Gets the currently logged in user or returns nil of there isn't one logged-in/available */
+ (SPUser *) currentUser;

+ (void) logoutCurrentUser;

+ (void) signUpUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password andBlock:(SPUserResultBlock)block;

+ (void) loginUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password andBlock:(SPUserResultBlock)block;


@end
