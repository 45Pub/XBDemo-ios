//
//  IMNoticeMsg.m
//  GoComIM
//
//  Created by 王鹏 on 13-5-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMNoticeMsg.h"

@implementation IMNoticeMsg
- (id)init
{
	self = [super init];
	if (self)
	{
		self.msgType = IMMsgTypeNotice;
	}
	return self;
}
@end
