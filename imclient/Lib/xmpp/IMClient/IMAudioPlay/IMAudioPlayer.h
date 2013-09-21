//
//  IMAudioPlayer.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol IMAudioPlayerDelegate;
@interface IMAudioPlayer : NSObject
- (id)initWithURL:(NSURL *)url;
- (id)initWithPath:(NSString *)path;
- (void)play;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)stopNow;
- (BOOL)isPlaying;
@property (nonatomic, weak) id<IMAudioPlayerDelegate> delegate;
@end

@protocol IMAudioPlayerDelegate <NSObject>

@optional
- (void)imAudioPlayerDidStarted:(IMAudioPlayer *)player;
- (void)imAudioPlayerDidEnded:(IMAudioPlayer *)player;
- (void)imAudioPlayerDidPaused:(IMAudioPlayer *)player;
- (void)imAudioPlayerDidResumed:(IMAudioPlayer *)player;
- (void)imAudioPlayerError:(IMAudioPlayer *)player;
@end