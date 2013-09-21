//
//  IMAmrPlayer.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMAmrPlayer.h"

@implementation IMAmrPlayer

- (id)initWithURL:(NSURL *)url
{
	if((self = [super init]))
	{
		self.player = [[PPAmrPlayer alloc]initWithPath:[url absoluteString]];
		self.player.delegate = self;
		[self.player prepare];
	}
	return self;
}

- (id)initWithPath:(NSString *)path
{
	if((self = [super init]))
	{
		self.player = [[PPAmrPlayer alloc]initWithPath:path];
		self.player.delegate = self;
		[self.player prepare];
	}
	return self;
}

- (BOOL)isPlaying
{
	return self.player.mstat == PPPLAYERSTATPLAYING;
}

- (void)dealloc
{
	_player.delegate = nil;
	[_player stop];
}

- (void)play
{
	[self.player play];
}

- (void)stop
{
	[self.player stop];
}

- (void)pause
{
	[self.player pause];
	if([self.delegate respondsToSelector:@selector(imAudioPlayerDidPaused:)])
	{
		[self.delegate imAudioPlayerDidPaused:self];
	}
}

- (void)resume
{
	[self.player resume];
	if([self.delegate respondsToSelector:@selector(imAudioPlayerDidResumed:)])
	{
		[self.delegate imAudioPlayerDidResumed:self];
	}
}

- (void)stopNow
{
	[self.player stop];
}

- (void)ppAmrPlayerDidStop:(PPAmrPlayer *)player
{
	if([self.delegate respondsToSelector:@selector(imAudioPlayerDidEnded:)])
	{
		[self.delegate imAudioPlayerDidEnded:self];
	}
}

- (void)ppAmrPlayerDidStart:(PPAmrPlayer *)player
{
	if([self.delegate respondsToSelector:@selector(imAudioPlayerDidStarted:)])
	{
		[self.delegate imAudioPlayerDidStarted:self];
	}
}
@end
