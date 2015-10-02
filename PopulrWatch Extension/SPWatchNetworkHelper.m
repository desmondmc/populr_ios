//
//  SPWatchNetworkHelper.m
//  Populr
//
//  Created by Desmond McNamee on 2015-10-02.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPWatchNetworkHelper.h"

@implementation SPWatchNetworkHelper

+ (void)urlRequestWithURL:(NSString *)URL
                             method:(NSString *)method
                             userId:(NSString *)userId
                            authKey:(NSString *)authKey
                  completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {

    NSURL *url = [NSURL URLWithString:URL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:userId forHTTPHeaderField:@"x-key"];
    [urlRequest addValue:authKey forHTTPHeaderField:@"new-token"];
    [urlRequest addValue:@"application/vnd.api+json" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:method];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                completionHandler(data, response, error);
                                            }];
    [task resume];
}

@end
