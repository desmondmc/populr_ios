//
//  NSString+Speedl.m
//  Populr
//
//  Created by Desmond McNamee on 2015-10-12.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "NSString+Speedl.h"

@implementation NSString (Speedl)

- (BOOL)isNilOrBlank {
    if (!self || [self isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

@end
