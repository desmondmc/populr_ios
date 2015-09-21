//
//  SPNetworkObject.h
//  Speedle
//
//  Created by Desmond McNamee on 2015-03-17.
//  Copyright (c) 2015 Desmond McNamee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPNetworkObject : NSObject

typedef void (^SPNetworkResultBlock)(BOOL success, NSString *serverMessage);

@property (strong, nonatomic) NSNumber *objectId;

@end
