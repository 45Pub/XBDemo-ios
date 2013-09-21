//
//  IMAudioMsg.m
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMAudioMsg.h"
#import "IMPathHelper.h"
#import "IMUser.h"
#import "IMContext.h"
#import "IMAmrPlayer.h"
#import "IMMsgStorage.h"

@implementation IMAudioMsg
- (id)init
{
	self = [super init];
	if (self) {
		self.msgType = IMMsgTypeAudio;
	}
	return self;
}

- (NSString *)fileLocalPath
{
	if (_localPath == nil) {
		_localPath = [IMPathHelper audioPathWithUserID:self.fromUser.userID fileName:self.msgID];
	}
	return _localPath;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startAudioPlay
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.fileLocalPath]) {
		
		return;
	}
	
	if (_audioPlayer.isPlaying) {
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_audioPlayer = [[IMAmrPlayer alloc]initWithPath:self.fileLocalPath];
		_audioPlayer.delegate = self;
		[_audioPlayer play];
	});
}


- (void)stopAudioPlay
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_audioPlayer stopNow];
	});
}

- (void)pauseAudioPlay
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_audioPlayer pause];
	});
}

- (void)resumAudioPlay
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_audioPlayer resume];
	});
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)imAudioPlayerDidStarted:(IMAudioPlayer *)player
{
	self.playState = IMMsgPlayStatePlaying;
}

- (void)imAudioPlayerDidEnded:(IMAudioPlayer *)player
{
	self.playState = IMMsgPlayStatePlayed;
	[[IMContext sharedContext].msgStorage updateMsgState:self];
}

- (void)imAudioPlayerDidPaused:(IMAudioPlayer *)player
{
	self.playState = IMMsgPlayStatePause;
}

- (void)imAudioPlayerDidResumed:(IMAudioPlayer *)player
{
	self.playState = IMMsgPlayStatePlaying;
}
@end
