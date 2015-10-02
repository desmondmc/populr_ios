//
//  SPWatchMessage.h
//  Populr
//
//  Created by Desmond McNamee on 2015-10-01.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPWatchMessage : NSObject

@property (strong, nonatomic) NSNumber *objectId;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *fromUsername;
@property (strong, nonatomic) NSString *type;

@end
