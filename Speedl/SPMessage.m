//
//  SPMessage.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-05.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessage.h"
#import "SPNetworkHelper.h"

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
    
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[self objectId]];
    
    NSURLRequest *request = [SPNetworkHelper putRequestWithURL:url andDictionary:nil];
    
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

@end
