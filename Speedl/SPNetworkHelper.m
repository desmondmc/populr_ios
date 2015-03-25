//
//  NetworkHelper.m
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import "SPNetworkHelper.h"

@implementation SPNetworkHelper

+ (NSURLRequest *) putRequestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary {
    NSMutableURLRequest *request = [self requestWithURL:urlString andDictionary:dictionary].mutableCopy;
    request.HTTPMethod = @"PUT";
    
    return request;
}

+ (NSURLRequest *) postRequestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary {
    NSMutableURLRequest *request = [self requestWithURL:urlString andDictionary:dictionary].mutableCopy;
    request.HTTPMethod = @"POST";
    
    return request;
}

+ (NSURLRequest *) requestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSError *error;
    NSData *userJson = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    if (error != nil) {
        return nil;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPBody = userJson;
    
    return request;
}

@end
