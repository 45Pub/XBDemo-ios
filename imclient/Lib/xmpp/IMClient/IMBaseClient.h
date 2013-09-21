//
//  IMBaseClient.h
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

#define DEFAULT_HOST @"qiumihui.cn"
#define DEFAULT_PORT 25222

typedef NS_ENUM(NSInteger, IMClientState)
{
	IMClientStateDisconnected = 0,
	IMClientStateConnecting,
	IMClientStateConnected,
};

@class GCDMulticastDelegate;
@class IMMsg;
@protocol IMClientDelegate;
@class IMMsgObserveHandler;
@class IMUserManager;
@class IMMsgStorage;
@class FMDatabaseQueue;
@class IMMsgCacheManager;
@class IMChatSessionManager;
@class IMMsgQueueManager;
@class IMNewMsgNotifyManager;

@interface IMBaseClient : NSObject
{
	NSString *_myUserID;
	NSString *_myPasswd;
	NSString *_host;
	NSUInteger _port;
	IMClientState _clientState;
	FMDatabaseQueue *_dbQueue;
	IMMsgCacheManager *_msgCacheMgr;
	IMChatSessionManager *_sessionMgr;
	IMMsgQueueManager *_msgQueueMgr;
	IMNewMsgNotifyManager *_msgNotifyMgr;
	IMUserManager *_userMgr;
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
	XMPPvCardSqlStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	IMMsgStorage *_msgStorage;
	
	XMPPRoster *xmppRoster;
	XMPPRosterSqlStorage *xmppRosterStorage;
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	NSCache *_msgHandlerCache;
	
	BOOL shouldSignup;
}

@property (nonatomic, readonly, strong) GCDMulticastDelegate <IMClientDelegate> *delegates;
@property (nonatomic, readonly, strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, readonly, strong) XMPPRoster *xmppRoster;
@property (nonatomic, readonly, strong) XMPPRosterSqlStorage *xmppRosterStorage;
@property (nonatomic, strong) IMUserManager *userMgr;
@property (nonatomic, readonly, strong) IMMsgStorage *msgStorage;
@property (nonatomic, readonly, strong) IMMsgCacheManager *msgCacheMgr;
@property (nonatomic, readonly, strong) IMChatSessionManager *sessionMgr;
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, strong) NSString *devToken;

- (id)initWithUserID:(NSString *)userID passwd:(NSString *)passwd host:(NSString *)host port:(NSUInteger)port;
- (BOOL)connect;
- (BOOL)connectAndSignup;

- (void)reSendMsg:(IMMsg *)msg;
- (void)sendMsg:(IMMsg *)msg;
- (void)sendLocalSysNoteMsg:(IMMsg *)msg;

- (void)sendToken:(NSString*)tokenString;

- (NSArray *)allFirstLetterAndUserInRoster;
- (NSArray *)searchFriendsWithKey:(NSString *)key;

//
- (void)handleRecvMsg:(IMMsg *)msg;
- (BOOL)shoudSendMsg:(IMMsg *)msg;
@end




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol IMClientDelegate <NSObject>

@optional

- (void)imClient:(IMBaseClient *)client stateChanged:(IMClientState)state;
- (void)imClient:(IMBaseClient *)client didRecvMsg:(IMMsg *)msg;
- (void)imClient:(IMBaseClient *)client didLogin:(BOOL)suc withError:(NSError *)error;
- (void)imClient:(IMBaseClient *)client didSignup:(BOOL)suc withError:(NSError *)error;
- (void)imClient:(IMBaseClient *)client conflictWithError:(NSError *)error;
@end