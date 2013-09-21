//
//  PPAmrRecorder.h
//  PPLibTest
//
//  Created by Paul Wang on 12-7-5.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#include <AudioToolbox/AudioToolbox.h>
#import "wav2amrBuffer.h"
#define kNumberRecordBuffers	1

@protocol PPAmrRecorderDelegate;
@interface PPAmrRecorder : NSObject
{
    AudioQueueRef				mQueue;
    AudioQueueBufferRef			mBuffers[kNumberRecordBuffers];
    AudioStreamBasicDescription dataFormat;
    
    wav2amrBuffer *_amrbuf;
    
    

}
@property (nonatomic, assign) id <PPAmrRecorderDelegate> delegate;
@property (nonatomic) NSUInteger limitRecordFrames;
@property (nonatomic, copy) NSString *mPath;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, readonly) NSUInteger mRecordFrames;
@property (nonatomic, readonly) BOOL recrodEnd;
@property (nonatomic, readonly) BOOL isCanceled;
@property (nonatomic) BOOL showMeter;
@property (nonatomic, retain) id userInfo;

- (int)startRecodeWithPath:(NSString *)path;
- (void)stopRecordImd:(BOOL)flag;
- (CGFloat)getPeakPower;
- (void)pause;
- (void)stop;
- (void)record;
- (void)stopAndCancel;
@end

@protocol PPAmrRecorderDelegate <NSObject>

@optional
- (void)ppAmrRecorderDidSatart:(PPAmrRecorder *)recorder;
- (void)ppAmrRecorderDidStop:(PPAmrRecorder *)recorder;
- (void)ppAmrRecorderDidCancel:(PPAmrRecorder *)recorder;
@end


