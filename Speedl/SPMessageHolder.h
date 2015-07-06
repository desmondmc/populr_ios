//
//  SPMessageHolder.h
//  Populr
//
//  Created by Desmond McNamee on 2015-07-06.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPMessageHolder : NSObject

+ (id)sharedInstance;

@property (strong, atomic) NSArray *messageArray;

@end
