//
//  GoChatSetViewController.h
//  GoComIM
//
//  Created by 王鹏 on 13-5-13.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GoGroupedTableViewController.h"
@class IMUser;
@interface GoChatSetViewController : GoGroupedTableViewController
{
}
@property (nonatomic, retain) IMUser *fromUser;
- (void)initContentArray;
- (void)push2ChatHistroy;
- (void)push2Contacts;
- (void)push2orgVc;
- (void)exitGroup;
@end
