//
//  IMContext.m
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMContext.h"
#import "IMUser.h"
static IMContext *sharedInstance = nil;

@implementation IMContext

+ (IMContext *)sharedContext
{
	@synchronized(self)
	{
		if (sharedInstance == nil) {
			[NSException raise:@"IMSessino error" format:@"must be init first"];
		}
	}
	return sharedInstance;
}

+ (void)initInstance:(IMContext *)context
{
	@synchronized(self)
	{
		sharedInstance = context;
	}
}

+ (void)destroyInstance
{
	@synchronized(self)
	{
		sharedInstance = nil;
	}
}

- (id)initWithLoginUserID:(IMUser *)loginUser msgStorage:(IMMsgStorage *)msgStorage
			  msgQueueMgr:(IMMsgQueueManager *)msgQueueMgr
{
	self = [super init];
	if (self) {
		_loginUser = loginUser;
		_msgStorage = msgStorage;
		_msgQueueMgr = msgQueueMgr;
	}
	return self;
}


@end
