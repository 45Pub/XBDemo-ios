//
//  IMMsgQueueManager.h
//  IMClient
//
//  Created by pengjay on 13-7-14.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMsgQueue.h"
#import "IMMsgStorage.h"
#import "IMMsgDeliverProtocol.h"
@interface IMMsgQueueManager : NSObject <IMMsgDeliverProtocol>
{
	NSCache *_cacheQueue;
	IMMsgQueue *_activeQueue;
	IMMsgQueue *_globalQueue;

	IMMsgStorage *_msgStorage;
}
@property (nonatomic) BOOL isQueueRecording;
- (id)initWithMsgStorage:(IMMsgStorage *)msgStorage;
- (IMMsgQueue *)openNormalMsgQueueWithUser:(IMUser *)fromUser delegate:(id<IMMsgQueueDelegate>)delegate;
- (void)closeNormalMsgQueueWithUser:(IMUser *)fromUser;
- (BOOL)msgQueueActiving:(IMUser *)fromUser;
@end
