//
//  IMXbcxClient.m
//  IMClient
//
//  Created by pengjay on 13-7-16.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMXbcxClient.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPvCardAvatarModule.h"
//#import "XMPPMessage+XEP0045.h"
#import "NSXMLElement+XEP_0203.h"
#import "XMPPMessage+Custom.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "FMDatabaseQueue.h"
#import <CFNetwork/CFNetwork.h>

#import "IMMsgObserveHandler.h"
#import "IMUser.h"
#import "IMUserManager.h"
#import "IMPathHelper.h"
#import "IMMsgStorage.h"
#import "IMMsgCacheManager.h"
#import "IMChatSessionManager.h"
#import "IMContext.h"
#import "IMMsgFactory.h"
#import "IMMsgQueueManager.h"
#import "IMUser.h"


#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation IMXbcxClient
- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
	
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	////////////////////////////////////////////////////////////////////////////////////////
	xmppRosterStorage = [[XMPPXBRosterSqlStorage alloc]initWithdbQueue:_dbQueue];
	xmppRoster = [[XMPPXBRoster alloc]initWithRosterStorage:xmppRosterStorage];
	
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [[XMPPvCardSqlStorage alloc]init];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	
	//Privacy
	_xmppXBPrivacy = [[XMPPXBPrivacy alloc]init];
	
	
	[xmppReconnect	activate:xmppStream];
	[xmppvCardTempModule activate:xmppStream];
	[xmppRoster activate:xmppStream];
	[_xmppXBPrivacy activate:xmppStream];
	
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	
	[xmppStream setHostName:_host];
	[xmppStream setHostPort:_port];
	
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
	
}


- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppvCardTempModule removeDelegate:self];
	[xmppRoster removeDelegate:self];
	[xmppRoster deactivate];
	[xmppReconnect deactivate];
	[xmppvCardTempModule deactivate];
	[_xmppXBPrivacy deactivate];
	
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
	xmppvCardTempModule = nil;
	xmppvCardStorage = nil;
}

- (XMPPXBRoster *)xbRoster
{
	return (XMPPXBRoster *)xmppRoster;
}


- (XMPPXBRosterSqlStorage *)xbRosterStorage
{
	return (XMPPXBRosterSqlStorage *)xmppRosterStorage;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPXBRosterStorageDelegate
/**
 *	@brief create discussGroup event
 *
 *	@param 	sender
 *	@param 	dgid 	discuss group id , like user jid
 *	@param 	dgName 	discuss group name
 *	@param 	sponsor 	user jid who sponsor this event
 *	@param 	sponsorName 	user nickname
 *	@param 	members 	each item is a NSDictionary , contains "jid", "name"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didCreateDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName members:(NSArray *)members
{
	DDLogVerbose(@"create group:%@:%@:%@:%@:%d", dgid, dgName, sponsor, sponsorName, members.count);

}

/**
 *	@brief delete discuss group event
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didDeletedDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName
{
	DDLogVerbose(@"delete group:%@:%@:%@:%@", dgid, dgName, sponsor, sponsorName);
	
}

/**
 *	@brief you are kicked by the sponer
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didKickedDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName
{
	DDLogVerbose(@"kicked by group:%@:%@:%@:%@", dgid, dgName, sponsor, sponsorName);
}


/**
 *	@brief  add discuss group members event
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didAddDiscussGroupMemebers:(NSArray *)memberArray dgid:(NSString *)dgid
			dgname:(NSString *)dgName sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName
{
	DDLogVerbose(@"add member group:%@:%@:%@:%@:%d", dgid, dgName, sponsor, sponsorName, memberArray.count);
}

/**
 *	@brief  remove discuss group members event
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didRemoveDiscussGroupMemebers:(NSArray *)memberArray dgid:(NSString *)dgid
			dgname:(NSString *)dgName sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName
{
	DDLogVerbose(@"remove member group:%@:%@:%@:%@:%d", dgid, dgName, sponsor, sponsorName, memberArray.count);
}

/**
 *	@brief change discuss group name event
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didChangedDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName
{
	DDLogVerbose(@"changename group:%@:%@:%@:%@", dgid, dgName, sponsor, sponsorName);
}

/**
 *	@brief sponsor quit the discuss group
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didQuitDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName
{
	DDLogVerbose(@"quit group:%@:%@:%@:%@", dgid, dgName, sponsor, sponsorName);
}

#pragma mark - Discuss Group
- (NSArray *)membersForDiscussGroup:(NSString *)dgid
{
	NSArray *xUserArray = [[self xbRosterStorage] discussMembersWithdgid:dgid];
	
	NSMutableArray *resultArray = [NSMutableArray array];
	
	for (XMPPUserObject *xuser in xUserArray) {
		IMUserType type = 0;
		if (xuser.usertype == XMPPUserTypeUser)
			type |= IMUserTypeP2P;
		else
			type |= IMUserTypeDiscuss;
		
		if (xuser.isAdmin)
			type |= IMUserTypeAdmin;
		
		IMUser *user = [_userMgr createCacheUserWithID:xuser.jidStr usertype:type nikename:xuser.nickname];
		if (![resultArray containsObject:user]) {
			[resultArray addObject:user];
		}
	}
	return resultArray;
}

#pragma mark AddFriend
/*<message type="chat" from="niaojuuu@doctor.cn/Spark 2.6.3" to="111111@doctor.cn" nick=”niaojuuu”>
 <event kind="addfriendask">此处为发送的验证信息</event>
 </message>
 */
- (void)sendAddFriendAsk:(NSString *)text to:(NSString *)jidstr
{
	NSXMLElement *event = [NSXMLElement elementWithName:@"event" stringValue:text];
	[event addAttributeWithName:@"kind" stringValue:@"addfriendask"];
	
	XMPPMessage *message = [XMPPMessage message];
	[message addAttributeWithName:@"type" stringValue:@"chat"];
	[message addAttributeWithName:@"to" stringValue:jidstr];
	[message addAttributeWithName:@"nick" stringValue:[IMContext sharedContext].loginUser.nickname];
	[message addChild:event];
	
	[xmppStream sendElement:message];
}

/*<message type="chat" from="niaojuuu@doctor.cn/Spark 2.6.3" to="111111@doctor.cn" nick=”niaojuuu”>
 <event kind="addfriendconfirm"/>
 </message>
 */
- (void)confireFriendAskto:(NSString *)jidstr
{
	NSXMLElement *event = [NSXMLElement elementWithName:@"event"];
	[event addAttributeWithName:@"kind" stringValue:@"addfriendconfirm"];
	
	XMPPMessage *message = [XMPPMessage message];
	[message addAttributeWithName:@"type" stringValue:@"chat"];
	[message addAttributeWithName:@"to" stringValue:jidstr];
	[message addAttributeWithName:@"nick" stringValue:[IMContext sharedContext].loginUser.nickname];
	[message addChild:event];
	
	[xmppStream sendElement:message];
}

#pragma mark - Override Handle addFriend
- (void)xmppStream:(XMPPStream *)sender didReceiveChatMessageWithEvent:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	NSString *fromJidstr = [[message from] bare];
	//        if(![Public isQunJid:groupid])
	//            return;
	NSString *nickName = [message attributeStringValueForName:@"nick"];
	NSXMLElement *event = [message elementForName:@"event"];
	NSString *kind = [event attributeStringValueForName:@"kind"];
	NSString *msgBody = [message stringValue];
	
	IMUser *msgUser = [self.userMgr createCacheUserWithID:fromJidstr
												 usertype:[IMUser userTypeForUserJidStr:fromJidstr]
												 nikename:nickName];
	
	IMUser *fromUser = nil;
	
	NSString *sponsor = fromJidstr;
	NSString *sponsorName = nickName;
	IMUser *sponsorUser = msgUser;
	if ([IMUser userTypeForUserJidStr:fromJidstr] & IMUserTypeDiscuss) {
		NSString *spj = [event attributeStringValueForName:@"sponsor"];
		sponsor = [[XMPPJID jidWithString:spj] bare];
		sponsorName = [event attributeStringValueForName:@"name"];
		sponsorUser = [self.userMgr createCacheUserWithID:sponsor usertype:IMUserTypeP2P nikename:sponsorName];
		if ([sponsor isEqualToString:[IMContext sharedContext].loginUser.userID])
			sponsorName = @"你";
	}
	NSString *msgcontent = nil;
	
	if([kind isEqualToString:@"addfriendask"])//好友请求消息验证
	{
		fromUser = [IMUser friendCenterUser];
		IMMsg *recvMsg = [IMMsgFactory handleMsgWithFromUser:fromUser msgUser:msgUser msgid:[IMMsg generateMessageID]
													 msgTime:[NSDate date] isDelay:NO msgBody:msgBody attach:nil
													 msgType:IMMsgTypeFriendCenter msgSize:0 fromType:IMMsgFromOther
												   readState:IMMsgReadStateUnRead procState:IMMsgProcStateUnproc
												   playState:IMMsgPlayStateUnPlay];
		[self handleRecvMsg:recvMsg];
		return;
	}
	else if([kind isEqualToString:@"addfriendconfirm"])
	{
		[self.xbRoster addUserWithJidStr:fromJidstr nickname:nickName subscribeToPresence:NO];
		msgcontent = [NSString stringWithFormat:@"%@ 通过了你的好友验证，并添加你为好友", sponsorName];
	}
	else if ([kind isEqualToString:XBROSTER_CMD_CREATEGROUP]) {
		NSArray *qunItems = [event elementsForName:@"member"];
		msgcontent = [NSString stringWithFormat:@"%@ 邀请 %@ 加入群聊", sponsorName,
					  [self nameStringFromItems:qunItems sponsor:sponsor]];
	}
	else if ([kind isEqualToString:XBROSTER_CMD_DELETEGROUP]) {
		msgcontent = [NSString stringWithFormat:@"%@ 已解散了群聊", sponsorName];
	}
	else if ([kind isEqualToString:XBROSTER_CMD_QUITGROUP]) {
		msgcontent = [NSString stringWithFormat:@"%@ 退出了群聊", sponsorName];
	}
	else if ([kind isEqualToString:XBROSTER_CMD_ADDMEMBER]) {
		NSArray *qunItems = [event elementsForName:@"member"];
		msgcontent = [NSString stringWithFormat:@"%@ 邀请 %@ 加入群聊", sponsorName,
					  [self nameStringFromItems:qunItems sponsor:sponsor isNewMemeber:YES]];
	}
	else if ([kind isEqualToString:XBROSTER_CMD_REMOVEMEMBER]) {
		NSArray *qunItems = [event elementsForName:@"member"];
		msgcontent = [NSString stringWithFormat:@"%@ 将 %@ 移出群聊", sponsorName,
					  [self nameStringFromItems:qunItems sponsor:sponsor]];
	}
	else if ([kind isEqualToString:XBROSTER_CMD_KICKED]) {
		msgcontent = [NSString stringWithFormat:@"你已被 %@ 移出群，无法再进行群聊", sponsorName];
	}
	else if ([kind isEqualToString:XBROSTER_CMD_RENAME]) {
		msgcontent = [NSString stringWithFormat:@"%@ 修改了群名", sponsorName];
	}
	else if ([kind isEqualToString:@"addfriend"]) {
		msgcontent = [NSString stringWithFormat:@"%@ 添加你为好友", nickName];
		[self.xbRoster freshRosterFromServer];
	}
	else
		return;
	
	IMMsg *recvMsg = [IMMsgFactory handleMsgWithFromUser:msgUser msgUser:sponsorUser msgid:[IMMsg generateMessageID]
												 msgTime:[NSDate date] isDelay:NO msgBody:msgcontent attach:nil
												 msgType:IMMsgTypeNotice msgSize:0 fromType:IMMsgFromOther
											   readState:IMMsgReadStateUnRead procState:IMMsgProcStateUnproc
											   playState:IMMsgPlayStateUnPlay];
	[self handleRecvMsg:recvMsg];
}

- (NSString *)nameStringFromItems:(NSArray *)qunItems sponsor:(NSString *)sponsor
{
	return [self nameStringFromItems:qunItems sponsor:sponsor isNewMemeber:NO];
}

- (NSString *)nameStringFromItems:(NSArray *)qunItems sponsor:(NSString *)sponsor isNewMemeber:(BOOL)newflag
{
	//only include new member when newflag is true
	NSMutableArray *nameArray = [NSMutableArray array];
	for (NSXMLElement *item in qunItems) {
		NSString *itemjid = [item attributeStringValueForName:@"jid"];
		NSString *itemName = [item attributeStringValueForName:@"name"];
		
		BOOL isfliter = NO;
		if (newflag) {
			int new = [item attributeIntValueForName:@"new" withDefaultValue:0];
			if (new == 1)
				isfliter = NO;
			else
				isfliter = YES;
		}
		
		if (isfliter == NO && ![sponsor isEqualToString:itemjid]) {
			if([itemjid isEqualToString:[IMContext sharedContext].loginUser.userID])
				itemName = @"你";
			if(itemName == nil)
				itemName = itemjid;
			[nameArray addObject:itemName];
		}
	}
	return [nameArray componentsJoinedByString:@"、"];

}

- (BOOL)shoudSendMsg:(IMMsg *)msg
{
	if (msg.fromUser.userType & IMUserTypeDiscuss) {
		if (![[self xbRosterStorage] memberExsit:[IMContext sharedContext].loginUser.userID withDgid:msg.fromUser.userID]) {
			msg.procState = IMMsgProcStateFaied;
			[_msgStorage updateMsgState:msg];
			return NO;
		}
	}
	return [super shoudSendMsg:msg];
}
@end
