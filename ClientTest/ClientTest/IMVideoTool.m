//
//  IMVideoTool.m
//  GoComIM
//
//  Created by 王鹏 on 13-6-29.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMVideoTool.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@implementation IMVideoTool
+ (void)encodeVideoOrientation:(NSURL *)orginFileURL outputFile:(NSURL *)outputURL hander:(VideoCompleteHander)hander
{
	AVURLAsset * videoAsset = [[AVURLAsset alloc]initWithURL:orginFileURL options:nil];
	
	AVAssetTrack *sourceVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	AVAssetTrack *sourceAudioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
	
	AVMutableComposition* composition = [AVMutableComposition composition];
	
	AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
								   ofTrack:sourceVideoTrack
									atTime:kCMTimeZero error:nil];
	[compositionVideoTrack setPreferredTransform:sourceVideoTrack.preferredTransform];
	
	AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
																				preferredTrackID:kCMPersistentTrackID_Invalid];
	[compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
								   ofTrack:sourceAudioTrack
									atTime:kCMTimeZero error:nil];
	
	
	CGSize videoSize = compositionVideoTrack.naturalSize;
	BOOL isPortrait_ = [[self class] isVideoPortrait:videoAsset];
	if(isPortrait_) {
		NSLog(@"video is portrait ");
		videoSize = CGSizeMake(videoSize.height, videoSize.width);
	}
	
	AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
	AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
	[layerInstruction setTransform:compositionVideoTrack.preferredTransform atTime:kCMTimeZero];
	
	AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
	videoComposition.frameDuration = CMTimeMake(1,30);
	videoComposition.renderScale = 1.0;
	videoComposition.renderSize = videoSize;
	instruction.layerInstructions = [NSArray arrayWithObject: layerInstruction];
	instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
	videoComposition.instructions = [NSArray arrayWithObject: instruction];
	
	AVAssetExportSession * assetExport = [[AVAssetExportSession alloc] initWithAsset:composition
																		  presetName:AVAssetExportPresetMediumQuality];
	
	NSString* videoName = @"export.mov";
	NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
	NSLog(@"%@/n%@", exportPath, outputURL);
	NSURL * exportUrl = [NSURL fileURLWithPath:exportPath];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
	}
	
	assetExport.outputFileType = AVFileTypeQuickTimeMovie;
	assetExport.outputURL = exportUrl;
	assetExport.shouldOptimizeForNetworkUse = YES;
	assetExport.videoComposition = videoComposition;
	
	[assetExport exportAsynchronouslyWithCompletionHandler:
	 ^(void ) {
		 switch (assetExport.status)
		 {
			 case AVAssetExportSessionStatusCompleted:
				 //                export complete
				 NSLog(@"Export Complete");
				 [[NSFileManager defaultManager] moveItemAtURL:exportUrl toURL:outputURL error:nil];
				 hander(YES);
				 break;
			 case AVAssetExportSessionStatusFailed:
				 NSLog(@"Export Failed");
				 NSLog(@"ExportSessionError: %@", [assetExport.error localizedDescription]);
				 hander(NO);
				 //                export error (see exportSession.error)
				 break;
			 case AVAssetExportSessionStatusCancelled:
				 NSLog(@"Export Failed");
				 NSLog(@"ExportSessionError: %@", [assetExport.error localizedDescription]);
				 hander(NO);
				 //                export cancelled
				 break;
		 }
	 }];
	[videoAsset release];
	[assetExport release];
}

+ (BOOL)isVideoPortrait:(AVAsset *)asset
{
	BOOL isPortrait = FALSE;
	NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
	if([tracks    count] > 0) {
		AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
		
		CGAffineTransform t = videoTrack.preferredTransform;
		// Portrait
		if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
		{
			isPortrait = YES;
		}
		// PortraitUpsideDown
		if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
			
			isPortrait = YES;
		}
		// LandscapeRight
		if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
		{
			isPortrait = FALSE;
		}
		// LandscapeLeft
		if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
		{
			isPortrait = FALSE;
		}
	}
	return isPortrait;
}

@end
