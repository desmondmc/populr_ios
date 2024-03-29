//
//  SPFriendsTableViewController.h
//  Speedl
//
//  Created by Desmond McNamee on 2015-05-14.
//  Copyright (c) 2015 Speedl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SPFriendListType) {
    SPFriendListTypeFriends
};

@interface SPFriendsTableViewController : UIViewController <UITableViewDelegate>

@property (nonatomic) SPFriendListType listType;

@end
