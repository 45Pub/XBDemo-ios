//
//  IMFileUploader.m
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFileUploader.h"
#import "ASIFormDataRequest.h"

@implementation IMFileUploader
- (void)dealloc
{
	[self cancelUpload];
}

- (void)cancelUpload
{
	[_request setDelegate:nil];
	[_request setUploadProgressDelegate:nil];
	[_request cancel];
	
}

- (void)uploadFile:(NSString *)localPath postURLStr:(NSString *)urlstr postDic:(NSDictionary *)dic
{
	if (localPath == nil || urlstr == nil) {
		if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFailed:)]) {
			[self.delegate imFileUploaderDidFailed:self];
		}
		return;
	}
	
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:localPath error:nil];
	totalSize = [attributes[NSFileSize] longLongValue];
	
	NSURL *url = [NSURL URLWithString:urlstr];
	_request = [ASIFormDataRequest requestWithURL:url];
	if (dic) {
		for (NSString *key in dic.allKeys) {
			[_request setPostValue:[dic objectForKey:key] forKey:key];
		}
	}
	
	[_request addFile:localPath forKey:@"upfile"];
	[_request setDelegate:self];
	[_request setDidStartSelector:@selector(uploadStart:)];
	[_request setDidFinishSelector:@selector(uploadFinished:)];
	[_request setDidFailSelector:@selector(uploadFailed:)];
	[_request setUploadProgressDelegate:self];
	[_request startAsynchronous];
}

#pragma mark -
- (void)uploadStart:(ASIHTTPRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(imFileUploaderDidStarted:)]) {
		[self.delegate imFileUploaderDidStarted:self];
	}
}

- (void)uploadFinished:(ASIHTTPRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(imFileUploaderDidFinished:resp:)]) {
		[self.delegate imFileUploaderDidFinished:self resp:request.responseString];
	}
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
		NSUInteger sendbytes = bytes;
		[self.delegate imFileUploader:self processSize:sendbytes TotalSize:totalSize];
	}
}

- (void)setProgress:(float)newProgress
{
	if ([self.delegate respondsToSelector:@selector(imFileUploader:procProgress:)]) {
		[self.delegate imFileUploader:self procProgress:newProgress];
	}
}

@end
