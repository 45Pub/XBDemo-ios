//
//  IMVideoFileUploader.m
//  IMClient
//
//  Created by pengjay on 13-7-23.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMVideoFileUploader.h"
#import "IMConfiguration.h"
#import "IMDefaultConfigurator.h"
#import "IMVideoMsg.h"
#import "IMUser.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
@implementation IMVideoFileUploader
- (void)uploadVideoMsg:(IMVideoMsg *)msg
{
	thubmailPostURL = [[IMConfiguration sharedInstance].configurator fileUploadURL];
	thumbType = [[IMConfiguration sharedInstance].configurator msgPostType:IMMsgTypeVideo
																		  isp2p:msg.fromUser.userType&IMUserTypeP2P
																	  thumbnail:YES];
	originType = [[IMConfiguration sharedInstance].configurator msgPostType:IMMsgTypeVideo
																	  isp2p:msg.fromUser.userType&IMUserTypeP2P
																  thumbnail:NO];
	originPath = msg.originFileLocalPath;
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:msg.fileLocalPath] ||
		![[NSFileManager defaultManager] fileExistsAtPath:msg.originFileLocalPath]) {
		if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFailed:)]) {
			[self.delegate imFileUploaderDidFailed:self];
		}
		return;
	}
	
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:msg.fileLocalPath error:nil];
	totalSize = [attributes[NSFileSize] longLongValue];
	attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:msg.originFileLocalPath error:nil];
	totalSize += [attributes[NSFileSize] longLongValue];
	
	_request = [ASIFormDataRequest requestWithURL:thubmailPostURL];
	
	[_request setPostValue:thumbType forKey:@"type"];
	[_request addFile:msg.fileLocalPath forKey:@"upfile"];
	[_request setDelegate:self];
	[_request setDidStartSelector:@selector(uploadStart:)];
	[_request setDidFinishSelector:@selector(uploadFinished:)];
	[_request setDidFailSelector:@selector(uploadFailed:)];
	[_request setUploadProgressDelegate:self];
	[_request startAsynchronous];
}

- (void)cancelUpload
{
	[videoReuest setDelegate:nil];
	[videoReuest setUploadProgressDelegate:nil];
	[videoReuest cancel];
	[super cancelUpload];
}

- (void)uploadOriginVideo
{
	videoReuest = [ASIFormDataRequest requestWithURL:thubmailPostURL];
	
	[videoReuest setPostValue:originType forKey:@"type"];
	[videoReuest addFile:originPath forKey:@"upfile"];
	[videoReuest setDelegate:self];
	[videoReuest setDidStartSelector:@selector(videouploadStart:)];
	[videoReuest setDidFinishSelector:@selector(videouploadFinished:)];
	[videoReuest setDidFailSelector:@selector(videouploadFailed:)];
	[videoReuest setUploadProgressDelegate:self];
	[videoReuest startAsynchronous];
}


- (void)uploadStart:(ASIHTTPRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(imFileUploaderDidStarted:)]) {
		[self.delegate imFileUploaderDidStarted:self];
	}
}

- (void)uploadFinished:(ASIHTTPRequest *)request
{
//	if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFinished:resp:)]) {
//		[self.delegate imFileUploaderDidFinished:self resp:request.responseString];
//	}
	NSDictionary *dic = [[request responseString] objectFromJSONString];
	if ([dic[@"ok"] integerValue] == 1) {
		respDic = [NSMutableDictionary dictionary];
		[respDic setObject:dic[@"url"] forKey:@"thumburl"];
	} else {
		if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFailed:)]) {
			[self.delegate imFileUploaderDidFailed:self];
		}
		return;
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		[self uploadOriginVideo];
	});
}

- (void)uploadFailed:(ASIHTTPRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFailed:)]) {
		[self.delegate imFileUploaderDidFailed:self];
	}
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
	if ([self.delegate respondsToSelector:@selector(imFileUploader:processSize:TotalSize:)]) {
		sendBytes += bytes;
		[self.delegate imFileUploader:self processSize:sendBytes TotalSize:totalSize];
		[self.delegate imFileUploader:self procProgress:(float)sendBytes/(float)totalSize];
	}
}

- (void)setProgress:(float)newProgress
{
	return;
}
#pragma mark -
- (void)videouploadStart:(ASIHTTPRequest *)request
{
	
}

- (void)videouploadFinished:(ASIHTTPRequest *)request
{
	NSDictionary *dic = [[request responseString] objectFromJSONString];
	if ([dic[@"ok"] integerValue] == 1) {
		[respDic setObject:dic[@"url"] forKey:@"url"];
	} else {
		if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFailed:)]) {
			[self.delegate imFileUploaderDidFailed:self];
		}
		return;
	}
	if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFinished:dic:)]) {
		[self.delegate imFileUploaderDidFinished:self dic:respDic];
	}
}

- (void)videouploadFailed:(ASIHTTPRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFailed:)]) {
		[self.delegate imFileUploaderDidFailed:self];
	}
}
@end
