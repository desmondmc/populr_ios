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

@implementation SPUser

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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kObjectIdKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUsernameKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
                
                NSArray *messages = [SPMessageBuilder messagesFromJSON:data error:&error];
                
                block(messages, nil);
                return;
            }
        });
    }];
}

- (void)postMessageInBackground:(NSString *)message block:(SPNetworkResultBlock)block {
    NSString *url = kAPIPostMessageUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    
    NSDictionary *userDictionary = @{@"message":message};
    
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
            if (block) {
                NSError *error;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(nil, remoteError);
                    return;
                }
                
                NSArray *followers = [SPUserBuilder usersFromJSON:data error:&error];
                
                block(followers, nil);
                return;
            }
        });
    }];
}

- (void)getFollowingInBackground:(SPFollowingResultBlock)block {
    NSString *url = kAPIFollowingUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    
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
                
                NSArray *followers = [SPUserBuilder usersFromJSON:data error:&error];
                
                block(followers, nil);
                return;
            }
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

@end
