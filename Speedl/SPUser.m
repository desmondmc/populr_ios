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

#define kObjectIdKey @"objectId"
#define kUsernameKey @"username"
#define kPasswordKey @"password"

@implementation SPUser

+ (SPUser *) currentUser {
    SPUser *currentUser = [[SPUser alloc] init];
    currentUser.objectId = [[NSUserDefaults standardUserDefaults] stringForKey:kObjectIdKey];
    
    if (currentUser.objectId == nil) {
        return nil;
    }
    
    currentUser.username = [[NSUserDefaults standardUserDefaults] stringForKey:kUsernameKey];
    currentUser.password = [[NSUserDefaults standardUserDefaults] stringForKey:kPasswordKey];
    return currentUser;
}

+ (void) logoutCurrentUser {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kObjectIdKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUsernameKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) signUpUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password block:(SPUserResultBlock)block {
    
    NSString *url = kAPISignUpUrl;
    
    NSDictionary *userDictionary = @{@"username":username, @"password":password};
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:userDictionary];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPUser checkResponseCodeForError:httpResponse.statusCode data:data];
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

+ (void) loginUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password block:(SPUserResultBlock)block {
    NSString *url = kAPILoginUrl;
    
    NSDictionary *userDictionary = @{@"username":username, @"password":password};
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:userDictionary];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPUser checkResponseCodeForError:httpResponse.statusCode data:data];
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

- (void) getMessagesInBackground:(SPMessagesResultBlock)block {
    NSString *url = kAPIMessagesUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPUser checkResponseCodeForError:httpResponse.statusCode data:data];
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

+ (NSString *) checkResponseCodeForError:(NSInteger)code data:(NSData *)data {
    if (code != 200) {
        NSError *error;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (parsedObject[@"message"] != nil) {
            return parsedObject[@"message"];
        } else {
            return kGenericErrorString;
        }
    }
    return nil;
}

#pragma mark Private

//Store the user on the disk, essentially log them in on the device.
+ (void) saveUserToDisk:(SPUser *)user {
    [[NSUserDefaults standardUserDefaults] setObject:user.objectId forKey:kObjectIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:kUsernameKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.password forKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
