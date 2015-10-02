//
//  SPWatchNetworkHelper.h
//  Populr
//
//  Created by Desmond McNamee on 2015-10-02.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPWatchNetworkHelper : NSObject

+ (void)urlRequestWithURL:(NSString *)URL
                   method:(NSString *)method
                   userId:(NSString *)userId
                  authKey:(NSString *)authKey
        completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

@end
