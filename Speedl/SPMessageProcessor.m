//
//  SPMessageProcessor.m
//  Populr
//
//  Created by Desmond McNamee on 2015-07-07.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPMessageProcessor.h"
#import "SPSuggestionTableViewCell.h"

#define kSuggestCellNibName @"SPSuggestionTableViewCell"
#define kCellSuggestionCellHieght 40

@interface SPMessageProcessor ()

@property (nonatomic) SPMessageType currentMessageType;
@property (strong, nonatomic) NSArray *followersArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *currectSuggestions;
@property (strong, nonatomic) NSString *currentWord;
@property (nonatomic) BOOL haveSuggestions;
@end

@implementation SPMessageProcessor

- (NSArray *)followersArray {
    if (!_followersArray)
    {
        _followersArray = [SPUser getFollowersArray];
    }
    return _followersArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:kSuggestCellNibName bundle:nil] forCellReuseIdentifier:kSuggestCellNibName];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorColor = [SPAppearance globalBackgroundColour];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
    }
    return _tableView;
}

#pragma mark - Build Autocomplete tableview

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSUInteger insertionPoint = [textView selectedRange].location;
    NSString *textViewText = [textView text];
    _haveSuggestions = NO;
    [textViewText enumerateSubstringsInRange:(NSRange){ 0, [textViewText length] }
                                     options:NSStringEnumerationByWords
                                  usingBlock:^(NSString *word, NSRange wordRange, NSRange enclosingRange, BOOL *stop) {
                                      if (NSLocationInRange(insertionPoint - 1, wordRange)) {
                                          if (wordRange.location > 0) {
                                              NSString *firstLetter = [textViewText substringWithRange:NSMakeRange(wordRange.location-1, 1)];
                                              if ([firstLetter isEqualToString:@"@"]) {
                                                  [self buildSuggestionsTableWithWord:word textView:textView];
                                              }
                                          }
                                      }
                                  }];
    if (!_haveSuggestions) {
        [_delegate hideTableView];
    }
}

- (void)turnOffSmartTextview:(UITextView *)textView {
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [textView becomeFirstResponder];
}

- (void)turnOnSmartTextview:(UITextView *)textView {
    textView.autocorrectionType = UITextAutocorrectionTypeDefault;
    
}

- (void)textViewDidChange:(UITextView *)textView {
    [self findAllToUsersFromText:textView.text];
}

- (void)buildSuggestionsTableWithWord:(NSString *)word textView:(UITextView *)textView{
    _currentWord = word;
    NSArray *followingArray = [self followersArray];
    NSMutableArray *arrayOfSuggestions = [NSMutableArray new];
    
    for (SPUser *followingUser in followingArray) {
        if ([followingUser.username hasPrefix:word]) {
            [arrayOfSuggestions addObject:followingUser.username];
        }
    }
    
    _currectSuggestions = arrayOfSuggestions;
    if (_currectSuggestions.count > 0) {
        _haveSuggestions = YES;
        NSInteger cellCount = _currectSuggestions.count;
        if (cellCount > 4) {
            cellCount = 4;
        }
        
        CGFloat height = cellCount * kCellSuggestionCellHieght;
        [_delegate displayTableView:[self tableView] height:height];
    }
    
}

#pragma mark - UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellSuggestionCellHieght;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_currectSuggestions) {
        return 0;
    }
    return [_currectSuggestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = kSuggestCellNibName;
    SPSuggestionTableViewCell *cell = nil;
    
    cell = (SPSuggestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        //There was no reusablecell to dequeue
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SPMessageTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:cell.frame];
        bgView.backgroundColor = [SPAppearance globalBackgroundColour];
        cell.selectedBackgroundView = bgView;
    }
    
    cell.usernameLabel.text = _currectSuggestions[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPSuggestionTableViewCell *cell = (SPSuggestionTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    NSString *selectedUsername = cell.usernameLabel.text;
    
    
    if ([selectedUsername hasPrefix:_currentWord]) {
        selectedUsername = [selectedUsername substringFromIndex:[_currentWord length]];
        selectedUsername = [selectedUsername stringByAppendingString:@" "];
    }
    
    [_delegate userSelectionMade:selectedUsername];
}

#pragma mark - Get @-ed users

- (void)findAllToUsersFromText:(NSString *)text {
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
