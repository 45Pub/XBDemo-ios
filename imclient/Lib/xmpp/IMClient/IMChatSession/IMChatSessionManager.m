//
//  IMChatSessionManager.m
//  IMClient
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMChatSessionManager.h"
#import "IMMsgStorage.h"
#import "IMChatSession.h"
#import "IMMsgQueueManager.h"

@implementation IMChatSessionManager

- (instancetype)initWithMsgStorage:(IMMsgStorage *)msgStorage
					 dispatchQueue:(dispatch_queue_t)queue
					   msgQueueMgr:(IMMsgQueueManager *)msgQueueMgr
{
	self = [super init];
	if (self) {
		_msgStorage = msgStorage;
		_msgQueueMgr = msgQueueMgr;
		if (queue) {
			_seQueue = queue;
			#if !OS_OBJECT_USE_OBJC
			dispatch_retain(_seQueue);
			#endif
		}
		else {
			const char *name = [NSStringFromClass([self class]) UTF8String];
			_seQueue = dispatch_queue_create(name, NULL);
		}
		
		_seQueueTag = &_seQueueTag;
		dispatch_queue_set_specific(_seQueue, _seQueueTag, _seQueueTag, NULL);
		
		_delegates = (GCDMulticastDelegate<IMChatSessionManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
	}
	return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
	dispatch_release(_seQueue);
#endif
}

- (void)deliverMsg:(IMMsg *)msg
{
	dispatch_block_t block = ^{
		[_msgStorage addChatSession:msg];
		
		if ([_msgQueueMgr msgQueueActiving:msg.fromUser]) {
			[self readChatSessionWithUser:msg.fromUser];
		}
		else {
			[self freshChatSession];
		}
		//
		[NSThread sleepForTimeInterval:0.1f];
	};

	if (dispatch_get_specific(_seQueueTag))
		block();
	else
		dispatch_async(_seQueue, block);
}

- (void)freshChatSession
{
	dispatch_block_t block = ^{
		NSArray *list = [_msgStorage getChatSessionList:0];
		_sessions = [NSMutableArray arrayWithArray:list];
		unreadTotalNum = [_msgStorage unreadTotalNum];
		[_delegates imChatSessionDidChanged:self sessions:list unreadNum:unreadTotalNum];
	};
	
	if (dispatch_get_specific(_seQueueTag))
		block();
	else
		dispatch_async(_seQueue, block);
}

- (void)readChatSession:(IMChatSession *)session
{
	if (session == nil||session.unreadNum <= 0)
		return;
	
	dispatch_block_t block = ^{
		[_msgStorage setAllMsgReaded:session.fromUser];
		[self freshChatSession];
	};
	
	if (dispatch_get_specific(_seQueueTag))
		block();
	else
		dispatch_async(_seQueue, block);
	
}

- (void)readChatSessionWithUser:(IMUser *)fromUser
{
	
	dispatch_block_t block = ^{
		[_msgStorage setAllMsgReaded:fromUser];
		[self freshChatSession];
	};
	
	if (dispatch_get_specific(_seQueueTag))
		block();
	else
		dispatch_async(_seQueue, block);
	
}

- (void)deleteChatSessionWithUser:(IMUser *)fromUser
{
	dispatch_block_t block = ^{
		[_msgStorage delChatSession:fromUser];
		[self freshChatSession];
	};
	
	if (dispatch_get_specific(_seQueueTag))
		block();
	else
		dispatch_async(_seQueue, block);
}
#pragma mark Delegate
- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
	// Asynchronous operation (if outside xmppQueue)
	
	dispatch_block_t block = ^{
		[_delegates addDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(_seQueueTag))
		block();
	else
		dispatch_async(_seQueue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously
{
	dispatch_block_t block = ^{
		[_delegates removeDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(_seQueueTag))
		block();
	else if (synchronously)
		dispatch_sync(_seQueue, block);
	else
		dispatch_async(_seQueue, block);
	
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
	// Synchronous operation (common-case default)
	
	[self removeDelegate:delegate delegateQueue:delegateQueue synchronously:YES];
}

- (void)removeDelegate:(id)delegate
{
	// Synchronous operation (common-case default)
	
	[self removeDelegate:delegate delegateQueue:NULL synchronously:YES];
}

@end

