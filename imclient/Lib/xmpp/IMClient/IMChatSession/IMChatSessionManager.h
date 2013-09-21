//
//  IMChatSessionManager.h
//  IMClient
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDMulticastDelegate.h"

#import "IMMsgDeliverProtocol.h"

@protocol IMChatSessionManagerDelegate;
@class IMMsgStorage;
@class IMMsg;
@class IMChatSession;
@class IMMsgQueueManager;
@class IMUser;

@interface IMChatSessionManager : NSObject <IMMsgDeliverProtocol>
{
	GCDMulticastDelegate <IMChatSessionManagerDelegate> *_delegates;
	NSMutableArray *_sessions;
	dispatch_queue_t _seQueue;
	void *_seQueueTag;
	IMMsgStorage *_msgStorage;
	IMMsgQueueManager *_msgQueueMgr;
	NSUInteger unreadTotalNum;
}

- (instancetype)initWithMsgStorage:(IMMsgStorage *)msgStorage
					 dispatchQueue:(dispatch_queue_t)queue
					   msgQueueMgr:(IMMsgQueueManager *)msgQueueMgr;

- (void)freshChatSession;
- (void)readChatSession:(IMChatSession *)session;
- (void)readChatSessionWithUser:(IMUser *)fromUser;
- (void)deleteChatSessionWithUser:(IMUser *)fromUser;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;
@end


@protocol IMChatSessionManagerDelegate <NSObject>

@optional
- (void)imChatSessionDidChanged:(IMChatSessionManager *)mgr
					   sessions:(NSArray *)sessions
					  unreadNum:(NSUInteger)unreadNum;
@end
