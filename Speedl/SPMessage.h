//
//  SPMessage.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-05.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import "SPNetworkObject.h"

@interface SPMessage : SPNetworkObject

typedef void (^SPMessagesResultBlock)(NSArray *messages, NSString *serverMessage);

// JSON values

/* Warning! This is an objective-c representation of json objects. The way the code is currently structured,
 variabel names of this object must match their corresponding json properties.*/

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *fromUsername;
@property (strong, nonatomic) NSString *type;

- (void)markMessageAsReadInBackground:(SPNetworkResultBlock)block;

@end
