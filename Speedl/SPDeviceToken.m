//
//  SPDeviceToken.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-23.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPDeviceToken.h"

#define kTokenKey @"SPTokenKey"

@implementation SPDeviceToken

+ (void)saveDeviceToken:(NSString *)deviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getStoredDeviceToken {
    return [[NSUserDefaults standardUserDefaults]
            stringForKey:kTokenKey];
}

@end
