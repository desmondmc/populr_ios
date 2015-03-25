//
//  SPUser.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPUser.h"
#import "SPUserBuilder.h"
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

+ (void) signUpUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password andBlock:(SPUserResultBlock)block {
    
    NSString *url = kAPILoginUrl;
    
    NSDictionary *userDictionary = @{@"username":username, @"password":password};
    
    NSURLRequest *request = [SPNetworkHelper putRequestWithURL:url andDictionary:userDictionary];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                SPUser *newUser = [SPUserBuilder userFromJSON:data error:&error];
                if (newUser && error == nil) {
                    [self saveUserToDisk:newUser];
                }
                block(newUser, error);
            }
        });
        
    }];
}

+ (void) loginUserInBackgroundWithUsername:(NSString *)username password:(NSString *)password andBlock:(SPUserResultBlock)block {
    NSString *url = kAPILoginUrl;
    
    NSDictionary *userDictionary = @{@"username":username, @"password":password};
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:userDictionary];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error;
                SPUser *user = [SPUserBuilder userFromJSON:data error:&error];
                if (user && error == nil) {
                    [self saveUserToDisk:user];
                }
                block(user, error);
            }
        });
        
    }];
}

#pragma mark Private

//Store the user on the disk essentially log them in on the device.
+ (void) saveUserToDisk:(SPUser *)user {
    [[NSUserDefaults standardUserDefaults] setObject:user.objectId forKey:kObjectIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:kUsernameKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.password forKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
