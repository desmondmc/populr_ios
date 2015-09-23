//
//  SPDeviceToken.h
//  Populr
//
//  Created by Desmond McNamee on 2015-09-23.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPDeviceToken : NSObject

+ (void)saveDeviceToken:(NSString *)deviceToken;

+ (NSString *)getStoredDeviceToken;

@end
