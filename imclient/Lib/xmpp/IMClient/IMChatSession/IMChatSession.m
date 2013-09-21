//
//  IMChatSession.m
//  IMClient
//
//  Created by pengjay on 13-7-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMChatSession.h"
#import "IMMsg.h"
#import "IMUser.h"
@implementation IMChatSession
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ unread[%d][%@]", self.fromUser, self.unreadNum, self.msg];
}

- (NSString *)sessionBody
{
	NSString *prefix = @"";
	if (self.fromUser.userType & IMUserTypeDiscuss) {
		if (self.msg.msgUser.nickname.length > 0)
			prefix = [NSString stringWithFormat:@"%@:", self.msg.msgUser.nickname];
	}
	
	if (self.msg == nil)
	{
		return @"";
	}
	
	if (self.msg.msgType == IMMsgTypePic)
	{
		return [NSString stringWithFormat:@"%@[图片]", prefix];
	}
	else if (self.msg.msgType == IMMsgTypeAudio)
	{
		return [NSString stringWithFormat:@"%@[语音]", prefix];
	}
	else if (self.msg.msgType == IMMsgTypeVideo)
	{
		return [NSString stringWithFormat:@"%@[视频]", prefix];
	}
	else if (self.msg.msgType == IMMsgTypeFile)
	{
		return [NSString stringWithFormat:@"%@[文件]", prefix];
	}
	else
		return [NSString stringWithFormat:@"%@%@", prefix, self.msg.msgBody];;
	
}
@end
