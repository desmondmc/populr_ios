//
//  SPUserBuilder.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPUserBuilder.h"

@implementation SPUserBuilder

+ (SPUser *)userFromJSON:(NSData *)jsonData error:(NSError **)error {
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    SPUser *user = [[SPUser alloc] init];
    
    if (parsedObject[@"data"] != nil) {
        user.objectId = parsedObject[@"data"][@"id"];
        user.username = parsedObject[@"data"][@"username"];
        user.phoneNumber = parsedObject[@"data"][@"phone_number"];
        user.goToken = parsedObject[@"data"][@"new_token"];
    }
    
    return user;
}

+ (NSArray *)usersFromJSON:(NSData *)jsonData error:(NSError **)error
{
    NSMutableArray *friendsArray = [[NSMutableArray alloc] init];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    if (parsedObject[@"data"] == [NSNull null]) {
        return friendsArray;
    }
    
    for (NSDictionary *userDictionary in parsedObject[@"data"]) {
        SPUser *user = [[SPUser alloc] init];
        user.objectId = userDictionary[@"id"];
        user.username = userDictionary[@"username"];
        user.isFriend = userDictionary[@"friends"];
        user.phoneNumber = userDictionary[@"phone_number"];
        [friendsArray addObject:user];
    }
    
    return friendsArray;
}

@end
