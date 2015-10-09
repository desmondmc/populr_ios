//
//  MessageInterfaceController.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-30.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "MessageInterfaceController.h"
#import "WKInterfaceLabel+Populr.h"

#define kCountDown @[@"",@"0"]
#define kMessageTextSize 20
#define kDefaultDelay 0.24

@interface MessageInterfaceController ()

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *messageLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *usernameLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *typeLabel;

@property (strong, nonatomic) NSArray *messageWords;

@end

@implementation MessageInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [_messageLabel setText:@"3" withSize:kMessageTextSize];
    if ([context isKindOfClass:[NSDictionary class]]) {
        [_usernameLabel setText:context[@"fromUsername"] withSize:kMessageTextSize];
        _messageWords = [self messageArrayWithMessage:context[@"message"]];
        [_typeLabel setText:[self getTypeTextWithType:context[@"type"]]];
        [self animateCountDown];
    }
}

- (NSString *)getTypeTextWithType:(NSString *)type {
    return [type stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[type substringToIndex:1] uppercaseString]];
}

- (NSArray *)messageArrayWithMessage:(NSString *)message {
    NSArray *array = [message componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    return [array arrayByAddingObject:@""];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)animateMessage {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *word = nil;
        for (NSInteger index = 0; index < [_messageWords count]; index++) {
            word = _messageWords[index];
            [_messageLabel setText:_messageWords[index] withSize:kMessageTextSize];
            if ([[_messageWords lastObject] isEqualToString:word]) {
                [self popToRootController];
            }
            [self sleepForWord:word];
        }
    });
}

- (void)sleepForWord:(NSString *)word {
    CGFloat multiplyer = 1;
    if ([word hasSuffix:@"."]
        || [word hasSuffix:@"!"]
        || [word hasSuffix:@"?"]
        || [word hasSuffix:@";"]
        || [word hasSuffix:@":"]) {
        
        multiplyer = 2.0;
    } else if ([word hasSuffix:@","]) {
        multiplyer = 1.5;
    }
    
    [NSThread sleepForTimeInterval:kDefaultDelay*multiplyer];
}

- (void)animateCountDown {
    NSArray *countDown = kCountDown;
    for (NSString *word in countDown) {
        NSInteger index = [countDown indexOfObject:word];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC * index), dispatch_get_main_queue(), ^{
            NSLog(@"%d - Setting message: %@", index, countDown[index]);
            [_messageLabel setText:countDown[index] withSize:kMessageTextSize];
            
            if ([[countDown lastObject] isEqualToString:word]) {
                [_usernameLabel setHidden:YES];
                [_typeLabel setHidden:YES];
                [self animateMessage];
            }
        });
    }
}

@end



