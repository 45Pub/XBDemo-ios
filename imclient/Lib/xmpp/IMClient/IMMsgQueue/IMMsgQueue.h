//
//  IMMsgQueue.h
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMsgDeliverProtocol.h"
#import "IMAudioPlayProtocol.h"
#import "IMBaseAudioPlayLogicHandler.h"
#import "IMMsgStorage.h"
#import "IMUser.h"
#import "IMMsg.h"
#import "IMMsgQueueProtocol.h"

typedef NS_ENUM(NSInteger, IMMsgQueueAudioMode) {
	IMMsgQueueAudioModeOne,
	IMMsgQueueAudioModePrvChat,
	IMMsgQueueAudioModeRoomChat,
};

@protocol IMMsgQueueDelegate;

@interface IMMsgQueue : NSObject <IMMsgDeliverProtocol, IMAudioPlayProtocol,
								IMMsgQueueProtocol, IMBaseAudioPlayLogicHandlerDataSource>
{
	IMUser *_fromUser;
	IMBaseAudioPlayLogicHandler *_audioMgr;
	IMMsgStorage *_msgStorage;
	
	dispatch_queue_t _mqueue;
	void *_mqueueTag;
	
	NSMutableArray *_displayArray;
	NSDate *_groupTime;
	BOOL _groupByTime;
	IMMsgQueueAudioMode _audioMode;
	
	IMMsg *_lastMsg;
}

@property (nonatomic, readonly, strong) IMUser *fromUser;
@property (nonatomic, readonly, strong) IMBaseAudioPlayLogicHandler *audioMgr;
@property (nonatomic, readonly) BOOL hasMoreHistroy;
@property (nonatomic, weak) id <IMMsgQueueDelegate> delegate;

- (instancetype)initWithUser:(IMUser *)user msgStorage:(IMMsgStorage *)msgStorage queue:(dispatch_queue_t)queue
				   audioMode:(IMMsgQueueAudioMode)mode groupFlag:(BOOL)groupFlag;

- (BOOL)beginLoadHistroy;
- (void)deleteMsgs:(NSArray *)delMsgs;
- (NSArray *)msgArray;
@end


@protocol IMMsgQueueDelegate <NSObject>

@optional

- (void)immsgQueue:(IMMsgQueue *)msgQueue didChanged:(NSArray *)msgArray;
- (void)immsgQueue:(IMMsgQueue *)msgQueue didLoadHistory:(NSArray *)hisstroyArray;
- (void)immsgQueue:(IMMsgQueue *)msgQueue didRemoveIndexes:(NSArray *)indexes;

@end