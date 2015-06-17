//
//  NSError+Speedl.m
//  gzelle
//
//  Created by Desmond McNamee on 2015-06-17.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "NSError+Speedl.h"

@implementation NSError (Speedl)

+ (NSError *)errorWithDescription:(NSString *)description {
    return [NSError errorWithDomain:@"gzelle" code:10 userInfo:@{NSLocalizedDescriptionKey : description}];
}

@end
