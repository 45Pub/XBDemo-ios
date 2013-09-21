//
//  IMVideoMsg.m
//  IMClient
//
//  Created by pengjay on 13-7-15.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMVideoMsg.h"
#import "IMPathHelper.h"
#import "IMUser.h"
#import "IMContext.h"
#import "IMVideoFileUploader.h"
#import "IMMsgStorage.h"

@implementation IMVideoMsg

- (id)init
{
	self = [super init];
	if (self) {
		self.msgType = IMMsgTypeVideo;
	}
	return self;
}

- (NSString *)originFileLocalPath
{
	if (_originFilePath == nil) {
		if (self.fromType == IMMsgFromLocalSelf) {
			NSString *filename = [NSString stringWithFormat:@"%@.mp4", self.msgID];
			_originFilePath = [IMPathHelper videoPathWithUserID:self.fromUser.userID fileName:filename isSend:YES];
		} else {
			NSString *filename = [self.originFileRemoteUrl lastPathComponent];
			_originFilePath = [IMPathHelper videoPathWithUserID:self.fromUser.userID fileName:filename isSend:YES];
		}
	}
	return _originFilePath;
}

- (void)uploadFile
{
	if (self.procState == IMMsgProcStateProcessing || self.fromType != IMMsgFromLocalSelf) {
		return;
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.fileLocalPath]) {
		return;
	}
	
	self.procState = IMMsgProcStateProcessing;
	
	
	IMVideoFileUploader *uploader = [[IMVideoFileUploader alloc]init];
	uploader.delegate = self;
	[uploader uploadVideoMsg:self];
	_fileUploader = uploader;
}

- (void)imFileUploaderDidFinished:(IMFileUploader *)uploader dic:(NSDictionary *)dic
{
	if (dic) {
		
		[self setFileRemoteURL:dic[@"thumburl"]];
		[self setOriginFileRemoteURL:dic[@"url"]];
		self.procState = IMMsgProcStateSuc;
		[[IMContext sharedContext].msgStorage updateMsgState:self];
		[[IMContext sharedContext].msgStorage updateMsgBody:self];
	}
	else {
		self.procState = IMMsgProcStateFaied;
		[[IMContext sharedContext].msgStorage updateMsgState:self];
	}
	
	_fileUploader.delegate = nil;
	_fileUploader = nil;
}
@end
