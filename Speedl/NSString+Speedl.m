//
//  NSString+Speedl.m
//  Populr
//
//  Created by Desmond McNamee on 2015-10-12.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "NSString+Speedl.h"
#import "NSString+EMOEmoji.h"

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
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz1234567890";
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

- (BOOL) isIncludingEmoji {
    return [self emo_containsEmoji];
}

// [NSString length] returns the number of 16 bit chars there are in the string. Since some characters are bigger than this like emojis 🤗, this isn't accurate. The function will return the actual number of unicode characters in the string. Meaning even emojis will be counted as one.
- (int)unicodeLength {
    __block int count = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                                options:NSStringEnumerationByComposedCharacterSequences
                             usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                 count++;
                             }];
    return count;
}

@end
