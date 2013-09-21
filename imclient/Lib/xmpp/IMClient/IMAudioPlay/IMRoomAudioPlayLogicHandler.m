//
//  IMRoomAudioPlayLogicHandler.m
//  IMClient
//
//  Created by pengjay on 13-7-14.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMRoomAudioPlayLogicHandler.h"
#import "DDLog.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif
@implementation IMRoomAudioPlayLogicHandler

- (id)initWithQueue:(dispatch_queue_t)queue
{
	self = [super initWithQueue:queue];
	if (self) {
		_mState = IMAudioPlayStatePauseForNew;
	}
	return self;
}


- (void)playNextFromSelf:(BOOL)flag
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([self.dataSource respondsToSelector:@selector(imAudioPlayHandlerNextMsgFrom:included:)]) {
			IMAudioMsg *tmpMsg = [self.dataSource imAudioPlayHandlerNextMsgFrom:_indexMsg included:flag];
			
			dispatch_block_t block = ^{
				if (tmpMsg == nil) {
					_mState = IMAudioPlayStatePauseForNew;
				}
				else {
					[self preparePlay:tmpMsg];
				}
			};
			
			if (dispatch_get_specific(_playQueueTag))
				block();
			else
				dispatch_async(_playQueue, block);
			
		}
	});
}

- (void)deliverMsg:(IMMsg *)msg
{
	if (msg.fromType != IMMsgFromOther || msg.msgType != IMMsgTypeAudio) {
		return;
	}

	dispatch_block_t block = ^{
		if (_mState == IMAudioPlayStatePauseForNew) {
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
	dispatch_block_t block = ^{
		if (_mState == IMAudioPlayStateStoped) {
			[self playNextFromSelf:YES];
		}
	};
	
	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}
@end
