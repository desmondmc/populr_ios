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

#define kObjectIdKey    @"objectId"
#define kUsernameKey    @"username"
#define kPasswordKey    @"password"
#define kTokenKey       @"token"
#define kMessagesKey    @"messages"
#define kFollowersKey   @"followers"
#define kFollowingsKey  @"followings"

@implementation SPUser

#pragma mark - Current User Persistent Store

+ (SPUser *) currentUser {
    SPUser *currentUser = [[SPUser alloc] init];
    currentUser.objectId = [[NSUserDefaults standardUserDefaults] stringForKey:kObjectIdKey];
    
    if (currentUser.objectId == nil) {
        return nil;
    }
    
    currentUser.username = [[NSUserDefaults standardUserDefaults] stringForKey:kUsernameKey];
    currentUser.password = [[NSUserDefaults standardUserDefaults] stringForKey:kPasswordKey];
    currentUser.token = [[NSUserDefaults standardUserDefaults] stringForKey:kTokenKey];
    
    return currentUser;
}

+ (void)logoutCurrentUser {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMessagesKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kObjectIdKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUsernameKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

+ (NSArray *)getFollowersArray {
    return [self getUserArrayFromPersistentStore:kFollowersKey];
}

+ (NSArray *)getFollowingArray {
    return [self getUserArrayFromPersistentStore:kFollowingsKey];
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

+ (void)saveFollowersList:(NSArray *)followersArray {
    [self saveUserArrayToPersistentStore:followersArray key:kFollowersKey];
}

+ (void)saveFollowingList:(NSArray *)followingArray {
    [self saveUserArrayToPersistentStore:followingArray key:kFollowingsKey];
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
                    [self saveUserToParse:newUser];
                    
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
                    [self saveUserToParse:user];
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

+ (void)searchForUserInBackgroundWithString:(NSString *)searchString block:(SPUserSearchResultBlock)block {
    NSString *url = kAPIUserSearchUrl;
    
    url = [url stringByAppendingString:searchString];
    
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
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    
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
    
    NSString *url = kAPIPostMessageUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    NSDictionary *userDictionary = nil;
    if ([users count] > 0) {
        userDictionary = @{@"message":message,
                           @"toUsers": users};
    } else {
        userDictionary = @{@"message":message};
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

- (void)postFeedbackInBackground:(NSString *)feedback block:(SPNetworkResultBlock)block {
    NSString *url = kAPIPostFeedbackUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    
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

- (void)getFollowersInBackground:(SPFollowersResultBlock)block {
    NSString *url = kAPIFollowersUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    
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
            
            NSArray *followers = [SPUserBuilder usersFromJSON:data error:&error];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSPFollowersCountNotification
                                                                object:@(followers.count)];
            [SPUser saveFollowersList:followers];
            
            if (block) {
                block(followers, nil);
            }
            return;
            
        });
    }];
}

- (void)getFollowingInBackground:(SPFollowingResultBlock)block {
    NSString *url = kAPIFollowingUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    
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
            
            NSArray *following = [SPUserBuilder usersFromJSON:data error:&error];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSPFollowingCountNotification
                                                                object:@(following.count)];
            [SPUser saveFollowingList:following];
            
            if (block) {
                block(following, nil);
            }
            return;
            
        });
    }];
}

- (void)followUserInBackground:(SPUser *)userToFollow block:(SPNetworkResultBlock)block
{
    NSString *url = kAPIFollowUserUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{target-id}" withString:[userToFollow objectId]];
    url = [url stringByReplacingOccurrencesOfString:@"{source-id}" withString:[self objectId]];
    
    NSURLRequest *request = [SPNetworkHelper putRequestWithURL:url andDictionary:nil];
    
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

- (void)unfollowUserInBackground:(SPUser *)userToFollow block:(SPNetworkResultBlock)block {
    NSString *url = kAPIFollowUserUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{target-id}" withString:[userToFollow objectId]];
    url = [url stringByReplacingOccurrencesOfString:@"{source-id}" withString:[self objectId]];
    
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
    [[NSUserDefaults standardUserDefaults] setObject:user.password forKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.token forKey:kTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveUserToParse:(SPUser *)user {
    // Store the deviceToken in the current Installation and save it to Parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSString *userObjectId = [user objectId];
    
    [currentInstallation setValue:userObjectId forKey:@"userId"];
    [currentInstallation saveInBackground];
}

#define kUserObjectIdKey @"SPUserObjectIdKey"
#define kUsernameDataKey @"SPUsernameDataKey"

#pragma mark - NSUserDefaults

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:[self objectId] forKey:kObjectIdKey];
    [encoder encodeObject:_username forKey:kUsernameDataKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        [self setObjectId:[decoder decodeObjectForKey:kObjectIdKey]];
        _username = [decoder decodeObjectForKey:kUsernameDataKey];
    }
    return self;
}

@end
