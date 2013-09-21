//
//  IMFileDownloader.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFileDownloader.h"
#import "ASIHTTPRequest.h"
@implementation IMFileDownloader

- (void)dealloc
{
	[self cancelDownload];
}

- (void)cancelDownload
{
	[_request setDelegate:nil];
	[_request setDownloadProgressDelegate:nil];
	[_request cancel];
}


- (void)downloadWithFileURLstr:(NSString *)url savePath:(NSString *)localPath
{
	if (url == nil || localPath == nil) {
		if ([self.delegate respondsToSelector:@selector(imFileDownloaderDidFailed:)]) {
			[self.delegate imFileDownloaderDidFailed:self];
		}
	}
	
	_urlstr = url;
	NSURL *fileURL = [NSURL URLWithString:url];
	NSString *tempdic = NSTemporaryDirectory();
	NSString *tmpFile = [tempdic stringByAppendingPathComponent:[localPath lastPathComponent]];
	_request = [ASIHTTPRequest requestWithURL:fileURL];
    [_request setTimeOutSeconds:10.0f];
	[_request setDownloadDestinationPath:localPath];
	[_request setDidStartSelector:@selector(started:)];
    [_request setDidFinishSelector:@selector(finised:)];
    [_request setDidFailSelector:@selector(failed:)];
    [_request setDelegate:self];
    [_request setDownloadProgressDelegate:self];
    [_request setAllowResumeForFileDownloads:YES];
    [_request setTemporaryFileDownloadPath:tmpFile];
    [_request startAsynchronous];
}


- (void)started:(ASIHTTPRequest *)request
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(imFileDownloaderDidStarted:)])
	{
		[self.delegate imFileDownloaderDidStarted:self];
	}
}

- (void)finised:(ASIHTTPRequest *)request
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(imFileDownloaderDidFinished:)])
	{
		[self.delegate imFileDownloaderDidFinished:self];
	}
}

- (void)failed:(ASIHTTPRequest *)request
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(imFileDownloaderDidFailed:)])
	{
		[self.delegate imFileDownloaderDidFailed:self];
	}
}

- (void)setProgress:(float)newProgress
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(imFileDownloader:procProgress:)])
	{
		[self.delegate imFileDownloader:self procProgress:newProgress];
	}
}

- (void)request:(ASIHTTPRequest *)req didReceiveBytes:(long long)bytes
{
	NSUInteger processSize = [req partialDownloadSize];
	NSUInteger totalSize = [req contentLength];
	if(self.delegate && [self.delegate respondsToSelector:@selector(imFileDownloader:processSize:TotalSize:)])
	{
		[self.delegate imFileDownloader:self processSize:processSize TotalSize:totalSize];
	}
}


@end
