//
//  IMMsgCacheManager.h
//  IMClient
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMMsg;
@class IMUser;
@interface IMMsgCacheManager : NSObject
{
	NSMutableDictionary *_sessionMsgCache;
	NSMutableDictionary *_processingMsgCache;
	NSLock *_mLock;
}

//SessionCacheMsg
- (IMMsg *)getSessionCachedMsgWithUser:(IMUser *)user msgid:(NSString *)msgid;
- (void)addSessionMsgWithUser:(IMUser *)user msg:(IMMsg *)msg;
- (void)removeSessionMsgWithUser:(IMUser *)user;
- (void)removeAllSessionMsg;

//ProcessCacheMsg
/**
 *	@param 	user    fromuser
 */
- (IMMsg *)getProcessCachedMsgWithUser:(IMUser *)user msgid:(NSString *)msgid;
- (void)addProcessMsg:(IMMsg *)msg;
- (void)removeProcessMsg:(IMMsg *)msg;
- (void)removeAllProcessMsg;
@end
