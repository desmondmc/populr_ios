//
//  SPFriendFindingDataSource.h
//  Populr
//
//  Created by Desmond McNamee on 2015-09-28.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPFriendFindingDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *users;

@end
