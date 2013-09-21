//
//  GoMemebersViewController.h
//  GoComIM
//
//  Created by 王鹏 on 13-5-15.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOPlainTableViewController.h"
@class IMUser;
@interface GoMemebersViewController : GOPlainTableViewController
- (id)initWithIMUser:(IMUser *)user;
@end
