//
//  NetworkHelper.h
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPNetworkHelper : NSObject

+ (NSURLRequest *) getRequestWithURL:(NSString *)urlString;
+ (NSURLRequest *) putRequestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary;
+ (NSURLRequest *) postRequestWithURL:(NSString *)urlString andDictionary:(NSDictionary *)dictionary;

@end
