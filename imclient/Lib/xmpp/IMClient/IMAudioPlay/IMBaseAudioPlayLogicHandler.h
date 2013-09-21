//
//  IMBaseAudioPlayHandler.h
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMAudioPlayProtocol.h"
#import "IMMsgDeliverProtocol.h"
#import "IMAudioMsg.h"
#import "IMMsgObserveHandler.h"
#import "IMMsgQueueProtocol.h"

typedef NS_ENUM(NSInteger, IMAudioPlayState)
{
	IMAudioPlayStateStoped = 0,
	IMAudioPlayStatePlaying,
	IMAudioPlayStatePauseForNew,
};

@protocol IMBaseAudioPlayLogicHandlerDataSource;
@interface IMBaseAudioPlayLogicHandler : NSObject <IMAudioPlayProtocol, IMMsgDeliverProtocol, IMMsgQueueProtocol>
{
	dispatch_queue_t _playQueue;
	void *_playQueueTag;
	IMAudioPlayState _mState;
	IMAudioMsg *_curMsg;
	IMAudioMsg *_indexMsg;
	IMMsgObserveHandler *_playHandler;
	IMMsgObserveHandler *_procHandler;
}
@property (nonatomic, weak) id <IMBaseAudioPlayLogicHandlerDataSource> dataSource;

- (id)initWithQueue:(dispatch_queue_t)queue;

- (void)preparePlay:(IMAudioMsg *)msg;
- (void)playNextFromSelf:(BOOL)flag;
@end


@protocol IMBaseAudioPlayLogicHandlerDataSource <NSObject>

@required

- (IMAudioMsg *)imAudioPlayHandlerNextMsgFrom:(IMAudioMsg *)msg included:(BOOL)flag;

@end
