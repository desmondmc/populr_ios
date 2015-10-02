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

#define kMessageArray @[@"1", @"2", @"3"]
#define kExampleMessageArray @[@"Networking", @"is", @"WKInterfaceTable", @"a", @"message."]

@interface TableInterfaceController()

@property (strong, nonatomic) IBOutlet WKInterfaceTable *messagesTable;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *loadingLabel;

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
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self loadTableData];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)haveMessagesState {
    [_loadingLabel setHidden:YES];
}

- (void)loadingState {
    [_loadingLabel setText:@"Loading..."];
    [_loadingLabel setHidden:NO];
}

- (void)notLoadingStateMessage:(NSString *)message {
    [_loadingLabel setText:message];
    [_loadingLabel setHidden:NO];
}
#pragma mark WCSession

-(void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    [SPWatchUser setUserAuthKey:userInfo[@"auth_key"]];
    [SPWatchUser setUserId:userInfo[@"user_id"]];
    [self loadTableData];
}

@end



