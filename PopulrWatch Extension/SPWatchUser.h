//
//  SPWatchUser.h
//  Populr
//
//  Created by Desmond McNamee on 2015-10-01.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPWatchMessage.h"

typedef void (^SPWatchMessagesResultBlock)(NSArray *messages, BOOL success);
typedef void (^SPWatchNetworkResultBlock)(BOOL success);

@interface SPWatchUser : NSObject

+ (NSString *)userId;
+ (NSString *)userAuthKey;
+ (void)setUserId:(NSString *)userId;
+ (void)setUserAuthKey:(NSString *)authKey;

+ (void)getUserMessagesInBackground:(SPWatchMessagesResultBlock)block;
+ (void)markMessageAsReadInBackground:(SPWatchMessage *)message
                                block:(SPWatchNetworkResultBlock)block;

@end
