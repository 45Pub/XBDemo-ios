//
//  IMNewMsgNotifyManager.m
//  IMClient
//
//  Created by pengjay on 13-7-18.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMNewMsgNotifyManager.h"
#import "IMConfiguration.h"
#import "IMDefaultConfigurator.h"
#import "IMMsgQueueManager.h"
#import "IMUser.h"
#import "IMMsg.h"
@implementation IMNewMsgNotifyManager

- (instancetype)initWithMsgQueueMgr:(IMMsgQueueManager *)msgQueueMgr
{
	self = [super init];
	if (self) {
		_msgQueueMgr = msgQueueMgr;
		[self initAudioSession];
	}
	return self;
}

- (void)dealloc
{
	[_newMsgTintPlayer stop];
}

- (void)initAudioSession
{
	AVAudioSession *session = [AVAudioSession sharedInstance];
	[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	UInt32 doChangeDefaultRoute = 1;
	AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
	[session setActive:YES error:nil];
}

- (void)deliverMsg:(IMMsg *)msg
{
	if ([_msgQueueMgr msgQueueActiving:msg.fromUser])
		return;
	
	if (msg.fromType != IMMsgFromOther) {
		return;
	}
	
	if (_newMsgTintPlayer == nil) {
		_newMsgTintPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[IMConfiguration sharedInstance].configurator.alertSoundURLForNewMsg
																  error:nil];
	}
	
	BOOL playSound = [[IMConfiguration sharedInstance].configurator shouldAlertNewMsgIn];
	BOOL playVibrate = [[IMConfiguration sharedInstance].configurator shouldVibrateNewMsgIn];
	
	if (playSound && !_newMsgTintPlayer.isPlaying && _msgQueueMgr.isQueueRecording == NO) {
		[_newMsgTintPlayer play];
	}
	
	if (playVibrate) {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
}

@end
