//
//  SPUsersTableDataSource.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-15.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPUsersTableDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSArray *users;

@end
