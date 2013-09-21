//
//  IMDefaultConfigurator.m
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMDefaultConfigurator.h"


@implementation IMDefaultConfigurator

- (NSURL *)fileUploadURL
{
	NSString *urlstr = @"http://wz.sinldo.com/doctorchat/api/index.php?fun=postfile";
	return [NSURL URLWithString:urlstr];
}

- (NSString *)msgPostType:(IMMsgType)msgType isp2p:(BOOL)isp2p thumbnail:(BOOL)isThumbmail
{
	NSInteger type = 0;
	if (msgType == IMMsgTypePic)
		type = 1;
	else if (msgType == IMMsgTypeVideo && isThumbmail == YES)
		type = 2;
	else if (msgType == IMMsgTypeVideo && isThumbmail == NO)
		type = 3;
	else
		type = 4;
	if (!isp2p) {
		type += 10;
	}
	return [NSString stringWithFormat:@"%d", type];
}

- (UIImage *)defaultDiscussGroupAvatar
{
	return nil;
}

- (UIImage *)defaultUserAvatar
{
	return nil;
}

- (BOOL)shouldPlaySoundRecvMsg
{
	return NO;
}
- (BOOL)shouldAlertNewMsgIn
{
	return YES;
}
- (BOOL)shouldVibrateNewMsgIn
{
	return YES;
}
- (BOOL)shouldPlaySoundSendMsg
{
	return NO;
}
- (NSURL *)soundURLForRecvMsg
{
	return [[NSBundle mainBundle] URLForResource: @"ReceivedMessage"
								   withExtension: @"caf"];
}
- (NSURL *)soundURLForSendMsg
{
	return [[NSBundle mainBundle] URLForResource: @"SentMessage"
								   withExtension: @"caf"];
}

- (NSURL *)alertSoundURLForNewMsg
{
	return [[NSBundle mainBundle] URLForResource: @"newmsgTint"
								   withExtension: @"caf"];
}
@end
