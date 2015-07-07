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

@end

@interface SPMessageProcessor : NSObject

@property (strong, nonatomic) NSArray *followerIDsInMessage;
@property (weak, nonatomic) id<SPMessageProcessorDelegate> delegate;

- (void)processText:(NSString *)text;

@end
