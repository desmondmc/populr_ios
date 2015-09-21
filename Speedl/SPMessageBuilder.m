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
    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    
    NSDictionary *parsedObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
    
    if (!parsedObjects[@"data"]) {
        *error = [NSError errorWithDescription:@"Response didn't include Messages"];
        return nil;
    }
    if (*error) {
        return nil;
    }
    
    if (parsedObjects[@"data"] == [NSNull null]) {
        return messagesArray;
    }
    
    for (NSDictionary *parsedObject in parsedObjects[@"data"]) {
        SPMessage *message = [[SPMessage alloc] init];
        
        if ([parsedObject objectForKey:@"id"] != nil) {
            message.objectId = [parsedObject objectForKey:@"id"];
        }
        message.message = parsedObject[@"message"];
        message.type = parsedObject[@"type"];
        message.fromUsername = parsedObject[@"from_username"];
        message.timestamp = parsedObject[@"created_at"];
        
        [messagesArray addObject:message];
    }
    
    return messagesArray;
}

@end
