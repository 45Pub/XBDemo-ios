//
//  IMFriendCenterMsg.m
//  IMClient
//
//  Created by pengjay on 13-7-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFriendCenterMsg.h"

@implementation IMFriendCenterMsg
- (id)init
{
	self = [super init];
	if (self)
	{
		self.msgType = IMMsgTypeFriendCenter;
	}
	return self;
}
@end
