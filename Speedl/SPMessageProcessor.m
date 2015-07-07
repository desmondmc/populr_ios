//
//  SPMessageProcessor.m
//  Populr
//
//  Created by Desmond McNamee on 2015-07-07.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessageProcessor.h"

@interface SPMessageProcessor ()

@property (nonatomic) SPMessageType currentMessageType;

@end

@implementation SPMessageProcessor

- (void)processText:(NSString *)text {
    NSArray *potentialUsernames = [self getWordsThatStartWithAtSymbolFromString:text];
    NSArray *followersArray = [SPUser getFollowingArray];
    _followerIDsInMessage = [self getVarifiedUserIDsWithUsernames:potentialUsernames
                                                               users:followersArray];
    [self setupMessageTypeAndNotifyDelegateOfChange];
}

- (void)setupMessageTypeAndNotifyDelegateOfChange {
    if (_followerIDsInMessage.count > 0) {
        if (_currentMessageType != SPMessageTypePublic) {
            if (_delegate) {
                [_delegate messageTypeChange:SPMessageTypeDirect];
            }
        }
        _currentMessageType = SPMessageTypePublic;
    } else {
        if (_currentMessageType != SPMessageTypeDirect) {
            if (_delegate) {
                [_delegate messageTypeChange:SPMessageTypePublic];
            }
        }
        _currentMessageType = SPMessageTypeDirect;
    }
}

- (NSArray *)getVarifiedUserIDsWithUsernames:(NSArray *)usernames users:(NSArray *)users {
    NSMutableArray *varifiedUserIds = [NSMutableArray new];
    
    for (NSString *potentialUsername in usernames) {
        for (SPUser *user in users) {
            NSString *lowercasePotential = [potentialUsername lowercaseString];
            NSString *lowercaseUsername = [user.username lowercaseString];
            if ([lowercasePotential isEqualToString:lowercaseUsername]) {
                [varifiedUserIds addObject:user.objectId];
                break;
            }
        }
    }
    
    return varifiedUserIds;
}

- (NSArray *)getWordsThatStartWithAtSymbolFromString:(NSString *)string {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:string
                                      options:0
                                        range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [string substringWithRange:wordRange];
        [array addObject:word];
    }
    return array;
}



@end
