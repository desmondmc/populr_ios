//
//  SPMessageHolder.m
//  Populr
//
//  Created by Desmond McNamee on 2015-07-06.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessageHolder.h"

@implementation SPMessageHolder

+ (id)sharedInstance
{
    static dispatch_once_t once = 0;

    __strong static id _sharedObject = nil;
    
    dispatch_once(&once, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}


@end
