//
//  SPMessageBuilder.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-05.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessageBuilder.h"

@implementation SPMessageBuilder

+ (NSArray *)messagesFromJSON:(NSData *)jsonData error:(NSError **)error {
    NSError *localError = nil;
    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    
    NSDictionary *parsedObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&localError];
    
    for (NSDictionary *parsedObject in parsedObjects[@"_embedded"][@"messages"]) {
        if (localError != nil) {
            *error = localError;
            return nil;
        }
        
        SPMessage *message = [[SPMessage alloc] init];
        
        if ([parsedObject objectForKey:@"id"] != nil) {
            message.objectId = [parsedObject objectForKey:@"id"];
        }
        
        for (NSString *key in parsedObject) {
            if ([message respondsToSelector:NSSelectorFromString(key)]) {
                [message setValue:[parsedObject valueForKey:key] forKey:key];
            }
        }
        
        [messagesArray addObject:message];
    }
    
    return messagesArray;
}

@end
