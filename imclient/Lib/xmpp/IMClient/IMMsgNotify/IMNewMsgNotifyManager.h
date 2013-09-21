//
//  IMNewMsgNotifyManager.h
//  IMClient
//
//  Created by pengjay on 13-7-18.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "IMMsgDeliverProtocol.h"
@class IMMsgQueueManager;
@interface IMNewMsgNotifyManager : NSObject <IMMsgDeliverProtocol>
{
	AVAudioPlayer *_newMsgTintPlayer;
	IMMsgQueueManager *_msgQueueMgr;
}

- (instancetype)initWithMsgQueueMgr:(IMMsgQueueManager *)msgQueueMgr;
@end
