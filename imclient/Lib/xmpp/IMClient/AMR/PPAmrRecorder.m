//
//  PPAmrRecorder.m
//  PPLibTest
//
//  Created by Paul Wang on 12-7-5.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PPAmrRecorder.h"
//#import "PPCore.h"


static void propertyListenerCallback(void *inUserData, AudioQueueRef queueObject, AudioQueuePropertyID propertyID)
;
static void MyInputBufferHandler(	void *								inUserData,
                                 AudioQueueRef						inAQ,
                                 AudioQueueBufferRef					inBuffer,
                                 const AudioTimeStamp *				inStartTime,
                                 UInt32								inNumPackets,
                                 const AudioStreamPacketDescription*	inPacketDesc);


@interface PPAmrRecorder()
- (void)cleanupAudioQueue;
@end

@implementation PPAmrRecorder
@synthesize delegate, limitRecordFrames, mPath, isRecording, mRecordFrames, recrodEnd, userInfo, showMeter;

- (id)init
{
    if((self = [super init]))
    {
        isRecording = NO;
        limitRecordFrames = 0;
    }
    return self;
}


- (void)dealloc
{
    delegate = nil;
    if(recrodEnd == NO)
    {
        AudioQueueRemovePropertyListener(mQueue, kAudioQueueProperty_IsRunning, propertyListenerCallback, self);
        AudioQueueStop(mQueue, YES);
    }
    [self cleanupAudioQueue];
    
	[mPath release];
	mPath = nil;
	[userInfo release];
	userInfo = nil;
    [super dealloc];
}

- (void)setupRecordPCMAudioFormat
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
    if(mQueue != NULL)
    {
        AudioQueueDispose(mQueue, true);
        mQueue = NULL;
    }
}


- (int)startRecodeWithPath:(NSString *)path
{
    if(path == nil || [path length] <= 0)
        return -1;
	
//	OSStatus error;
//	UInt32 category;
//	category = kAudioSessionCategory_PlayAndRecord;
//	error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
//	if (error) printf("couldn't set audio category!");
//	AudioSessionSetActive(true);
	
	if(isRecording == YES)
        return -4;
    
    if(_amrbuf != nil)
    {
        [_amrbuf release];
		_amrbuf = nil;
    }
    
    _amrbuf = [[wav2amrBuffer alloc]initWithPath:path];
    if(_amrbuf == nil)
        return -2;
    _isCanceled = NO;
    self.mPath = path;
    
    [self setupRecordPCMAudioFormat];
    [self cleanupAudioQueue];
    
    AudioQueueNewInput(&dataFormat, MyInputBufferHandler, self, NULL, NULL, 0, &mQueue);
    
    if(showMeter == YES)
    {
        UInt32 val = 1;
        OSStatus ret = AudioQueueSetProperty(mQueue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
        if(ret != noErr)
        {
            printf("Error enabling level metering\n");
        }
    }
    
    AudioQueueAddPropertyListener(mQueue, kAudioQueueProperty_IsRunning, propertyListenerCallback, self);
    for (int i = 0; i < kNumberRecordBuffers; ++i) {
        mBuffers[i] = nil;
        AudioQueueAllocateBuffer(mQueue, 8000, &mBuffers[i]);
        AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL);
    }
    
    OSStatus result = AudioQueueStart(mQueue, NULL);
    if(result)
        return -3;
    
    isRecording = YES;
    mRecordFrames = 0;
    recrodEnd = NO;
    return 0;

}

- (void)stopRecordImd:(BOOL)flag
{
    if(isRecording == NO)
        return;
    
    recrodEnd = YES;
    AudioQueueStop(mQueue, flag);
    return;
}

- (void)stopAndCancel
{
	_isCanceled = YES;
	[self stop];
}

- (void)stop
{
    [self stopRecordImd:YES];
}

- (void)record
{
    AudioQueueStart(mQueue, NULL);
}

- (void)pause
{
    AudioQueuePause(mQueue);
}

- (CGFloat)getPeakPower
{
    if(isRecording == NO || mQueue == nil)
        return 0.0f;
    
    UInt32 dataSize = sizeof(AudioQueueLevelMeterState) * dataFormat.mChannelsPerFrame;
    AudioQueueLevelMeterState *levels = (AudioQueueLevelMeterState*)malloc(dataSize);
    
    OSStatus rc = AudioQueueGetProperty(mQueue, kAudioQueueProperty_CurrentLevelMeter, levels, &dataSize);
    if (rc) {
//        PPLOG(@"NoiseLeveMeter>>takeSample - AudioQueueGetProperty(CurrentLevelMeter) returned %ld", rc);
    }
    
    float channelAvg = 0;
    for (int i = 0; i < dataFormat.mChannelsPerFrame; i++) {
        channelAvg += levels[i].mPeakPower;
    }
    free(levels);
    
    // This works because in this particular case one channel always has an mAveragePower of 0.
    return channelAvg;
}

#pragma mark -
- (void)putWavBuffer:(void *)buffer bsize:(size_t)bufsize
{
    int f = [_amrbuf putWavBuffer:buffer bsize:bufsize];
    mRecordFrames += f;
}

- (void)recordeIsRunningStateChanged
{
    UInt32 isRunning;
    UInt32 ioDataSize = sizeof(isRunning);
    AudioQueueGetProperty(mQueue, kAudioQueueProperty_IsRunning, &isRunning, &ioDataSize );
    if ( isRunning )
    {
//        PPLOG(@"record started===");
        if ([delegate respondsToSelector:@selector(ppAmrRecorderDidSatart:)] )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [delegate ppAmrRecorderDidSatart:self];
            });
            
        }
    }
    else
    {
//        PPLOG(@"record stoped===");
        [_amrbuf release];
        _amrbuf = nil;
		if(_isCanceled == YES)
		{
			if ([delegate respondsToSelector:@selector(ppAmrRecorderDidCancel:)] )
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					
					[delegate ppAmrRecorderDidCancel:self];
				});
				
			}
		}
		else
		{
			if ([delegate respondsToSelector:@selector(ppAmrRecorderDidStop:)] )
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					
					[delegate ppAmrRecorderDidStop:self];
				});
				
			}
		}
        isRecording = NO;
    }
    
    
}


#pragma mark -- CallBack
static void propertyListenerCallback(void *inUserData, AudioQueueRef queueObject, AudioQueuePropertyID propertyID)
{
    if (propertyID == kAudioQueueProperty_IsRunning)
    {
        PPAmrRecorder *ar = (PPAmrRecorder *)inUserData;
        [ar recordeIsRunningStateChanged];
    }
}

static void MyInputBufferHandler(	void *								inUserData,
                                 AudioQueueRef						inAQ,
                                 AudioQueueBufferRef					inBuffer,
                                 const AudioTimeStamp *				inStartTime,
                                 UInt32								inNumPackets,
                                 const AudioStreamPacketDescription*	inPacketDesc)
{
    PPAmrRecorder *ar = (PPAmrRecorder *)inUserData;
    if(ar.limitRecordFrames > 0)
    {
        if(ar.mRecordFrames > ar.limitRecordFrames)
        {
            AudioQueueStop(inAQ, NO);
            return;
        }
    }
    
    if(inNumPackets > 0)
    {
        [ar putWavBuffer:inBuffer->mAudioData bsize:inBuffer->mAudioDataByteSize];
        if(ar.recrodEnd == NO)
            AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);

    }
}


@end
