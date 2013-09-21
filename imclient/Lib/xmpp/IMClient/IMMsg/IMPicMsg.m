//
//  IMPicMsg.m
//  IMClient
//
//  Created by pengjay on 13-7-15.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMPicMsg.h"
#import "IMPathHelper.h"
#import "IMUser.h"
#import "JSONKit.h"
#import "IMContext.h"
#import "IMMsgStorage.h"
#import "IMConfiguration.h"

@implementation IMPicMsg
- (id)init
{
	self = [super init];
	if (self) {
		self.msgType = IMMsgTypePic;
	}
	return self;
}

- (NSString *)fileLocalPath
{
	if (_localPath == nil) {
		NSString *filename = [NSString stringWithFormat:@"%@.jpg", self.msgID];
		_localPath = [IMPathHelper thumbnailPathWithUserID:self.fromUser.userID fileName:filename];
	}
	return _localPath;
}

- (NSString *)fileRemoteUrl
{
	return [self.msgAttach objectForKey:@"thumburl"];
}

- (void)setOriginFileRemoteURL:(NSString *)originRemtoeURL
{
	self.msgBody = originRemtoeURL;
}

- (void)setFileRemoteURL:(NSString *)remoteURL
{
	if (remoteURL.length <= 0)
		return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.msgAttach];
	[dic setObject:remoteURL forKey:@"thumburl"];
	self.msgAttach = dic;
}

- (NSString *)originFileLocalPath
{
	if (_originFilePath == nil) {
		if (self.fromType == IMMsgFromLocalSelf) {
			NSString *filename = [NSString stringWithFormat:@"%@.jpg", self.msgID];
			_originFilePath = [IMPathHelper picPathWithUserID:self.fromUser.userID fileName:filename isSend:YES];
		} else {
			NSString *filename = [self.originFileRemoteUrl lastPathComponent];
			_originFilePath = [IMPathHelper picPathWithUserID:self.fromUser.userID fileName:filename isSend:NO];
		}
	}
	return _originFilePath;
}

- (NSString *)originFileRemoteUrl
{
	return self.msgBody;
}

- (NSUInteger)originFileSize
{
	return [[self.msgAttach objectForKey:@"size"] integerValue];
}

- (void)uploadFile
{
	if (self.procState == IMMsgProcStateProcessing || self.fromType != IMMsgFromLocalSelf) {
		return;
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.originFileLocalPath]) {
		return;
	}
	
	self.procState = IMMsgProcStateProcessing;
	
	/////////////Custom
	NSDictionary *postDic = nil;
	
	BOOL isp2p = self.fromUser.userType & IMUserTypeP2P;
	NSString *postType = [[IMConfiguration sharedInstance].configurator msgPostType:self.msgType isp2p:isp2p thumbnail:NO];
	postDic = [NSDictionary dictionaryWithObject:postType forKey:@"type"];
	////////////
	
	_fileUploader = [[IMFileUploader alloc]init];
	_fileUploader.delegate = self;
	
	[_fileUploader uploadFile:self.originFileLocalPath postURLStr:[self filePostUrl] postDic:postDic];
}

#pragma mark upload
- (void)imFileUploaderDidFinished:(IMFileUploader *)uploader resp:(NSString *)resp
{
	NSDictionary *dic = [resp objectFromJSONString];
	if ([dic[@"ok"] integerValue] == 1) {
		
		[self setOriginFileRemoteURL:dic[@"url"]];
		[self setFileRemoteURL:dic[@"thumurl"]];
		
		self.procState = IMMsgProcStateSuc;
		[[IMContext sharedContext].msgStorage updateMsgState:self];
		[[IMContext sharedContext].msgStorage updateMsgBody:self];
		[[IMContext sharedContext].msgStorage updateMsgAttach:self];
	}
	else {
		self.procState = IMMsgProcStateFaied;
		[[IMContext sharedContext].msgStorage updateMsgState:self];
	}
	
	_fileUploader.delegate = nil;
	_fileUploader = nil;
	
}
@end
