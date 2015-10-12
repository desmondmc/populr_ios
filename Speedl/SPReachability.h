//
//  SPReachability.h
//  Populr
//
//  Created by Desmond McNamee on 2015-10-11.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPReachability : NSObject

+ (id)sharedInstance;

@property (atomic) BOOL isReachable;

@end
