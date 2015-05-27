//
//  SPUser.h
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNetworkObject.h"
#import "SPMessage.h"



@interface SPUser : SPNetworkObject

typedef void (^SPUserResultBlock)(SPUser *user, NSString *serverMessage);
typedef void (^SPFollowersResultBlock)(NSArray *followers, NSString *serverMessage);
typedef void (^SPFollowingResultBlock)(NSArray *following, NSString *serverMessage);
typedef void (^SPUserSearchResultBlock)(NSArray *users, NSString *serverMessage);

// JSON values

/* Warning! This is an objective-c representation of json objects. The way the code is currently structured,
 variabel names of this object must match their corresponding json properties.*/

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSNumber *following;

/* Gets the currently logged in user or returns nil of there isn't one logged-in/available */
+ (SPUser *) currentUser;

+ (void)logoutCurrentUser;

+ (void)signUpUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password block:(SPUserResultBlock)block;

+ (void)loginUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password block:(SPUserResultBlock)block;

+ (void)searchForUserInBackgroundWithString:(NSString *)searchString block:(SPUserSearchResultBlock)block;

- (void)getMessagesInBackground:(SPMessagesResultBlock)block;

- (void)postMessageInBackground:(NSString *)message block:(SPNetworkResultBlock)block;

- (void)getFollowersInBackground:(SPFollowersResultBlock)block;

- (void)getFollowingInBackground:(SPFollowingResultBlock)block;

- (void)followUserInBackground:(SPUser *)userToFollow block:(SPNetworkResultBlock)block;

@end
