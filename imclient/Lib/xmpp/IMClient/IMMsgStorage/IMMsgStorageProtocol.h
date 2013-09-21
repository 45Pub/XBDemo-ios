//
//  IMMsgStorageProtocol.h
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import <Foundation/Foundation.h>
#import "IMMsg.h"
@protocol IMMsgStorageProtocol <NSObject>
@required
// Msg
- (void)saveMsg:(IMMsg *)msg; //保存消息
- (void)delMsg:(IMMsg *)msg; //删除消息
- (void)delAllMsg:(IMUser *)user;

- (NSMutableArray *)getUserLastMsg:(IMUser *)user count:(int)cnt; //获取最近消息

- (NSMutableArray *)getUserOlderMsg:(IMUser *)user msgid:(NSString *)msgid count:(int)cnt; // 获取历史消息

- (BOOL)msgExistwithMsgid:(NSString *)msgid user:(IMUser *)user;

//update Msg
- (void)updateMsgState:(IMMsg *)msg; //更新消息的state

- (void)updateMsgAttach:(IMMsg *)msg;

- (void)updateMsgBody:(IMMsg *)msg;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ChatSession
- (void)delAllChatSession;


/**
 *	@brief 删除会话	
  */
- (void)delChatSession:(IMUser *)user;


/**
 *	@brief 清除聊天内容
 */
- (void)clearChatSessionContent:(IMUser *)user;

- (void)addChatSession:(IMMsg *)msg;

- (NSUInteger)unreadTotalNum;

- (void)setAllMsgReaded:(IMUser *)user;

- (NSMutableArray *)getChatSessionList:(NSInteger)cnt;

- (NSMutableArray *)searchUsersInChatSessionWithKeyword:(NSString *)keywrod;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//FriendCenter
- (IMMsgProcState)getFrinedCenterProcStateWithUser:(IMUser *)user;
- (void)updateFriendCenterProcState:(IMMsgProcState)state withUser:(IMUser *)user;

@end
