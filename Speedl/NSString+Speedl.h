//
//  NSString+Speedl.h
//  Populr
//
//  Created by Desmond McNamee on 2015-10-12.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Speedl)

- (BOOL)isNilOrBlank;
- (BOOL)isIncludingEmoji;
- (NSString *)removeNonAlphaNumericalEnding;
- (int)unicodeLength;
@end
