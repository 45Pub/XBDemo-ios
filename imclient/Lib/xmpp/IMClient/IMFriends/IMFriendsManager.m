//
//  IMFriendsManager.m
//  IMClient
//
//  Created by pengjay on 13-7-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFriendsManager.h"
#import "DDLog.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation IMFriendsManager


- (instancetype)initWithRoster:(XMPPRoster *)roster rosterStrorage:(XMPPRosterSqlStorage *)rosterStorage
				 dispatchQueue:(dispatch_queue_t)queue
{
	self = [super init];
	if (self) {
		_roster = roster;
		_rosterStorage = rosterStorage;
		if (queue) {
			_queue = queue;
#if !OS_OBJECT_USE_OBJC
			dispatch_retain(_queue);
#endif
		}
		else {
			const char *name = [NSStringFromClass([self class]) UTF8String];
			_queue = dispatch_queue_create(name, NULL);
		}
		
		_queueTag = &_queueTag;
		dispatch_queue_set_specific(_queue, _queueTag, _queueTag, NULL);
		
		_delegates = (GCDMulticastDelegate<IMFriendsManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
		
		[_roster addDelegate:self delegateQueue:_queue];
	}
	return self;
}

- (void)dealloc
{
	[_roster removeDelegate:self];
#if !OS_OBJECT_USE_OBJC
	dispatch_release(_queue);
#endif
}

#pragma mark Delegate
- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
	// Asynchronous operation (if outside xmppQueue)
	
	dispatch_block_t block = ^{
		[_delegates addDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(_queueTag))
		block();
	else
		dispatch_async(_queue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously
{
	dispatch_block_t block = ^{
		[_delegates removeDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(_queueTag))
		block();
	else if (synchronously)
		dispatch_sync(_queue, block);
	else
		dispatch_async(_queue, block);
	
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



#pragma mark - RosterDelegate
- (void)xmppRosterDidChange:(XMPPRosterSqlStorage *)sender
{
	
}

#pragma mark -

@end
