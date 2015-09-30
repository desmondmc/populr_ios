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

// Data has to be an array or a dictionary
+ (NSURLRequest *) postRequestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary {
    NSMutableURLRequest *request = [self requestWithURL:urlString andDictionary:dictionary].mutableCopy;
    request.HTTPMethod = @"POST";
    
    [self setRequestHeaders:&request];
    
    return request;
}

+ (NSURLRequest *) postRequestWithURL:(NSString *)urlString array:(NSArray *)array {
    NSMutableURLRequest *request = [self requestWithURL:urlString andArray:array].mutableCopy;
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
        userJson = [NSJSONSerialization dataWithJSONObject:@{@"data": dictionary}
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

+ (NSURLRequest *) requestWithURL:(NSString *)urlString andArray:(NSArray *)array {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSData *userJson = nil;
    NSError *error;
    if (array) {
        userJson = [NSJSONSerialization dataWithJSONObject:@{@"data": array}
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
        [httpRequest setValue:currentUser.objectId.stringValue forHTTPHeaderField:@"x-key"];
        [httpRequest setValue:currentUser.goToken forHTTPHeaderField:@"new-token"];
    }
    [httpRequest setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Accept"];
    [httpRequest setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
}

+ (NSString *)checkResponseCodeForError:(NSInteger)code data:(NSData *)data {
    if (code < 200 || code > 299) {
        NSError *error;
        if (!data) {
            return kGenericErrorString;
        }
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSArray *errorArray = parsedObject[@"errors"];
        if ([errorArray count] > 0) {
            NSLog(@"Error in response: %@", parsedObject[@"errors"][0][@"detail"]);
            NSString *message = parsedObject[@"errors"][0][@"message"];
            if (message) {
                return message;
            }
        }
        return kGenericErrorString;
    }
    return nil;
}

+ (NSString *)getTimeStampString {
    return [NSString stringWithFormat:@"?q=%d", (int)[[NSDate date] timeIntervalSince1970]];
}

@end
