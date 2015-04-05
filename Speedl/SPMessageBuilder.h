//
//  SPMessageBuilder.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-04-05.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPMessageBuilder : NSObject


+ (NSArray *)messagesFromJSON:(NSData *)jsonData error:(NSError **)error;

@end
