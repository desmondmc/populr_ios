//
//  SPUserBuilder.h
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPUser.h"

@interface SPUserBuilder : NSObject

+ (SPUser *)userFromJSON:(NSData *)jsonData error:(NSError **)error;
+ (NSArray *)followersFromJSON:(NSData *)jsonData error:(NSError **)error;

@end
