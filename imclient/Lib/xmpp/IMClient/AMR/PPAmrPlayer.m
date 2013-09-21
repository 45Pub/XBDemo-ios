//
//  PPAmrPlayer.m
//  PPLibTest
//
//  Created by Paul Wang on 12-7-3.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PPAmrPlayer.h"
//#import "PPCore.h"
#import "AudioSessionUtil.h"

static UInt32 kAmrPlayerBufferSizeBytes = 0x10000; // 64k
static void propertyListenerCallback(void *inUserData, AudioQueueRef queueObject, AudioQueuePropertyID propertyID);
static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer);


@interface PPAmrPlayer()
- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;
- (void)playBackIsRunningStateChanged;
- (void)cleanupAudioQueue;
@end

@implementation PPAmrPlayer
@synthesize amrPath, mstat, delegate, userInfo;
- (id)initWithPath:(NSString *)path
{
    if((self = [super init]))
    {
        self.amrPath = path;
        mstat = PPPLAYERSTATSTOP;
    }
    return self;
}

- (id)init
{
    return [self initWithPath:nil];
}

- (void)dealloc
{
//    NSLog(@"release");
    delegate = nil;
    if(mstat != PPPLAYERSTATSTOP)
    {
        AudioQueueRemovePropertyListener(queue, kAudioQueueProperty_IsRunning, propertyListenerCallback, self);
        [self stop];
    }
    [self cleanupAudioQueue];
    
    [amrPath release];
	amrPath = nil;
	[userInfo release];
	userInfo = nil;
    [super dealloc];
}

- (void)setupAmrPCMAudioFormat
{
    dataFormat.mSampleRate = 8000.0f;
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mFormatFlags = 12;
    dataFormat.mBytesPerPacket = 2;
    dataFormat.mFramesPerPacket = 1;
    dataFormat.mBytesPerFrame = 2;
    dataFormat.mChannelsPerFrame = 1;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mReserved = 0;
}

- (void)cleanupAudioQueue
{
    if(queue != NULL)
    {
        AudioQueueDispose(queue, true);
        queue = NULL;
    }
}

- (int)prepare
{
   if(mstat != PPPLAYERSTATSTOP)
       return -1;
    
    if(amrPath == nil)
        return -2;
    
    if(_wavbuf != nil)
    {
        [_wavbuf release];
        _wavbuf = nil;
    }
    
    _wavbuf = [[amr2wavBuffer alloc]initWithPath:amrPath];
    
    if(_wavbuf == nil)
        return -3;
    
    [self setupAmrPCMAudioFormat];
    [self cleanupAudioQueue];
    AudioQueueNewOutput(&dataFormat, BufferCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &queue);

    numPacketsToRead = kAmrPlayerBufferSizeBytes / dataFormat.mBytesPerPacket;
    
    // don't need packet descriptions for CBR data
    packetDescs = nil;
    
    AudioQueueAddPropertyListener(queue, kAudioQueueProperty_IsRunning, propertyListenerCallback, self);

    packetIndex = 0;
    for (int i = 0; i < NUM_QUEUE_BUFFERS; i++)
    {
        AudioQueueAllocateBuffer(queue, kAmrPlayerBufferSizeBytes, &buffers[i]);
        if ([self readPacketsIntoBuffer:buffers[i]] == 0)
        {
            // this might happen if the file was so short that it needed less buffers than we planned on using
            NSLog(@"too short");
            break;
        }
    }
    NSLog(@"prepare end");
    trackEnded = NO;
    mstat = PPPLAYERSTATPREPARE;
    return 0;
}

- (int)play
{
//    [AudioSessionUtil headPlusinChangeToSpeaker];
    
    if(trackEnded == YES)
        return -1;
    
    if(mstat != PPPLAYERSTATPREPARE)
        return -2;
    
    OSStatus result = AudioQueuePrime(queue, 1, nil); 
    if (result)
    {
        NSLog(@"play: error priming AudioQueue[%ld]", result);
        mstat = PPPLAYERSTATSTOP;
        return -3;
    }
    AudioQueueStart(queue, nil);
    mstat = PPPLAYERSTATPLAYING;
    NSLog(@"===Queen start");
    return 0;
}

- (void)stop
{
    if(queue != NULL)
        AudioQueueStop(queue, YES); // <-- YES means stop immediately
    mstat = PPPLAYERSTATSTOP;
}

- (void)pause
{
	AudioQueuePause(queue);
}

- (void)resume
{
	AudioQueueStart(queue, nil);
}

#pragma mark -
- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer
{
    UInt32  numPackets;
    buffer->mAudioDataByteSize = [_wavbuf getWavBuffer:buffer->mAudioData];
    
    numPackets = buffer->mAudioDataByteSize;    
    if (numPackets > 0)
    {
        // - End Of File has not been reached yet since we read some packets, so enqueue the buffer we just read into
        // the audio queue, to be played next
        // - (packetDescs ? numPackets : 0) means that if there are packet descriptions (which are used only for Variable
        // BitRate data (VBR)) we'll have to send one for each packet, otherwise zero
        //        buffer->mAudioDataByteSize = numBytes;
        AudioQueueEnqueueBuffer(queue, buffer, (packetDescs ? numPackets : 0), packetDescs);
        
        // move ahead to be ready for next time we need to read from the file
        packetIndex += numPackets;
    }
    
    return numPackets;
}

- (void) callbackForBuffer:(AudioQueueBufferRef) buffer
{
    if (trackEnded)
        return;
    
    if ([self readPacketsIntoBuffer:buffer] == 0)
    {
            // set it to stop, but let it play to the end, where the property listener will pick up that it actually finished
            AudioQueueStop(queue, NO);
            trackEnded = YES;
    }
}



- (void)playBackIsRunningStateChanged
{
    UInt32 isRunning;
    UInt32 ioDataSize = sizeof(isRunning);
    AudioQueueGetProperty(queue, kAudioQueueProperty_IsRunning, &isRunning, &ioDataSize );
    if ( isRunning )
    {
        NSLog(@"started===");
        if ([delegate respondsToSelector:@selector(ppAmrPlayerDidStart:)] )
        {
            dispatch_async(dispatch_get_main_queue(), ^{

            [delegate ppAmrPlayerDidStart:self];
            });

        }
    }
    else
    {
        NSLog(@"stoped===");
        mstat = PPPLAYERSTATSTOP;
        if ([delegate respondsToSelector:@selector(ppAmrPlayerDidStop:)] )
        {
            dispatch_async(dispatch_get_main_queue(), ^{

            [delegate ppAmrPlayerDidStop:self];
            });

        }
        
    }

    
}

#pragma mark - CallBack
static void propertyListenerCallback(void *inUserData, AudioQueueRef queueObject, AudioQueuePropertyID propertyID)
{
    if (propertyID == kAudioQueueProperty_IsRunning)
    {
        PPAmrPlayer *player = (PPAmrPlayer *)inUserData;
        [player playBackIsRunningStateChanged];
        
    }
}

static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer)
{
    // redirect back to the class to handle it there instead, so we have direct access to the instance variables
    [(PPAmrPlayer*)inUserData callbackForBuffer:buffer];
}
@end
