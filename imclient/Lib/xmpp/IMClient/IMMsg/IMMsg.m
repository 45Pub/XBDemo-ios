//
//  IMMsg.m
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import "IMMsg.h"
@implementation IMMsg
+ (NSString*)generateMessageID
{
	NSString *result = nil;
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	if (uuid)
	{
		result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
	}
	
	return result;
}

- (id)init
{
	if((self = [super init]))
	{
		self.msgTime = [NSDate date];
		self.msgID = [[self class] generateMessageID];
		_readState = IMMsgReadStateUnRead;
		_procState = IMMsgProcStateUnproc;
		_playState = IMMsgPlayStateUnPlay;
		_fromType = IMMsgFromOther;
		_msgVer = MSG_VERSION;
		_msgType = IMMsgTypeText;
	}
	return self;
}

- (id)initSendMsg
{
	if((self = [super init]))
	{
		self.msgTime = [NSDate date];
		self.msgID = [[self class] generateMessageID];
		_msgType = IMMsgTypeText;
		_readState = IMMsgReadStateReaded;
		_procState = IMMsgProcStateUnproc;
		_playState = IMMsgPlayStatePlayed;
		_fromType = IMMsgFromLocalSelf;
		_msgVer = MSG_VERSION;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"IMMsg:user[%@]type[%d]msgbody[%@]msgdate[%@]", self.msgUser, self.msgType, self.msgBody, self.msgTime];
}
@end
