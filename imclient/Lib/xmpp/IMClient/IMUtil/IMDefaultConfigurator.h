//
//  IMDefaultConfigurator.h
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMsg.h"

@interface IMDefaultConfigurator : NSObject
- (NSURL *)fileUploadURL;
- (NSString *)msgPostType:(IMMsgType)msgType isp2p:(BOOL)isp2p thumbnail:(BOOL)isThumbmail;



- (UIImage *)defaultUserAvatar;
- (UIImage *)defaultDiscussGroupAvatar;

- (BOOL)shouldPlaySoundRecvMsg;
- (BOOL)shouldAlertNewMsgIn;
- (BOOL)shouldVibrateNewMsgIn;
- (BOOL)shouldPlaySoundSendMsg;
- (NSURL *)soundURLForRecvMsg;
- (NSURL *)soundURLForSendMsg;
- (NSURL *)alertSoundURLForNewMsg;
@end
