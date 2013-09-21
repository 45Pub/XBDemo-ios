//
//  IMFileUploader.h
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ASIFormDataRequest;
@protocol IMFileUploaderDelegate;

@interface IMFileUploader : NSObject
{
	ASIFormDataRequest *_request;
	NSUInteger totalSize;
}
@property (nonatomic, weak) id <IMFileUploaderDelegate> delegate;

- (void)cancelUpload;
- (void)uploadFile:(NSString *)localPath postURLStr:(NSString *)urlstr postDic:(NSDictionary *)dic;

@end

@protocol IMFileUploaderDelegate <NSObject>

@optional

- (void)imFileUploaderDidStarted:(IMFileUploader *)uploader;
- (void)imFileUploaderDidFinished:(IMFileUploader *)uploader resp:(NSString *)resp;
- (void)imFileUploaderDidFinished:(IMFileUploader *)uploader dic:(NSDictionary *)dic;
- (void)imFileUploaderDidFailed:(IMFileUploader *)uploader;
- (void)imFileUploader:(IMFileUploader *)uploader processSize:(NSUInteger)proSize TotalSize:(NSUInteger)total;
- (void)imFileUploader:(IMFileUploader *)uploader procProgress:(CGFloat)progress;

@end