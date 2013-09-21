//
//  IMMsgCellUtil.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IMMsgAll.h>

#import "IMMsgCell.h"
#import "IMTextMsgCell.h"
#import "IMPicMsgCell.h"
#import "IMAudioMsgCell.h"
#import "IMVideoMsgCell.h"
#import "IMTimeCell.h"
#import "IMFileMsgCell.h"
#import "IMNoticeCell.h"
#import "IMFriendCenterCell.h"

@interface IMMsgCellUtil : NSObject

+ (CGFloat)cellHeightForMsg:(id)msg;

+ (UITableViewCell *)tableView:(UITableView *)tableView cellForMsg:(id)msg;

@end
