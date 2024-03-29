//
//  InterfaceController.m
//  PopulrWatch Extension
//
//  Created by Desmond McNamee on 2015-09-30.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "TableInterfaceController.h"
#import "MessagesTableRowController.h"
#import "SPWatchUser.h"
#import "SPWatchMessage.h"
#import "WKInterfaceLabel+Populr.h"

#define kMessageArray @[@"1", @"2", @"3"]
#define kExampleMessageArray @[@"Networking", @"is", @"WKInterfaceTable", @"a", @"message."]
#define kLoadingLabelSize 20

@interface TableInterfaceController()

@property (strong, nonatomic) IBOutlet WKInterfaceTable *messagesTable;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *loadingLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *extraLabel;

@end


@implementation TableInterfaceController

- (void)loadTableData {
    [self loadingState];
    [SPWatchUser getUserMessagesInBackground:^(NSArray *messages, BOOL success, NSString *errorMessage) {
        [self notLoadingStateMessage:errorMessage];
        [self reloadTableWithMessages:messages];
    }];
}

- (void)reloadTableWithMessages:(NSArray *)messages {
    _messages = messages;
    [_messagesTable setNumberOfRows:[_messages count] withRowType:@"MessagesTableRowController"];
    for (SPWatchMessage *message in _messages) {
        NSInteger index = [_messages indexOfObject:message];
        MessagesTableRowController *row = (MessagesTableRowController *)[_messagesTable rowControllerAtIndex:index];
        [row.numberLabel setText:[NSString stringWithFormat:@"%d", index+1]];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    SPWatchMessage *watchMessage = _messages[rowIndex];
    NSLog(@"Selected row: %@", watchMessage);
    
    [SPWatchUser markMessageAsReadInBackground:watchMessage block:^(BOOL success) {
        [self loadTableData];
    }];
    
    // Remove message from local list.
    NSMutableArray *mutableMessages = _messages.mutableCopy;
    [mutableMessages removeObject:watchMessage];
    [self reloadTableWithMessages:mutableMessages];
    
    // Push table view.
    [self pushControllerWithName:@"MessageInterfaceController"
                         context:@{@"message": watchMessage.message,
                                   @"fromUsername": watchMessage.fromUsername,
                                   @"type": watchMessage.type}];
}

#pragma mark Life Cyclie

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        [self loadTableData];
    } else {
        [self notSupportedState];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)haveMessagesState {
    [_loadingLabel setHidden:YES];
    [_extraLabel setHidden:YES];
}

- (void)loadingState {
    if ([_messages count] == 0) {
        [_loadingLabel setText:@"..." withSize:kLoadingLabelSize];
        [_loadingLabel setHidden:NO];
        [_extraLabel setHidden:YES];
    }
}

- (void)notSupportedState {
    [_loadingLabel setText:@"Requires iOS 9+" withSize:kLoadingLabelSize-5];
    [_extraLabel setText:@"Please update" withSize:kLoadingLabelSize-5];
    [_loadingLabel setHidden:NO];
    [_extraLabel setHidden:NO];
}

- (void)notLoadingStateMessage:(NSString *)message {
    if ([message isEqualToString:@"Please login"]) {
        [_loadingLabel setText:@"Open Populr on" withSize:kLoadingLabelSize];
        [_extraLabel setText:@"iPhone to login" withSize:kLoadingLabelSize];
    } else {
        [_loadingLabel setText:message withSize:kLoadingLabelSize];
        [_extraLabel setHidden:YES];
    }
    [_loadingLabel setHidden:NO];
}
#pragma mark WCSession

-(void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    NSLog(@"User info: %@", userInfo);
    [SPWatchUser setUserAuthKey:userInfo[@"auth_key"]];
    [SPWatchUser setUserId:userInfo[@"user_id"]];
    [self loadTableData];
}

@end



