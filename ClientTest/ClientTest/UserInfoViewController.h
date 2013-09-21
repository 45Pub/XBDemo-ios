//
//  UserInfoViewController.h
//  IMLite
//
//  Created by pengjay on 13-7-19.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GoGroupedTableViewController.h"
#import <IMMsg.h>

@class IMUser;
@interface UserInfoViewController : GoGroupedTableViewController
- (instancetype)initWithUser:(IMUser *)user;
@property (nonatomic) BOOL shouldProcWhenNotFriend;
@property (nonatomic) BOOL undisposed;

//@property (nonatomic, retain) IMMsg *friendCenderMsg;

@end
