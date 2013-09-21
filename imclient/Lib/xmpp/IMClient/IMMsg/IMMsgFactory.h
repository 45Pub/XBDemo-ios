//
//  IMMsgFactory.h
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMsgAll.h"
#import "IMUser.h"
@interface IMMsgFactory : NSObject
+ (IMMsg *)handleMsgWithFromUser:(IMUser *)fromUser msgUser:(IMUser *)msgUser msgid:(NSString *)msgid
						 msgTime:(NSDate *)msgTime isDelay:(BOOL)isDelay msgBody:(NSString *)msgBody
						  attach:(NSDictionary *)attch msgType:(IMMsgType)msgType msgSize:(UInt64)msgSize
						fromType:(IMMsgFrom)fromType readState:(IMMsgReadState)readState
					   procState:(IMMsgProcState)procState playState:(IMMsgPlayState)playState;
@end
