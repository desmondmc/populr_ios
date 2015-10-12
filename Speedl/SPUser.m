//
//  SPUser.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPUser.h"
#import "SPUserBuilder.h"
#import "SPMessageBuilder.h"
#import "SPNetworkHelper.h"
#import <WatchConnectivity/WCSession.h>

#define kObjectIdKey    @"objectId"
#define kUsernameKey    @"username"
#define kGoTokenKey     @"goToken"
#define kPasswordKey    @"password"
#define kTokenKey       @"token"
#define kMessagesKey    @"messages"
#define kFriendsKey     @"friends"
#define kPhoneKey       @"phone"

@implementation SPUser

#pragma mark - Current User Persistent Store

+ (SPUser *) currentUser {
    SPUser *currentUser = [[SPUser alloc] init];
    currentUser.objectId = [[NSUserDefaults standardUserDefaults] valueForKey:kObjectIdKey];
    
    if (currentUser.objectId == nil) {
        return nil;
    }
    
    currentUser.username = [[NSUserDefaults standardUserDefaults] stringForKey:kUsernameKey];
    currentUser.password = [[NSUserDefaults standardUserDefaults] stringForKey:kPasswordKey];
    currentUser.token = [[NSUserDefaults standardUserDefaults] stringForKey:kTokenKey];
    currentUser.goToken = [[NSUserDefaults standardUserDefaults] stringForKey:kGoTokenKey];
    currentUser.phoneNumber = [[NSUserDefaults standardUserDefaults] stringForKey:kPhoneKey];
    
    return currentUser;
}

+ (void)logoutCurrentUser {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

#pragma mark - Message List Persistent Store

+ (NSArray *)getMessageList {
    if (kGlobalMessageArray) {
        return kGlobalMessageArray;
    }
    NSMutableArray *messagesArray = [NSMutableArray new];
    NSArray *encodedMessages = [[NSUserDefaults standardUserDefaults] arrayForKey:kMessagesKey];
    for (NSData *encodedMessage in encodedMessages) {
        SPMessage *message = [NSKeyedUnarchiver unarchiveObjectWithData:encodedMessage];
        [messagesArray addObject:message];
    }
    
    return messagesArray;
}

+ (void)saveMessageList:(NSArray *)messageList {
    [[SPMessageHolder sharedInstance] setMessageArray:messageList];
    NSMutableArray *encodedMessageList = [NSMutableArray new];
    
    for (SPMessage *message in messageList) {
        NSData *encodedMessage = [NSKeyedArchiver archivedDataWithRootObject:message];
        [encodedMessageList addObject:encodedMessage];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:encodedMessageList forKey:kMessagesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Friends Lists Persistent Store

+ (NSArray *)getFriendsArray {
    return [self getUserArrayFromPersistentStore:kFriendsKey];
}

+ (NSArray *)getUserArrayFromPersistentStore:(NSString *)key {
    NSMutableArray *usersArray = [NSMutableArray new];
    NSArray *encodedUsers = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
    for (NSData *encodedUser in encodedUsers) {
        SPUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedUser];
        [usersArray addObject:user];
    }
    return usersArray;
}

+ (void)savePhoneNumber:(NSString *)phoneNumber {
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:kPhoneKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveFriendsList:(NSArray *)friendsArray {
    [self saveUserArrayToPersistentStore:friendsArray key:kFriendsKey];
}

+ (void)saveUserArrayToPersistentStore:(NSArray *)userArray key:(NSString *)key {
    NSMutableArray *encodedUserList = [NSMutableArray new];
    
    for (SPUser *user in userArray) {
        NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
        [encodedUserList addObject:encodedUser];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:encodedUserList forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Network calls

+ (void)signUpUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password block:(SPUserResultBlock)block {
    if (![[SPReachability sharedInstance] isReachable]) {
        if (block) {
            block(nil,@"Network error");
        }
        return;
    }
    
    NSString *url = kAPISignUpUrl;
    
    NSDictionary *userDictionary = @{@"username":username, @"password":password};
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:userDictionary];

    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(nil, remoteError);
                    return;
                }
                
                
                SPUser *newUser = [SPUserBuilder userFromJSON:data error:&error];
                if (newUser && error == nil && newUser.objectId != nil) {
                    [self saveUserToDisk:newUser];
                    [self sendUserDataToWatch:newUser];
                } else {
                    block(nil, kGenericErrorString);
                    return;
                }
                block(newUser, nil);
                return;
            }
        });
    }];
}

+ (void)loginUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password block:(SPUserResultBlock)block {
    if (![[SPReachability sharedInstance] isReachable]) {
        if (block) {
            block(nil,@"Network error");
        }
        return;
    }
    
    NSString *url = kAPILoginUrl;
    
    NSDictionary *userDictionary = @{@"username":username, @"password":password};
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:userDictionary];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(nil, remoteError);
                    return;
                }
                
                SPUser *user = [SPUserBuilder userFromJSON:data error:&error];
                if (user && error == nil && user.objectId != nil) {
                    [self saveUserToDisk:user];
                    [self sendUserDataToWatch:user];
                } else {
                    block(nil, kGenericErrorString);
                    return;
                }
                block(user, nil);
                return;
            }
        });
        
    }];
}

+ (void)sendUserDataToWatch:(SPUser *)user {
    if ([WCSession isSupported]) {
        if (user.objectId && user.goToken) {
            NSDictionary *applicationDict = @{@"user_id": [user.objectId stringValue],
                                              @"auth_key": user.goToken};// Create a dict of application data
            [[kAppDel session] transferUserInfo:applicationDict];
        }
    }
}

+ (void)searchForUserInBackgroundWithString:(NSString *)searchString block:(SPUserSearchResultBlock)block {
    if (![[SPReachability sharedInstance] isReachable]) {
        if (block) {
            block(nil,@"Network error");
        }
        return;
    }
    
    NSString *url = kAPIUserSearchUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{term}" withString:searchString];
    
    NSURLRequest *request = [SPNetworkHelper getRequestWithURL:url];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(nil, remoteError);
                    return;
                }
                
                NSArray *users = [SPUserBuilder usersFromJSON:data error:&error];
                
                block(users, nil);
                return;
            }
        });
    }];
}

- (void)getMessagesInBackground:(SPMessagesResultBlock)block {
    NSString *url = kAPIMessagesUrl;
    
    // Attempt to prevent cacheing
    url = [url stringByAppendingString:[SPNetworkHelper getTimeStampString]];
    
    NSURLRequest *request = [SPNetworkHelper getRequestWithURL:url];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (block) {
                    block(nil, error.description);
                }
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
            if (remoteError) {
                if (block) {
                    block(nil, remoteError);
                }
                return;
            }
            
            NSError *error = nil;
            
            NSArray *messages = [SPMessageBuilder messagesFromJSON:data error:&error];
            
            if (error) {
                if (block) {
                    NSLog(@"Error: %@", [error localizedDescription]);
                    block(nil, [error localizedDescription]);
                }
            }
            [SPUser saveMessageList:messages];
            NSLog(@"Posting Message Count: %lu", (unsigned long)messages.count);
            [[NSNotificationCenter defaultCenter] postNotificationName:kSPMessageCountNotification
                                                                object:@(messages.count)];
            if (block) {
                block(messages, nil);
            }
            
            return;
        });
    }];
}

- (void)postMessageInBackground:(NSString *)message
                          users:(NSArray *)users
                          block:(SPNetworkResultBlock)block {
    if (![[SPReachability sharedInstance] isReachable]) {
        if (block) {
            block(NO,@"Network error");
        }
        return;
    }
    
    NSString *url = kAPIPostMessageUrl;
    
    NSDictionary *userDictionary = nil;
    if ([users count] > 0) {
        userDictionary = @{@"message":message,
                           @"to_users": users,
                           @"type": @"direct"};
    } else {
        userDictionary = @{@"message":message,
                           @"type": @"public"};
    }

    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:userDictionary];

    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(NO, remoteError);
                    return;
                }
                
                block(YES, nil);
                return;
            }
        });
        
    }];
}

- (void)postPhoneNumberInBackground:(NSString *)phoneNumber
                              countryCode:(NSString *)countryCode
                              block:(SPNetworkResultBlock)block {
    if (![[SPReachability sharedInstance] isReachable]) {
        if (block) {
            block(NO, @"Network error");
        }
        return;
    }
    
    NSString *url = kAPIPostPhoneUrl;
    
    NSDictionary *userDictionary = @{@"phone_number":phoneNumber,
                                     @"country_code": countryCode,
                                     @"type": @"direct"};
    
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:userDictionary];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(NO, remoteError);
                    return;
                }
                
                block(YES, nil);
                return;
            }
        });
        
    }];
}

- (void)postContactDataInBackground:(NSArray *)contactData
                              block:(SPContactsResultBlock)block {
    
    NSString *url = kAPIPostContactDataUrl;
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url array:contactData];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(nil, remoteError);
                    return;
                }
                
                NSArray *users = [SPUserBuilder usersFromJSON:data error:&error];
                
                // Sort data by isFriend.
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isFriend"
                                                             ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray;
                sortedArray = [users sortedArrayUsingDescriptors:sortDescriptors];
                
                block(sortedArray, nil);
                return;
            }
        });
        
    }];
}

- (void)postFeedbackInBackground:(NSString *)feedback block:(SPNetworkResultBlock)block {
    if (![[SPReachability sharedInstance] isReachable]) {
        if (block) {
            block(NO, @"Network error");
        }
        return;
    }
    
    NSString *url = kAPIPostFeedbackUrl;
    
    NSDictionary *userDictionary = @{@"feedback": feedback};
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:userDictionary];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(NO, remoteError);
                    return;
                }
                
                block(YES, nil);
                return;
            }
        });
        
    }];
}

- (void)postDeviceTokenInBackground:(NSString *)token block:(SPNetworkResultBlock)block {
    NSString *url = kAPIDeviceTokenUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{token}" withString:token];
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:nil];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(NO, remoteError);
                    return;
                }
                
                block(YES, nil);
                return;
            }
        });
        
    }];
}

- (void)logoutUserInBackgroundWithBlock:(SPNetworkResultBlock)block {
    NSString *url = kAPILogoutUrl;
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:nil];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(NO, remoteError);
                    return;
                }
                
                block(YES, nil);
                return;
            }
        });
        
    }];
}

- (void)getFriendsInBackground:(SPFriendsResultBlock)block {
    if (![[SPReachability sharedInstance] isReachable]) {
        NSLog(@"UNREACHABLE NETWORK!");
        if (block) {
            block(nil,@"Network error");
        }
        return;
    }
    
    NSString *url = kAPIFriendsUrl;
    
    NSURLRequest *request = [SPNetworkHelper getRequestWithURL:url];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
            if (remoteError) {
                if (block) {
                    block(nil, remoteError);
                }
                return;
            }
            
            NSArray *friends = [SPUserBuilder usersFromJSON:data error:&error];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSPFriendsCountNotification
                                                                object:@(friends.count)];
            [SPUser saveFriendsList:friends];
            
            if (block) {
                block(friends, nil);
            }
            return;
            
        });
    }];
}

- (void)friendUserInBackground:(SPUser *)userToFriend block:(SPNetworkResultBlock)block
{
    if (![[SPReachability sharedInstance] isReachable]) {
        if (block) {
            block(NO,@"Network error");
        }
        return;
    }
    
    NSString *url = kAPIFriendUserUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[userToFriend objectId].stringValue];
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:nil];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(NO, remoteError);
                    return;
                }
                
                [self getFriendsInBackground:nil];
                
                block(YES, nil);
                return;
            }
        });
    }];
}

- (void)unfriendUserInBackground:(SPUser *)userToUnfriend block:(SPNetworkResultBlock)block {
    if (![[SPReachability sharedInstance] isReachable]) {
        if (block) {
            block(NO,@"Network error");
        }
        return;
    }
    
    NSString *url = kAPIUnfriendUserUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[userToUnfriend objectId].stringValue];
    
    NSURLRequest *request = [SPNetworkHelper deleteRequestWithURL:url];
    
    [SPNetworkHelper sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(NO, remoteError);
                    return;
                }
                
                [self getFriendsInBackground:nil];
                block(YES, nil);
                return;
            }
        });
    }];
}



#pragma mark Private

//Store the user on the disk, essentially log them in on the device.
+ (void)saveUserToDisk:(SPUser *)user {
    [[NSUserDefaults standardUserDefaults] setObject:user.objectId forKey:kObjectIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:kUsernameKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.goToken forKey:kGoTokenKey];
    if (![user.phoneNumber isEqual:[NSNull null]]) {
        [[NSUserDefaults standardUserDefaults] setObject:user.phoneNumber forKey:kPhoneKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#define kUserObjectIdKey @"SPUserObjectIdKey"
#define kUsernameDataKey @"SPUsernameDataKey"
#define kIsFriendsDataKey @"SPIsFriendsDataKey"

#pragma mark - NSUserDefaults

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:[self objectId] forKey:kObjectIdKey];
    [encoder encodeObject:_username forKey:kUsernameDataKey];
    [encoder encodeObject:_isFriend forKey:kIsFriendsDataKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        [self setObjectId:[decoder decodeObjectForKey:kObjectIdKey]];
        _username = [decoder decodeObjectForKey:kUsernameDataKey];
        _isFriend = [decoder decodeObjectForKey:kIsFriendsDataKey];
    }
    return self;
}

@end
