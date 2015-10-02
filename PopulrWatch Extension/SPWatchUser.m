//
//  SPWatchUser.m
//  Populr
//
//  Created by Desmond McNamee on 2015-10-01.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPWatchUser.h"
#import "SPWatchNetworkHelper.h"

#define kAuthKeyKey @"SPWatchAuthKey"
#define kUserIdKey @"SPWatchUserIdKey"

@implementation SPWatchUser

+ (NSString *)userId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey];
}

+ (NSString *)userAuthKey {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAuthKeyKey];
}

+ (void)setUserId:(NSString *)userId {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kUserIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setUserAuthKey:(NSString *)authKey {
    [[NSUserDefaults standardUserDefaults] setObject:authKey forKey:kAuthKeyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)getUserMessagesInBackground:(SPWatchMessagesResultBlock)block {
    NSString *userId = [self userId];
    NSString *authKey = [self userAuthKey];
    
    if (userId == nil || authKey == nil) {
        block(nil, NO, @"Please login");
        return;
    }
    [SPWatchNetworkHelper urlRequestWithURL:@"http://populr_go_api.gzelle.co/messages"
                                     method:@"GET"
                                     userId:@"33"
                                    authKey:@"051aabce-8c89-45eb-6e08-95bf79cf32ef"
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                              if (error) {
                                  NSLog(@"Error with request: %@", error);
                                  block(nil, NO, @"Error");
                              } else {
                                  NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                  if (error) {
                                      block(nil, NO, @"Error");
                                  } else {
                                      NSArray *messages = [self messageArrayFromDictionary:dataDic];
                                      NSString *error = @"";
                                      if ([messages count] == 0) {
                                          error = @"No messages";
                                      }
                                      
                                      
                                      block(messages, YES, error);
                                  }
                              }
    }];
}

+ (void)markMessageAsReadInBackground:(SPWatchMessage *)message
                                block:(SPWatchNetworkResultBlock)block {
    NSString *url = @"http://populr_go_api.gzelle.co/readmessage/{id}";
    url = [url stringByReplacingOccurrencesOfString:@"{id}" withString:[message.objectId stringValue]];
    [SPWatchNetworkHelper urlRequestWithURL:url
                                     method:@"POST"
                                     userId:@"33"
                                    authKey:@"051aabce-8c89-45eb-6e08-95bf79cf32ef"
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                              NSLog(@"Response: %@", httpResponse);
                              if (error) {
                                  block(NO);
                              } else if (httpResponse.statusCode < 200 || httpResponse.statusCode > 299) {
                                  block(NO);
                              } else {
                                  block(YES);
                              }
                          }];
}

#pragma mark - Helpers

+ (NSArray *)messageArrayFromDictionary:(NSDictionary *)json {
    NSArray *unparseMessages = json[@"data"];
    NSMutableArray *messages = [NSMutableArray new];
    if (json[@"data"] == [NSNull null]) {
        return messages;
    }
    
    for (NSDictionary *unparseMessage in unparseMessages) {
        SPWatchMessage *message = [SPWatchMessage new];
        message.objectId = unparseMessage[@"id"];
        message.message = unparseMessage[@"message"];
        message.type = unparseMessage[@"type"];
        message.fromUsername = unparseMessage[@"from_username"];
        [messages addObject:message];
    }
    
    return messages;
}

@end
