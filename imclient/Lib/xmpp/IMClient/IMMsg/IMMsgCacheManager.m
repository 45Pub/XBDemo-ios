//
//  IMMsgCacheManager.m
//  IMClient
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgCacheManager.h"
#import "IMUser.h"
#import "IMMsg.h"

@implementation IMMsgCacheManager

- (instancetype)init
{
	self = [super init];
	if (self) {
		_mLock = [[NSLock alloc]init];
		_sessionMsgCache = [[NSMutableDictionary alloc]init];
		_processingMsgCache = [[NSMutableDictionary alloc]init];
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Session Msg Cache
- (IMMsg *)getSessionCachedMsgWithUser:(IMUser *)user msgid:(NSString *)msgid
{
	IMMsg *msg = nil;
	if (user == nil || msgid == nil) {
		return nil;
	}
	
	NSString *key = [NSString stringWithFormat:@"%@%d", user.userID, user.userType];
	
	[_mLock lock];
	msg = [_sessionMsgCache objectForKey:key];
	[_mLock unlock];
	if ([msg.msgID isEqualToString:msgid]) {
		return msg;
	}
	return nil;
}

- (void)addSessionMsgWithUser:(IMUser *)user msg:(IMMsg *)msg
{
	if (user == nil || msg == nil) {
		return;
	}
	
	NSString *key = [NSString stringWithFormat:@"%@%d", user.userID, user.userType];
	
	[_mLock lock];
	[_sessionMsgCache setObject:msg forKey:key];
	[_mLock unlock];
	return;
}

- (void)removeSessionMsgWithUser:(IMUser *)user
{
	if (user == nil) {
		return;
	}
	
	NSString *key = [NSString stringWithFormat:@"%@%d", user.userID, user.userType];
	
	[_mLock lock];
	[_sessionMsgCache removeObjectForKey:key];
	[_mLock unlock];
	
}

- (void)removeAllSessionMsg
{
	[_mLock lock];
	[_sessionMsgCache removeAllObjects];
	[_mLock unlock];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - ProcessCache
- (IMMsg *)getProcessCachedMsgWithUser:(IMUser *)user msgid:(NSString *)msgid
{
	IMMsg *msg = nil;
	if (user == nil || msgid == nil) {
		return nil;
	}
	
	NSString *key = [NSString stringWithFormat:@"%@%@", user.userID, msgid];
	
	[_mLock lock];
	msg = [_processingMsgCache objectForKey:key];
	[_mLock unlock];
	return msg;
}

- (void)addProcessMsg:(IMMsg *)msg
{
	if (msg == nil) {
		return;
	}
	
	NSString *key = [NSString stringWithFormat:@"%@%@", msg.fromUser.userID, msg.msgID];
	
	[_mLock lock];
	[_processingMsgCache setObject:msg forKey:key];
	[_mLock unlock];
	return;
}

- (void)removeProcessMsg:(IMMsg *)msg
{
	if (msg == nil) {
		return;
	}
	
	NSString *key = [NSString stringWithFormat:@"%@%@", msg.fromUser.userID, msg.msgID];
	
	[_mLock lock];
	[_processingMsgCache removeObjectForKey:key];
	[_mLock unlock];
	
}

- (void)removeAllProcessMsg
{
	[_mLock lock];
	[_processingMsgCache removeAllObjects];
	[_mLock unlock];
}

@end
