//
//  IMAudioPlayer.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMAudioPlayer.h"

@implementation IMAudioPlayer
- (id)initWithURL:(NSURL *)url
{
	if((self = [super init]))
	{
	
	}
	return self;
}
- (id)initWithPath:(NSString *)path
{
	if((self = [super init]))
	{
		
	}
	return self;
}

- (BOOL)isPlaying
{
	return NO;
}

- (void)play
{
	if([_delegate respondsToSelector:@selector(imAudioPlayerDidStarted:)])
	{
		[_delegate imAudioPlayerDidStarted:self];
	}
	[self performSelector:@selector(test) withObject:nil afterDelay:10.0f];
}

- (void)test
{
	if([_delegate respondsToSelector:@selector(imAudioPlayerDidEnded:)])
	{
		[_delegate imAudioPlayerDidEnded:self];
	}
}

- (void)stop
{
	if([_delegate respondsToSelector:@selector(imAudioPlayerDidEnded:)])
	{
		[_delegate imAudioPlayerDidEnded:self];
	}
}

- (void)stopNow
{
	[self stop];
}

- (void)pause
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(test) object:nil];
	if([_delegate respondsToSelector:@selector(imAudioPlayerDidPaused:)])
	{
		[_delegate imAudioPlayerDidPaused:self];
	}
}

- (void)resume
{
	if([_delegate respondsToSelector:@selector(imAudioPlayerDidResumed:)])
	{
		[_delegate imAudioPlayerDidResumed:self];
	}
	[self performSelector:@selector(test) withObject:nil afterDelay:3.0f];

}

@end
