//
//  SPMessage.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-05.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessage.h"
#import "SPNetworkHelper.h"

@import Firebase;

@implementation SPMessage

// date is a derived from timestamp
- (NSDate *)date {
    if (self.timestamp == nil || [self.timestamp isEqualToString:@""]) {
        return nil;
    }
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyymmdd"];
    NSDate *date = [dateFormat dateFromString:self.timestamp];
    
    return date;
}

-(void)setMessage:(NSString *)message {
    message = [[message componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    _message = message;
}

- (void)markMessageAsReadInBackground:(SPNetworkResultBlock)block {
    NSString *url = kAPIReadMessageUrl;
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self.objectId stringValue]];
    
    NSURLRequest *request = [SPNetworkHelper postRequestWithURL:url andDictionary:nil];
    
    [FIRAnalytics logEventWithName:@"read_message"
                        parameters:@{
                                     @"message": self.message,
                                     @"from_username": self.fromUsername,
                                     }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSString *remoteError = [SPNetworkHelper checkResponseCodeForError:httpResponse.statusCode data:data];
                if (remoteError) {
                    block(NO, remoteError);
                    return;
                } else {
                    block(YES, nil);
                    return;
                }
            }
        });
    }];
}

#define kObjectIdKey @"SPObjectIdKey"
#define kMessageKey @"SPMessageKey"
#define kFromUsernameKey @"SPFromUsernameKey"
#define kTimestampKey @"SPTimestampKey"

#pragma mark - NSUserDefaults

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:[self objectId] forKey:kObjectIdKey];
    [encoder encodeObject:_message forKey:kMessageKey];
    [encoder encodeObject:_fromUsername forKey:kFromUsernameKey];
    [encoder encodeObject:_timestamp forKey:kTimestampKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        [self setObjectId:[decoder decodeObjectForKey:kObjectIdKey]];
        _message = [decoder decodeObjectForKey:kMessageKey];
        _fromUsername = [decoder decodeObjectForKey:kFromUsernameKey];
        _timestamp = [decoder decodeObjectForKey:kTimestampKey];
    }
    return self;
}

@end
