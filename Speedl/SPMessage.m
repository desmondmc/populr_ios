//
//  SPMessage.m
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-05.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessage.h"

@implementation SPMessage


// date is a derived from timestamp
- (NSDate *)date {
    if (self.timestamp == nil || [self.timestamp isEqualToString:@""]) {
        return nil;
    }
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyymmdd"];
    NSDate *date = [dateFormat dateFromString:self.timestamp];
    
    return date;
}

@end
