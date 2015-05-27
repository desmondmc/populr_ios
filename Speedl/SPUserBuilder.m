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
    
    if (parsedObject[@"user"][@"id"] != nil) {
        user.objectId = parsedObject[@"user"][@"id"];
        user.token = parsedObject[@"token"];
        user.username = parsedObject[@"user"][@"username"];
    }
    
    return user;
}

+ (NSArray *)usersFromJSON:(NSData *)jsonData error:(NSError **)error
{
    NSMutableArray *followersArray = [[NSMutableArray alloc] init];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    for (NSDictionary *userDictionary in parsedObject[@"users"]) {
        SPUser *user = [[SPUser alloc] init];
        user.objectId = userDictionary[@"user"][@"objectId"];
        user.username = userDictionary[@"user"][@"username"];
        user.following = userDictionary[@"following"];
        [followersArray addObject:user];
    }
    
    return followersArray;
}

@end
