//
//  IMContext.h
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMUser, IMMsgStorage, IMMsgQueueManager;
@interface IMContext : NSObject

- (id)initWithLoginUserID:(IMUser *)loginUser msgStorage:(IMMsgStorage *)msgStorage
			  msgQueueMgr:(IMMsgQueueManager *)msgQueueMgr;

@property (nonatomic, readonly, strong) IMUser *loginUser;
@property (nonatomic, readonly, weak) IMMsgStorage *msgStorage;
@property (nonatomic, readonly, weak) IMMsgQueueManager *msgQueueMgr;

+ (IMContext *)sharedContext;
+ (void)initInstance:(IMContext *)context;
+ (void)destroyInstance;
@end
