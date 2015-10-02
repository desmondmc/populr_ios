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

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
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

- (void)loadTableData {
    [SPWatchUser getUserMessagesInBackground:^(NSArray *messages, BOOL success) {
        if (!success) {
            [_loadingLabel setText:@"Error"];
        }
        [self reloadTableWithMessages:messages];
    }];
}

- (void)reloadTableWithMessages:(NSArray *)messages {
    _messages = messages;
    [_messagesTable setNumberOfRows:[_messages count] withRowType:@"MessagesTableRowController"];
    if ([_messages count] > 0) {
        [_loadingLabel setHidden:YES];
    }
    for (SPWatchMessage *message in _messages) {
        NSInteger index = [_messages indexOfObject:message];
        MessagesTableRowController *row = (MessagesTableRowController *)[_messagesTable rowControllerAtIndex:index];
        [row.numberLabel setText:[NSString stringWithFormat:@"%d", index+1]];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    SPWatchMessage *watchMessage = _messages[rowIndex];
    NSLog(@"Selected row: %@", watchMessage);
    
    NSString *messageString = watchMessage.message;
    NSArray *array = [messageString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    
    [SPWatchUser markMessageAsReadInBackground:watchMessage block:^(BOOL success) {
        [self loadTableData];
    }];
    
    // Remove message from local list.
    NSMutableArray *mutableMessages = _messages.mutableCopy;
    [mutableMessages removeObject:watchMessage];
    [self reloadTableWithMessages:mutableMessages];
    
    // Push table view.
    [self pushControllerWithName:@"MessageInterfaceController" context:array];
}



@end



