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

- (NSString *)removeNonAlphaNumericalEnding {
    // Create a char buffer to hold the string.
    NSUInteger len = [self length];
    unichar buffer[len+1];
    
    // Create a character set that are all the characters allowed in a username.
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz123456789";
    NSCharacterSet *notLetters = [[NSCharacterSet characterSetWithCharactersInString:letters] invertedSet];
    
    // Move string into buffer
    [self getCharacters:buffer range:NSMakeRange(0, len)];
    
    // Loop through and find where the valid characters end and store that index.
    NSInteger indexToStopOn = 0;
    for(int i = 0; i < len; i++) {
        unichar c = buffer[i];
        if ([notLetters characterIsMember:c]) {
            indexToStopOn = i;
            break;
        }
    }
    
    // No invalid characters return original string.
    if (indexToStopOn == 0) {
        return self;
    }
    
    // Return trimmed string.
    return [self substringToIndex:indexToStopOn];
}

@end
