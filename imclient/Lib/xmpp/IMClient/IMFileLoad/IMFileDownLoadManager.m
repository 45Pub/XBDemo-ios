//
//  IMFileDownLoadManager.m
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFileDownLoadManager.h"
#import "IMMsgCacheManager.h"
#import "IMMsgStorage.h"
#import "ASIHTTPRequest.h"
#import "IMPathHelper.h"
@implementation IMFileDownLoadManager

- (instancetype)initWithmsgMgr:(IMMsgCacheManager *)msgMgr msgStroage:(IMMsgStorage *)msgStorage
{
	self = [super init];
	if (self) {
		_msgStorage = msgStorage;
		_msgMgr = msgMgr;
		_downloaderUrlForMsg = [NSMutableDictionary dictionary];
		_downloaders = [NSMutableArray array];
		_downloadInfo = [NSMutableArray array];
		_msgidTypeForMsg = [NSMutableDictionary dictionary];
	}
	
	return self;
}

- (void)dealloc
{
	for (IMFileDownloader *downloader in _downloaders) {
		[downloader cancelDownload];
	}

}

- (NSString *)fileURLstrForMsg:(IMMsg *)msg downloadType:(MSGDOWNTYPE)type
{
	return [NSString stringWithFormat:@"http://www.baidu.com"];
}

- (NSString *)saveLoaclPathForMsg:(IMMsg *)msg downloadType:(MSGDOWNTYPE)type
{
	return [IMPathHelper fileThumbPathForMsg:msg];
}

- (void)downloadIMMsg:(IMMsg *)msg downloadType:(MSGDOWNTYPE )type block:(IMFileDownloadBlock)block
{
	if (msg == nil)
		return;
	
	//Downloading
	NSString *urlstr = [self fileURLstrForMsg:msg downloadType:type];
	NSString *localPath = [self saveLoaclPathForMsg:msg downloadType:type];
	if (urlstr == nil) {
		return;
	}
	
	NSString *key = [NSString stringWithFormat:@"%@%d", msg.msgID, type];
	if ([_msgidTypeForMsg objectForKey:key]) {
		return;
	} else {
		[_msgidTypeForMsg setObject:msg forKey:key];
	}
	
	
	IMFileDownloader *downloader = [[IMFileDownloader alloc]init];
	downloader.delegate = self;
	
	[_downloaderUrlForMsg setObject:msg forKey:urlstr];
	[_downloaders addObject:downloader];
	[_downloadInfo addObject:[NSDictionary dictionaryWithObject:block forKey:@"block"]];
	
	[downloader downloadWithFileURLstr:urlstr savePath:localPath];
	
	return;
	
}


#pragma mark - DownloadDelegate

- (void)imFileDownloaderDidStarted:(IMFileDownloader *)downloader
{

}


- (void)imFileDownloaderDidFinished:(IMFileDownloader *)downloader
{

}

- (void)imFileDownloaderDidFailed:(IMFileDownloader *)downloader
{

}

- (void)imFileDownloader:(IMFileDownloader *)downloader processSize:(NSUInteger)proSize TotalSize:(NSUInteger)total
{

}


- (void)imFileDownloader:(IMFileDownloader *)downloader procProgress:(CGFloat)progress
{

}

@end
