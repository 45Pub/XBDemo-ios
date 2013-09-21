//
//  IMBaseAudioPlayHandler.m
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMBaseAudioPlayLogicHandler.h"
#import "DDLog.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@implementation IMBaseAudioPlayLogicHandler


- (id)initWithQueue:(dispatch_queue_t)queue
{
	self = [super init];
	if (self) {
		if (queue) {
			_playQueue = queue;
	#if !OS_OBJECT_USE_OBJC
			dispatch_retain(_playQueue);
	#endif
		}
		else {
			const char *name = [NSStringFromClass([self class]) UTF8String];
			_playQueue = dispatch_queue_create(name, NULL);
		}
		
		_playQueueTag = &_playQueueTag;
		dispatch_queue_set_specific(_playQueue, _playQueueTag, _playQueueTag, NULL);
		
		_mState = IMAudioPlayStateStoped;
	}
	return self;
}

- (id)init
{
	self = [super init];
	if (self) {
		const char *name = [NSStringFromClass([self class]) UTF8String];
		_playQueue = dispatch_queue_create(name, NULL);
		_playQueueTag = &_playQueueTag;
		dispatch_queue_set_specific(_playQueue, _playQueueTag, _playQueueTag, NULL);
	}
	return self;
}

- (void)dealloc
{
	_procHandler = nil;
	_playHandler = nil;
	DDLogVerbose(@"QueueHandler dealloc");
#if !OS_OBJECT_USE_OBJC
	dispatch_release(_playQueue);
#endif
}

- (void)preparePlay:(IMAudioMsg *)msg
{
	dispatch_block_t block = ^{
		if (msg.fromType == IMMsgFromOther) {
			_indexMsg = msg;
		}
	
		_mState = IMAudioPlayStatePlaying;
		_playHandler = nil;
		_procHandler = nil;
		[_curMsg stopAudioPlay];
		_curMsg = msg;
		
		__weak typeof(self) wself = self;
		
		_playHandler = [[IMMsgObserveHandler alloc]initWithMsg:_curMsg keyPath:@"playState"
											   compeletedBolck:^(IMMsgObserveHandler *handler, IMMsg *msg1, NSNumber *nValue, NSNumber *oValue) {
												   typeof(self) sself = wself;
												   [sself playHandler:msg1 oldValue:oValue newValue:nValue];
											   }];

		[_playHandler addObserver];
		
	
		_procHandler = [[IMMsgObserveHandler alloc]initWithMsg:_curMsg keyPath:@"procState"
											   compeletedBolck:^(IMMsgObserveHandler *handler, IMMsg *msg1, NSNumber *nValue, NSNumber *oValue) {
												   typeof(self) sself = wself;
												   [sself procHander:msg1];
		}];
		[_procHandler addObserver];
		if ((_curMsg.procState == IMMsgProcStateSuc || _curMsg.fromType == IMMsgFromLocalSelf) &&
			[[NSFileManager defaultManager] fileExistsAtPath:_curMsg.fileLocalPath]) {
			[_curMsg startAudioPlay];
			[self downloadNextAudioMsgFrom:_indexMsg];
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				DDLogVerbose(@"msgqueue: download first [%@]", _curMsg.msgBody);
				[_curMsg downloadFile];
			});
		}
		
	};

	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Handler
- (void)procHander:(IMMsg *)msg
{
	dispatch_block_t block = ^{
		if (_mState != IMAudioPlayStatePlaying)
			return;
		DDLogVerbose(@"msgqueue: download suc and play:%@", msg.msgID);
		if (_curMsg == msg && _curMsg.procState == IMMsgProcStateSuc) {
			[_curMsg startAudioPlay];
			[self downloadNextAudioMsgFrom:_indexMsg];
		}
	};
	
	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}

- (void)playHandler:(IMMsg *)msg oldValue:(NSNumber *)oldV newValue:(NSNumber *)newV
{
	dispatch_block_t block = ^{
		if ([newV intValue] == IMMsgPlayStatePlayed && [oldV integerValue] == IMMsgPlayStatePlaying) {
			if (_mState != IMAudioPlayStatePlaying)
				return;
			DDLogVerbose(@"msgqueue: play end and play next:%@", msg.msgID);
			if (msg == _curMsg && _curMsg.playState == IMMsgPlayStatePlayed) {
				[self playNextFromSelf:YES];
			}
		}
	};
	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)playNextFromSelf:(BOOL)flag
{
	dispatch_block_t block = ^{
		_mState = IMAudioPlayStateStoped;
	};
	
	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}


- (void)downloadNextAudioMsgFrom:(IMAudioMsg *)msg
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([self.dataSource respondsToSelector:@selector(imAudioPlayHandlerNextMsgFrom:included:)]) {
			IMAudioMsg *tmpMsg = [self.dataSource imAudioPlayHandlerNextMsgFrom:msg included:NO];
			if (tmpMsg.fromType != IMMsgFromLocalSelf && (tmpMsg.procState == IMMsgProcStateFaied ||
														  tmpMsg.procState == IMMsgProcStateUnproc)) {
				[tmpMsg downloadFile];
			}
		}
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deliverMsg:(IMMsg *)msg
{
	return;
}


- (void)selectMsg:(IMMsg *)msg
{
	if (msg == nil || msg.msgType != IMMsgTypeAudio)
		return ;
	
	dispatch_block_t block = ^{
		if (_mState == IMAudioPlayStatePlaying) {
			if (msg == _curMsg) {
				if (_curMsg.playState == IMMsgPlayStatePlaying) {
					[_curMsg stopAudioPlay];
				}
				else if (_curMsg.procState == IMMsgProcStateProcessing) {
					[self playNextFromSelf:NO];
				}
				else {
					[self preparePlay:(IMAudioMsg *)msg];
				}
			}
			else {
				[self preparePlay:(IMAudioMsg *)msg];
			}
		}
		else {
			[self preparePlay:(IMAudioMsg *)msg];
		}
		
	};
	
	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}


- (void)startAudioPlay
{
	
}

- (void)stopAudioPlay
{
	dispatch_block_t block = ^{
		_mState = IMAudioPlayStateStoped;
		_playHandler = nil;
		_procHandler = nil;
		[_curMsg stopAudioPlay];
	};

	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}

- (void)pauseAudioPlay
{
	dispatch_block_t block = ^{
		if (_curMsg.playState == IMMsgPlayStatePlaying) {
			[_curMsg pauseAudioPlay];
		}
		else {
			[self stopAudioPlay];
		}
	};
	
	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}

- (void)resumAudioPlay
{
	dispatch_block_t block = ^{
		if (_curMsg.playState == IMMsgPlayStatePause) {
			[_curMsg resumAudioPlay];
		}
		else {
			[self startAudioPlay];
		}
	};
	
	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}

@end
