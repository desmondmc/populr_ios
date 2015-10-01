//
//  InterfaceController.m
//  PopulrWatch Extension
//
//  Created by Desmond McNamee on 2015-09-30.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "TableInterfaceController.h"
#import "MessagesTableRowController.h"

#define kMessageArray @[@"1", @"2", @"3"]
#define kExampleMessageArray @[@"Hello", @"this", @"is", @"a", @"message."]

@interface TableInterfaceController()

@property (strong, nonatomic) IBOutlet WKInterfaceTable *messagesTable;

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
    NSArray *messageArray = kMessageArray;
    
    [_messagesTable setNumberOfRows:[messageArray count] withRowType:@"MessagesTableRowController"];
    
    for (NSString *message in messageArray) {
        NSInteger index = [messageArray indexOfObject:message];
        MessagesTableRowController *row = (MessagesTableRowController *)[_messagesTable rowControllerAtIndex:index];
        [row.numberLabel setText:message];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSLog(@"Selected row: %@", kMessageArray[rowIndex]);
    
    [self pushControllerWithName:@"MessageInterfaceController" context:kExampleMessageArray];
}

@end



