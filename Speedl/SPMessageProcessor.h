//
//  SPMessageProcessor.h
//  Populr
//
//  Created by Desmond McNamee on 2015-07-07.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SPMessageType) {
    SPMessageTypePublic,
    SPMessageTypeDirect
};

@protocol SPMessageProcessorDelegate <NSObject>

- (void)messageTypeChange:(SPMessageType)messageType;
- (void)displayTableView:(UITableView *)tableView height:(CGFloat)height;
- (void)hideTableView;
- (void)userSelectionMade:(NSString *)selection;

@end

@interface SPMessageProcessor : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *followerIDsInMessage;
@property (weak, nonatomic) id<SPMessageProcessorDelegate> delegate;

- (void)textViewDidChangeSelection:(UITextView *)textView;
- (void)textViewDidChange:(UITextView *)textView;

@end
