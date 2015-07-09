//
//  SPMessageProcessor.m
//  Populr
//
//  Created by Desmond McNamee on 2015-07-07.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessageProcessor.h"
#import "SPFriendTableViewCell.h"

#define kSuggestCellNibName @"SPFriendTableViewCell"

@interface SPMessageProcessor ()

@property (nonatomic) SPMessageType currentMessageType;
@property (strong, nonatomic) NSArray *followingArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *currectSuggestions;

@end

@implementation SPMessageProcessor

- (NSArray *)followingArray {
    if (!_followingArray) {
        _followingArray = [SPUser getFollowingArray];
    }
    return _followingArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:kSuggestCellNibName bundle:nil] forCellReuseIdentifier:kSuggestCellNibName];
    }
    return _tableView;
}

#pragma mark - Build Autocomplete tableview

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSUInteger insertionPoint = [textView selectedRange].location;
    NSString *textViewText = [textView text];
    
    [textViewText enumerateSubstringsInRange:(NSRange){ 0, [textViewText length] }
                                     options:NSStringEnumerationByWords
                                  usingBlock:^(NSString *word, NSRange wordRange, NSRange enclosingRange, BOOL *stop) {
                                      if (NSLocationInRange(insertionPoint - 1, wordRange)) {
                                          NSString *firstLetter = [textViewText substringWithRange:NSMakeRange(wordRange.location-1, 1)];
                                          if ([firstLetter isEqualToString:@"@"]) {
                                              [self buildSuggestionsTableWithWord:word];
                                          } else {
                                              [_delegate hideTableView];
                                          }
                                      }
                                  }];
}

- (void)buildSuggestionsTableWithWord:(NSString *)word {
    NSLog(@"Building table for word: %@", word);
    NSArray *followingArray = [self followingArray];
    NSMutableArray *arrayOfSuggestions = [NSMutableArray new];
    
    for (SPUser *followingUser in followingArray) {
        if ([followingUser.username hasPrefix:word]) {
            [arrayOfSuggestions addObject:followingUser.username];
        }
    }
    
    _currectSuggestions = arrayOfSuggestions;
    if (_currectSuggestions.count > 0) {
        [_delegate displayTableView:[self tableView] height:10];
    } else {
        [_delegate hideTableView];
    }
    NSLog(@"Suggestions: %@", arrayOfSuggestions);
}

#pragma mark - UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_currectSuggestions) {
        return 0;
    }
    return [_currectSuggestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = kSuggestCellNibName;
    SPFriendTableViewCell *cell = nil;
    
    cell = (SPFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        //There was no reusablecell to dequeue
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SPMessageTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.friendNameLabel = _currectSuggestions[indexPath.row];
    
    return cell;
}

#pragma mark - Get @-ed users

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
