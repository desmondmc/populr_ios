//
//  NetworkHelper.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPNetworkHelper.h"

@implementation SPNetworkHelper

+ (void)sendAsynchronousRequest:(NSURLRequest*) request
                          queue:(NSOperationQueue*) queue
              completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        handler(response, data, error);

    }];
}

+ (NSURLRequest *) putRequestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary {
    NSMutableURLRequest *request = [self requestWithURL:urlString andDictionary:dictionary].mutableCopy;
    request.HTTPMethod = @"PUT";
    
    [self setRequestHeaders:&request];
    
    return request;
}

+ (NSURLRequest *) postRequestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary {
    NSMutableURLRequest *request = [self requestWithURL:urlString andDictionary:dictionary].mutableCopy;
    request.HTTPMethod = @"POST";
    
    [self setRequestHeaders:&request];
    
    return request;
}

+ (NSURLRequest *) getRequestWithURL:(NSString *)urlString {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    request.HTTPMethod = @"GET";
    
    [self setRequestHeaders:&request];
    
    return request;
}

+ (NSURLRequest *) deleteRequestWithURL:(NSString *)urlString {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"DELETE";
    
    [self setRequestHeaders:&request];
    
    return request;
}

+ (NSURLRequest *) requestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSData *userJson = nil;
    NSError *error;
    if (dictionary) {
        userJson = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:0
                                                             error:&error];
    }
    if (error != nil) {
        return nil;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if (userJson) {
        request.HTTPBody = userJson;
    }
    
    
    [self setRequestHeaders:&request];
    
    return request;
}

+ (void) setRequestHeaders:(NSMutableURLRequest **)request {
    if (!request) {
        return;
    }
    
    NSMutableURLRequest *httpRequest = *request;
    SPUser *currentUser = [SPUser currentUser];
    if (currentUser) {
        [httpRequest setValue:currentUser.token forHTTPHeaderField:@"x-access-token"];
        [httpRequest setValue:currentUser.objectId forHTTPHeaderField:@"x-key"];
    }
    [httpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

+ (NSString *)checkResponseCodeForError:(NSInteger)code data:(NSData *)data {
    if (code != 200) {
        NSError *error;
        if (!data) {
            return kGenericErrorString;
        }
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (parsedObject[@"message"] != nil) {
            return parsedObject[@"message"];
        } else {
            return kGenericErrorString;
        }
    }
    return nil;
}

+ (NSString *)getTimeStampString {
    return [NSString stringWithFormat:@"?q=%d", (int)[[NSDate date] timeIntervalSince1970]];
}

@end
