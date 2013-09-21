//
//  IMPrvChatAudioPlayLogicHandler.m
//  IMClient
//
//  Created by pengjay on 13-7-13.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMPrvChatAudioPlayLogicHandler.h"
#import "DDLog.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@implementation IMPrvChatAudioPlayLogicHandler



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
	return;
//	if (msg.fromType != IMMsgFromOther || msg.msgType != IMMsgTypeAudio) {
//		return;
//	}
//	
//	dispatch_block_t block = ^{
//		if (_mState == IMAudioPlayStatePauseForNew) {
//			[self preparePlay:(IMAudioMsg *)msg];
//		}
//	};
//	
//	if (dispatch_get_specific(_playQueueTag))
//		block();
//	else
//		dispatch_async(_playQueue, block);

}

#pragma mark - IMMsgQueueProtocol
- (void)selectMsg:(IMMsg *)msg
{
	if (msg == nil || msg.msgType != IMMsgTypeAudio)
			return ;

	dispatch_block_t block = ^{
		if (_mState == IMAudioPlayStatePlaying) {
			if (msg == _curMsg) {
				if (_curMsg.playState == IMMsgPlayStatePlaying) {
					_mState = IMAudioPlayStateStoped;
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


#pragma mark - AuidoPlayProtocol

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
	};

	if (dispatch_get_specific(_playQueueTag))
		block();
	else
		dispatch_async(_playQueue, block);
}

@end
