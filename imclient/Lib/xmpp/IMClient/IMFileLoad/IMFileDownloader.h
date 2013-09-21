//
//  IMFileDownloader.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol IMFileDownloaderDelegate;
@class ASIHTTPRequest;

@interface IMFileDownloader : NSObject
{
	ASIHTTPRequest *_request;

}

@property (nonatomic, weak) id <IMFileDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSString *urlstr;
- (void)downloadWithFileURLstr:(NSString *)url savePath:(NSString *)localPath;
- (void)cancelDownload;
@end

@protocol IMFileDownloaderDelegate <NSObject>
@optional
- (void)imFileDownloaderDidStarted:(IMFileDownloader *)downloader;
- (void)imFileDownloaderDidFinished:(IMFileDownloader *)downloader;
- (void)imFileDownloaderDidFailed:(IMFileDownloader *)downloader;
- (void)imFileDownloader:(IMFileDownloader *)downloader processSize:(NSUInteger)proSize TotalSize:(NSUInteger)total;
- (void)imFileDownloader:(IMFileDownloader *)downloader procProgress:(CGFloat)progress;
@end