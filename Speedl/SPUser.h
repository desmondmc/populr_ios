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
typedef void (^SPFriendsResultBlock)(NSArray *friends, NSString *serverMessage);
typedef void (^SPFollowingResultBlock)(NSArray *following, NSString *serverMessage);
typedef void (^SPUserSearchResultBlock)(NSArray *users, NSString *serverMessage);
typedef void (^SPContactsResultBlock)(NSArray *contacts, NSString *serverMessage);

// JSON values

/* Warning! This is an objective-c representation of json objects. The way the code is currently structured,
 variabel names of this object must match their corresponding json properties.*/

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *token;      // This token was used for the Parse API
@property (strong, nonatomic) NSString *goToken;   // This token was used for go API
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSNumber *isFriend;

/* Gets the currently logged in user or returns nil of there isn't one logged-in/available */
+ (SPUser *) currentUser;

+ (void)logoutCurrentUser;

+ (void)signUpUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password block:(SPUserResultBlock)block;

+ (void)loginUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password block:(SPUserResultBlock)block;

+ (void)searchForUserInBackgroundWithString:(NSString *)searchString block:(SPUserSearchResultBlock)block;

+ (NSArray *)getMessageList;
+ (void)saveMessageList:(NSArray *)messageList;
+ (NSArray *)getFriendsArray;
+ (void)savePhoneNumber:(NSString *)phoneNumber;
+ (void)sendUserDataToWatch:(SPUser *)user;
+ (NSDictionary *)getUserDataForWatch:(SPUser *)user;

- (void)getMessagesInBackground:(SPMessagesResultBlock)block;

- (void)postMessageInBackground:(NSString *)message
                          users:(NSArray *)users
                          block:(SPNetworkResultBlock)block;

- (void)postPhoneNumberInBackground:(NSString *)phoneNumber
                        countryCode:(NSString *)countryCode
                              block:(SPNetworkResultBlock)block;

- (void)postContactDataInBackground:(NSArray *)contactData
                              block:(SPContactsResultBlock)block;

- (void)postFeedbackInBackground:(NSString *)feedback block:(SPNetworkResultBlock)block;

- (void)postDeviceTokenInBackground:(NSString *)token block:(SPNetworkResultBlock)block;

- (void)getFriendsInBackground:(SPFriendsResultBlock)block;

- (void)friendUserInBackground:(SPUser *)userToFollow block:(SPNetworkResultBlock)block;

- (void)unfriendUserInBackground:(SPUser *)userToFollow block:(SPNetworkResultBlock)block;

- (void)logoutUserInBackgroundWithBlock:(SPNetworkResultBlock)block;

@end
