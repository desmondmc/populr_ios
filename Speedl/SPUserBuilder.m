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
    
    if ([parsedObject objectForKey:@"id"] != nil) {
        user.objectId = [parsedObject objectForKey:@"id"];
    }
        
    for (NSString *key in parsedObject) {
        if ([user respondsToSelector:NSSelectorFromString(key)]) {
            [user setValue:[parsedObject valueForKey:key] forKey:key];
        }
    }
    
    return user;
}

@end
