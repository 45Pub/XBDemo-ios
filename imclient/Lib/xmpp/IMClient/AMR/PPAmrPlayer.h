//
//  PPAmrPlayer.h
//  PPLibTest
//
//  Created by Paul Wang on 12-7-3.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioToolbox.h>
#import "amr2wavBuffer.h"

#define NUM_QUEUE_BUFFERS 3
#define kNumAQBufs 6 // number of audio queue buffers we allocate
#define kAQBufSize 32 * 1024 // number of bytes in each audio queue buffer
#define kAQMaxPacketDescs 512 // number of packet descriptions in our array

typedef enum PPPLAYERSTAT
{
    PPPLAYERSTATSTOP = 0,
    PPPLAYERSTATPREPARE,
    PPPLAYERSTATPLAYING,
    PPPLAYERSTATPAUSE,
}PPPLAYERSTAT;

@protocol PPAmrPlayerDelegate;

@interface PPAmrPlayer : NSObject
{
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[NUM_QUEUE_BUFFERS];
    
    amr2wavBuffer *_wavbuf;
    //
    
    AudioStreamBasicDescription dataFormat;
    AudioStreamPacketDescription *packetDescs;
    
    UInt64 packetIndex;
    UInt32 numPacketsToRead;
        
    BOOL trackEnded;
}
@property (nonatomic, readonly) PPPLAYERSTAT mstat; 
@property (nonatomic, copy) NSString *amrPath;
@property (nonatomic, assign) id <PPAmrPlayerDelegate> delegate;
@property (nonatomic, retain) id userInfo;

- (id)initWithPath:(NSString *)path;
- (int)prepare;
- (int)play;
- (void)stop;
- (void)pause;
- (void)resume;
@end


@protocol PPAmrPlayerDelegate <NSObject>

@optional

- (void)ppAmrPlayerDidStop:(PPAmrPlayer *)player;
- (void)ppAmrPlayerDidStart:(PPAmrPlayer *)player;

@end


