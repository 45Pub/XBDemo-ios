//
//  IMMsgQueueManager.m
//  IMClient
//
//  Created by pengjay on 13-7-14.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgQueueManager.h"
#import "DDLog.h"


#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@implementation IMMsgQueueManager


- (id)initWithMsgStorage:(IMMsgStorage *)msgStorage
{
	self = [super init];
	if (self) {
		_cacheQueue = [[NSCache alloc]init];
		_msgStorage = msgStorage;
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
- (void)clearMemory
{
	[_cacheQueue removeAllObjects];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

- (IMMsgQueue *)openNormalMsgQueueWithUser:(IMUser *)fromUser delegate:(id<IMMsgQueueDelegate>)delegate
{
	if (fromUser == nil || delegate == nil)
		return nil;
	
	if ([_activeQueue.fromUser isEqual:fromUser]) {
		DDLogVerbose(@"get active:%@", fromUser);
		_activeQueue.delegate = delegate;
		return _activeQueue;
	}
	
	IMMsgQueue *msgQueue = [_cacheQueue objectForKey:fromUser.userID];
	if (!msgQueue) {
		msgQueue = [[IMMsgQueue alloc]initWithUser:fromUser msgStorage:_msgStorage queue:NULL
										audioMode:IMMsgQueueAudioModePrvChat groupFlag:YES];
#warning No cache
//		[_cacheQueue setObject:msgQueue forKey:fromUser.userID];
	}

	_activeQueue = msgQueue;
	_activeQueue.delegate = delegate;

	return _activeQueue;
}

- (void)closeNormalMsgQueueWithUser:(IMUser *)fromUser
{
	if ([_activeQueue.fromUser isEqual:fromUser]) {
		[_activeQueue stopAudioPlay];
		_activeQueue.delegate = nil;
		_activeQueue = nil;
	}
}

#pragma mark - Deliver

- (void)deliverMsg:(IMMsg *)msg
{
	if ([_activeQueue.fromUser isEqual:msg.fromUser]) {
		[_activeQueue deliverMsg:msg];
	} else {
		IMMsgQueue *msgQueue = [_cacheQueue objectForKey:msg.fromUser.userID];
		if (msgQueue) {
			[msgQueue deliverMsg:msg];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)msgQueueActiving:(IMUser *)fromUser
{
	if ([_activeQueue.fromUser isEqual:fromUser]) {
		return YES;
	}
	return NO;
}

#pragma mark -
- (void)setIsQueueRecording:(BOOL)isQueueRecording
{
	_isQueueRecording = isQueueRecording;
	if (_activeQueue) {
		if (_isQueueRecording) {
			[_activeQueue pauseAudioPlay];
		} else {
			[_activeQueue resumAudioPlay];
		}
	}
}

@end
