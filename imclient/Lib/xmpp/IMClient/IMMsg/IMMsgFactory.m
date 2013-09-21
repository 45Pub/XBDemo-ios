//
//  IMMsgFactory.m
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgFactory.h"
#import "IMMsgAll.h"

@implementation IMMsgFactory

+ (IMMsg *)handleMsgWithFromUser:(IMUser *)fromUser msgUser:(IMUser *)msgUser msgid:(NSString *)msgid
					  msgTime:(NSDate *)msgTime isDelay:(BOOL)isDelay msgBody:(NSString *)msgBody
					   attach:(NSDictionary *)attch msgType:(IMMsgType)msgType msgSize:(UInt64)msgSize
					 fromType:(IMMsgFrom)fromType readState:(IMMsgReadState)readState
					procState:(IMMsgProcState)procState playState:(IMMsgPlayState)playState
{
	
	if (fromUser == nil || msgUser == nil) {
		NSLog(@"user is nil");
		return nil;
	}
	
	IMMsg *msg = nil;
	switch (msgType) {
		case IMMsgTypeText:
			msg = [[IMMsg alloc]init];
			break;
		case IMMsgTypeAudio:
			msg = [[IMAudioMsg alloc]init];
			break;
		case IMMsgTypeFile:
			msg = [[IMFileMsg alloc]init];
			break;
		case IMMsgTypePic:
			msg = [[IMPicMsg alloc]init];
			break;
		case IMMsgTypeVideo:
			msg = [[IMVideoMsg alloc]init];
			break;
		case IMMsgTypeFriendCenter:
			msg = [[IMFriendCenterMsg alloc]init];
			break;
		case IMMsgTypeNotice:
			msg = [[IMNoticeMsg alloc]init];
			break;
		default:
			break;
	}
	
	msg.fromUser = fromUser;
	msg.msgUser = msgUser;
	msg.msgVer = MSG_VERSION;
	msg.msgID = msgid;
	msg.msgTime = msgTime;
	msg.isDelayed = isDelay;
	msg.msgBody = msgBody;
	msg.msgAttach = attch;
	msg.msgType = msgType;
	msg.msgSize = msgSize;
	msg.fromType = fromType;
	msg.readState = readState;
	msg.procState = procState;
	msg.playState = playState;

	
	return msg;
}
@end
