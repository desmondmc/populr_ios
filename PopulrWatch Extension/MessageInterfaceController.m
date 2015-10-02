//
//  MessageInterfaceController.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-30.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "MessageInterfaceController.h"
#define kCountDown @[@"3",@"2",@"1", @"0"]

@interface MessageInterfaceController ()

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *messageLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *messageFromLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *usernameLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *typeLabel;

@property (strong, nonatomic) NSArray *messageWords;

@end

@implementation MessageInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    if ([context isKindOfClass:[NSDictionary class]]) {
        [_usernameLabel setText:context[@"fromUsername"]];
        _messageWords = [self messageArrayWithMessage:context[@"message"]];
        [_typeLabel setText:context[@"type"]];
        [self animateCountDown];
    }
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
    for (NSString *word in _messageWords) {
        NSInteger index = [_messageWords indexOfObject:word];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.24 * NSEC_PER_SEC * index)), dispatch_get_main_queue(), ^{
            NSLog(@"%d - Setting message: %@", index, _messageWords[index]);
            [_messageLabel setText:_messageWords[index]];
            if ([[_messageWords lastObject] isEqualToString:word]) {
                [self popToRootController];
            }
        });
    }
}

- (void)animateCountDown {
    NSArray *countDown = kCountDown;
    for (NSString *word in countDown) {
        NSInteger index = [countDown indexOfObject:word];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC * index), dispatch_get_main_queue(), ^{
            NSLog(@"%d - Setting message: %@", index, countDown[index]);
            [_messageLabel setText:countDown[index]];
            
            if ([[countDown lastObject] isEqualToString:word]) {
                [_messageFromLabel setHidden:YES];
                [_usernameLabel setHidden:YES];
                [self animateMessage];
            }
        });
    }
}

@end



