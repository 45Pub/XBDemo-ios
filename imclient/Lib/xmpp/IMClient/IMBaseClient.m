//
//  IMBaseClient.m
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import "IMBaseClient.h"
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
#import "IMMsgObserveHandler.h"
#import "IMNewMsgNotifyManager.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface IMBaseClient() 

@end

@implementation IMBaseClient
@synthesize xmppvCardTempModule = xmppvCardTempModule;
@synthesize xmppRoster = xmppRoster;
@synthesize msgCacheMgr = _msgCacheMgr;
@synthesize sessionMgr = _sessionMgr;
@synthesize xmppRosterStorage = xmppRosterStorage;
@synthesize userMgr = _userMgr;
@synthesize msgStorage = _msgStorage;
- (id)initWithUserID:(NSString *)userID passwd:(NSString *)passwd host:(NSString *)host port:(NSUInteger)port
{
	self = [super init];
	if (self) {
		
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		
		NSAssert(userID != nil, @"userid cann't be nil");
		
		_myUserID = userID;
		_myPasswd = passwd;
		
		_host = DEFAULT_HOST;
		if (host.length > 0) {
			_host = host;
		}
		
		_port = DEFAULT_PORT;
		if (port > 0) {
			_port = port;
		}
		
		_msgHandlerCache = [[NSCache alloc]init];
		_delegates = (GCDMulticastDelegate<IMClientDelegate> *)[[GCDMulticastDelegate alloc]init];
		_clientState = IMClientStateDisconnected;
		
		_userMgr = [[IMUserManager alloc]initWithClient:self];
		
		_dbQueue = [[FMDatabaseQueue alloc]initWithPath:[IMPathHelper userStoragePath:_myUserID]];
	
		_msgCacheMgr = [[IMMsgCacheManager alloc]init];
		_msgStorage = [[IMMsgStorage alloc]initWithdbQueue:_dbQueue userManager:_userMgr msgManager:_msgCacheMgr];
		
		_msgQueueMgr = [[IMMsgQueueManager alloc]initWithMsgStorage:_msgStorage];
		
		_sessionMgr = [[IMChatSessionManager alloc]initWithMsgStorage:_msgStorage dispatchQueue:NULL msgQueueMgr:_msgQueueMgr];
		
		_msgNotifyMgr = [[IMNewMsgNotifyManager alloc]initWithMsgQueueMgr:_msgQueueMgr];
		
		IMContext *context = [[IMContext alloc]initWithLoginUserID:[_userMgr createCacheUserWithID:_myUserID
																						  usertype:IMUserTypeP2P]
														msgStorage:_msgStorage msgQueueMgr:_msgQueueMgr];
		
		[IMContext initInstance:context];
		[self setupStream];
	}
	
	return self;
}


- (void)dealloc
{
	[IMContext destroyInstance];
	DDLogInfo(@"BaseClient Dealloc");
	[self teardownStream];
}

#pragma prtocted

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
	xmppRosterStorage = [[XMPPRosterSqlStorage alloc]initWithdbQueue:_dbQueue];
	xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:xmppRosterStorage];
	
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [[XMPPvCardSqlStorage alloc]init];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	[xmppReconnect	activate:xmppStream];
	[xmppvCardTempModule activate:xmppStream];
	[xmppRoster activate:xmppStream];
	
	
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
	
	[self disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
	xmppvCardTempModule = nil;
	xmppvCardStorage = nil;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"]; // type="available" is implicit
	if(self.devToken != nil) {
        [presence addAttributeWithName:@"token" stringValue:self.devToken];
    }

	[xmppStream sendElement:presence];
    
    _isOnline = YES;
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[xmppStream sendElement:presence];
    
    _isOnline = NO;
    self.devToken = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
	if (![xmppStream isDisconnected]) {
		return YES;
	}
	
		
	if (_myUserID == nil || _myPasswd == nil) {
		DDLogError(@"%@: userId or passwd is nil", THIS_METHOD);
		return NO;
	}
	
	[xmppStream setMyJID:[XMPPJID jidWithString:_myUserID]];
	
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
		
		DDLogError(@"Error connecting: %@", error);
		
		return NO;
	}
	
	_clientState = IMClientStateConnecting;
	[self.delegates imClient:self stateChanged:_clientState];
	
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}


- (BOOL)connectAndSignup
{
	shouldSignup = YES;
	return [self connect];
}

- (void)sendToken:(NSString*)deviceToken {
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    [presence addAttributeWithName:@"token" stringValue:deviceToken];
    [xmppStream sendElement:presence];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	
	NSError *error = nil;
	
	if (![xmppStream authenticateWithPassword:_myPasswd error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	_clientState = IMClientStateConnected;
	[self.delegates imClient:self stateChanged:_clientState];
	[self.delegates imClient:self didLogin:YES withError:nil];
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	_clientState = IMClientStateDisconnected;
	[self.delegates imClient:self stateChanged:_clientState];
	
	if (shouldSignup) {
		NSError *er = nil;
		if (![xmppStream registerWithPassword:_myPasswd error:&er]) {
			DDLogVerbose(@"register error1:%@", er);
		}
			
	}
	[self.delegates imClient:self didLogin:NO withError:nil];
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	shouldSignup = NO;
	[self.delegates imClient:self didSignup:YES withError:nil];
	if ([xmppStream authenticateWithPassword:_myPasswd error:nil]) {
		DDLogVerbose(@"auth error");
	}
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	shouldSignup = NO;
    NSInteger errorCode = [[error elementForName:@"error"] attributeIntegerValueForName:@"code"];
    NSError *err = [NSError errorWithDomain:@"RegisterError" code:errorCode userInfo:nil];
	[self.delegates imClient:self didSignup:NO withError:err];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
	DDLogVerbose(@"%@: %@:%@", THIS_FILE, THIS_METHOD, message);
	if ([message isChatMessageWithBody])
	{
        [self xmppStream:sender didReceiveChatMessageWithBody:message];
	}
//    else if ([message isGroupInviteMessage])
//    {
//		
//		
//        //todo accept or not ?
//        
//		//        if (xmppCurRoom)
//		//        {
//		//            [xmppCurRoom deactivate];
//		//            [xmppCurRoom release];
//		//        }
//		//
//		//        NSString* roomName = [[[message elementForName:@"x" xmlns:@"jabber:x:conference"] attributeForName:@"jid"] stringValue];
//		//        xmppCurRoom = [[XMPPRoom alloc] initWithRoomName:roomName nickName:[[xmppStream myJID] user]];
//		//        [xmppCurRoom activate:xmppStream];
//		//        [xmppCurRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
//		//        [xmppCurRoom acceptInvitation];
//    }
    else if ([message isMessageWithBody])
    {
		[self xmppStream:sender didReceiveSysMessageWithBody:message];
	}
    else if([message isChatMessageWithEvent])//群事件消息
    {
		[self xmppStream:sender didReceiveChatMessageWithEvent:message];
    }
	else
	{
		DDLogVerbose(@"Not Handler msg!");
	}

	
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	NSXMLElement *conflict = [error elementForName:@"conflict" xmlns:@"urn:ietf:params:xml:ns:xmpp-streams"];
    if (conflict != nil) {
		[self.delegates imClient:self conflictWithError:nil];
		[self teardownStream];
	}
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	_clientState = IMClientStateDisconnected;
	[self.delegates imClient:self stateChanged:_clientState];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MessageHandler
//私聊消息处理
- (void)xmppStream:(XMPPStream *)sender didReceiveChatMessageWithBody:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	NSDate *msgDate = [NSDate date];
	if([message wasDelayed])
	{
		msgDate = [message delayedDeliveryDate];
		
	}

	NSString *userJID = nil;
	
	//这里要区分是在房间里的单独对话消息还是真正的私聊消息
	XMPPJID* msgFrom = [message from];
//	NSString* fromDomain = [msgFrom domain];
	NSString* nickName = [message attributeStringValueForName:@"nick"];
	NSString *msgID = [message elementID];
	if(msgID == nil || [msgID length] <= 0)
		msgID = [IMMsg generateMessageID];
	
	userJID = [msgFrom bare];

	IMUser *fromUser = [self.userMgr createCacheUserWithID:userJID usertype:IMUserTypeP2P nikename:nickName];
	IMUser *msgUser = [self.userMgr createCacheUserWithID:userJID usertype:IMUserTypeP2P nikename:nickName];
	
	///Discuss Group Message Process
	if ([XMPPUserObject xmppUserTypeWithJidStr:userJID] == XMPPUserTypeDiscussGroup) {
		NSXMLElement *body = [message elementForName:@"body"];
		NSString *dismsgUserJID = [body attributeStringValueForName:@"sponsor"];
		NSString *dissmgUserName = [body attributeStringValueForName:@"name"];
		msgUser = [self.userMgr createCacheUserWithID:dismsgUserJID usertype:IMUserTypeP2P nikename:dissmgUserName];
		
		fromUser = [self.userMgr createCacheUserWithID:userJID usertype:IMUserTypeDiscuss nikename:nickName];
	}
	///
	
	assert(msgUser.userID);
	
	
//	NSXMLElement *body = [message elementForName:@"body"];
//	NSString *chatMsg = [body stringValue];
//	NSString *chatType = [body attributeStringValueForName:@"type" withDefaultValue:XMPPMessageTypeNormal];
//	int nSize = [body attributeIntValueForName:@"size" withDefaultValue:0];
//	
//	NSMutableDictionary *attach = nil;
//	if ([chatType isEqualToString:XMPPMessageTypePicFileLink] || [chatType isEqualToString:XMPPMessageTypeVideoLink]) {
//		attach = [NSMutableDictionary dictionary];
//		NSString *thumbURL = [body attributeStringValueForName:@"thumb"];
//		if (thumbURL) {
//			[attach setObject:thumbURL forKey:@"thumburl"];
//		}
//	}
//	
//	IMMsg *recvMsg = [IMMsgFactory handleMsgWithFromUser:fromUser msgUser:msgUser msgid:msgID msgTime:msgDate
//												 isDelay:[message wasDelayed] msgBody:chatMsg attach:attach
//												 msgType:[XMPPMessage getImMsgType:chatType] msgSize:nSize
//												fromType:IMMsgFromOther readState:IMMsgReadStateUnRead
//											   procState:IMMsgProcStateUnproc playState:IMMsgPlayStateUnPlay];
    
    NSXMLElement *body = [message elementForName:@"body"];
	NSString *chatMsg = [body stringValue];
	NSString *chatType = [body attributeStringValueForName:@"type" withDefaultValue:XMPPMessageTypeNormal];
    
	NSMutableDictionary *attach = nil;
//    NSString *disPlayName = [body attributeStringValueForName:@"displayname" withDefaultValue:@""];
//    [attach setObject:disPlayName forKey:@"disPlayName"];
    int nSize;
    NSString *bodyStr = nil;
	if ([chatType isEqualToString:XMPPMessageTypeVideoLink]) {
		NSString *thumbURL = [body attributeStringValueForName:@"thumb"];
		if (thumbURL) {
            attach = [NSMutableDictionary dictionary];
			[attach setObject:thumbURL forKey:@"thumburl"];
		}
        nSize = [body attributeIntValueForName:@"size" withDefaultValue:0];
        bodyStr = chatMsg;
	} else if ([chatType isEqualToString:XMPPMessageTypePicFileLink]) {
        NSXMLElement *detail = [message elementForName:@"detail"];
        nSize = [detail attributeIntValueForName:@"size" withDefaultValue:0];
        bodyStr = [detail stringValue];
        attach = [NSMutableDictionary dictionary];
        [attach setObject:chatMsg forKey:@"thumburl"];
    } else {
        nSize = [body attributeIntValueForName:@"size" withDefaultValue:0];
        bodyStr = chatMsg;
    }
	
	IMMsg *recvMsg = [IMMsgFactory handleMsgWithFromUser:fromUser msgUser:msgUser msgid:msgID msgTime:msgDate
												 isDelay:[message wasDelayed] msgBody:bodyStr attach:attach
												 msgType:[XMPPMessage getImMsgType:chatType] msgSize:nSize
												fromType:IMMsgFromOther readState:IMMsgReadStateUnRead
											   procState:IMMsgProcStateUnproc playState:IMMsgPlayStateUnPlay];
	

	
	if (recvMsg) {
		[self handleRecvMsg:recvMsg];
	}
}

//系统消息处理
- (void)xmppStream:(XMPPStream *)sender didReceiveSysMessageWithBody:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	//查看是否为管理员消息
	//	NSString* from = [[message from] full];
	//	if ([from isEqualToString:XMPP_SVR_DOMAIN]) {
	//		//是管理员的广播消息
	//		NSXMLElement *body = [message elementForName:@"body"];
	//		NSString *chatMsg = [body stringValue];
	//		//            NSString *chatType = [body attributeStringValueForName:@"type" withDefaultValue:XMPPMessageTypeNormal];
	//		int nSize = [body attributeIntValueForName:@"size" withDefaultValue:0];
	//
	//		ChatMsg *cmsg = [[[ChatMsg alloc]init] autorelease];
	//
	//		NSDate *senddate = [NSDate date];
	//		if([message wasDelayed])
	//		{
	//			senddate = [message delayedDeliveryDate];
	//			cmsg.isDelay = YES;
	//			cmsg.groupTime = [senddate timeIntervalSince1970];
	//
	//			CUSTOMIZELOG(@"%@", senddate);
	//		}
	//		cmsg.remoteTime = [senddate timeIntervalSince1970];
	//
	//		cmsg.roomID = ADMIN_JID;
	//		cmsg.roomName = ADMIN_NAME;
	//		cmsg.userID = ADMIN_JID;
	//		cmsg.userName = ADMIN_NAME;
	//		cmsg.msgID = [Public generateMessageID:cmsg.userName];
	//		cmsg.msgSize = nSize;
	//
	//		cmsg.message = chatMsg;
	//		cmsg.msgType = MESSAGETYPETEXT;
	//		cmsg.msgStat = MSGSTATPLAYED;
	//		cmsg.fromFlag = 1;
	//
	//		dispatch_async(dispatch_get_main_queue(), ^{
	//			[[MsgProc sharedMsgProc] recvPrivateMsg:cmsg];
	//		});
	//	}
	
}

//群聊事件处理
- (void)xmppStream:(XMPPStream *)sender didReceiveChatMessageWithEvent:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
//	NSString *fromJidstr = [[message from] bare];
//	//        if(![Public isQunJid:groupid])
//	//            return;
//	NSString *nickName = [message attributeStringValueForName:@"nick"];
//	NSXMLElement *event = [message elementForName:@"event"];
//	NSString *kind = [event attributeStringValueForName:@"kind"];
//	NSString *msgBody = [message stringValue];
//	
//	IMUser *msgUser = [[IMUser alloc]init] ;
//	msgUser.userID = fromJidstr;
//	msgUser.nickname = nickName;
//
//	IMUser *fromUser = [[IMUser alloc]init] ;
	
}
#pragma mark - HandelMsg
- (void)handleRecvMsg:(IMMsg *)msg
{
	[_msgStorage saveMsg:msg];
	[_msgQueueMgr deliverMsg:msg];
	[_sessionMgr deliverMsg:msg];
	[_msgNotifyMgr deliverMsg:msg];
	
	if (msg.fromType != IMMsgFromLocalSelf) {
		[self.delegates imClient:self didRecvMsg:msg];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Roster
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@", presence);
	[xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
}

- (void)xmppRosterDidChange:(XMPPRosterSqlStorage *)sender
{
	DDLogVerbose(@"roster changed");
}

- (void)xmppRosterDidPopulate:(XMPPRosterSqlStorage *)sender
{
	DDLogVerbose(@"roster populate");
}


- (void)xmppRoster:(XMPPRosterSqlStorage *)sender didAddUser:(NSString *)userJid
{
	DDLogVerbose(@"roster add :%@", userJid);
}

- (void)xmppRoster:(XMPPRosterSqlStorage *)sender didUpdateUser:(NSString *)userJid
{
	DDLogVerbose(@"roster update :%@", userJid);
}

- (void)xmppRoster:(XMPPRosterSqlStorage *)sender didRemoveUser:(NSString *)userJid
{
	DDLogVerbose(@"roster remove :%@", userJid);
}


- (void)xmppRoster:(XMPPRosterSqlStorage *)sender
    didAddResource:(XMPPResourceObject *)resource
          withUser:(NSString *)userJid
{
	DDLogVerbose(@"roster online:%@", userJid);
}

- (void)xmppRoster:(XMPPRosterSqlStorage *)sender
 didUpdateResource:(XMPPResourceObject *)resource
          withUser:(NSString *)userJid
{
	DDLogVerbose(@"roster updateline:%@", userJid);
}

- (void)xmppRoster:(XMPPRosterSqlStorage *)sender
 didRemoveResource:(XMPPResourceObject *)resource
		  withUser:(NSString *)userJid
{
	DDLogVerbose(@"roster offline:%@", userJid);
}

#pragma mark - vCardTempDelegate
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid
{
	
	DDLogVerbose(@"%@: %@: %@", THIS_FILE, THIS_METHOD, [jid bare]);
	
	vCardTemp.jid = jid;
	[self.userMgr updateCacheUserWithvCard:vCardTemp];
	[self.xmppRoster setNickname:[vCardTemp nickname] ifExsitUserJidstr:[jid bare]];
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{

	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{

	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SendMsg
- (BOOL)sendXmppChatMsg:(IMMsg *)msg
{
	if (_clientState == IMClientStateDisconnected) {
		if ([xmppStream isDisconnected])
			[self connect];
		return NO;
	}
	DDLogVerbose(@"sendMsg:sendXMPP:%@", msg.msgID);
	XMPPMessage *xmppMsg = [XMPPMessage message];
	[xmppMsg addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [xmppMsg addAttributeWithName:@"id" stringValue:msg.msgID];
    [xmppMsg addAttributeWithName:@"to" stringValue:msg.fromUser.userID];
    [xmppMsg addAttributeWithName:@"from" stringValue:[[xmppStream myJID] full]];
    [xmppMsg addAttributeWithName:@"type" stringValue:@"chat"];
    [xmppMsg addAttributeWithName:@"nick" stringValue:msg.msgUser.nickname];
    
    	
//	NSXMLElement *sendMsgBody = [NSXMLElement elementWithName:@"body" stringValue:msg.msgBody];
//	
//	if (msg.msgType != IMMsgTypeText) {
//		[sendMsgBody addAttributeWithName:@"type" stringValue:[XMPPMessage getXMPPMsgTypeStr:msg.msgType]];
//	}
//
//	if (msg.msgSize > 0) {
//		[sendMsgBody addAttributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%llu", msg.msgSize]];
//	}
//	
//	
//	if (msg.msgType == IMMsgTypePic || msg.msgType == IMMsgTypeVideo) {
//		IMPicMsg *picMsg = (IMPicMsg *)msg;
////		if ([picMsg originFileRemoteUrl]) {
////			NSXMLElement *detailBody = [NSXMLElement elementWithName:@"detail" stringValue:[picMsg originFileRemoteUrl]];
////			NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[picMsg originFileLocalPath]
////																						error:nil];
////			UInt64 totalSize = [attributes[NSFileSize] longLongValue];
////			[detailBody addAttributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%llu", totalSize]];
////			[xmppMsg addChild:detailBody];
////		}
//		[sendMsgBody addAttributeWithName:@"thumb" stringValue:picMsg.fileRemoteUrl];
//		
//	}
    
    NSXMLElement *sendMsgBody;
    
    if (msg.msgType == IMMsgTypePic) {
        sendMsgBody = [NSXMLElement elementWithName:@"body" stringValue:msg.msgAttach[@"thumburl"]];
        IMPicMsg *picMsg = (IMPicMsg*)msg;
//        [sendMsgBody addAttributeWithName:@"displayname" stringValue:[picMsg.msgAttach objectForKey:@"disPlayName"]];
        [sendMsgBody addAttributeWithName:@"type" stringValue:[XMPPMessage getXMPPMsgTypeStr:msg.msgType]];
        NSXMLElement *detail = [NSXMLElement elementWithName:@"detail" stringValue:picMsg.msgBody];
        [detail addAttributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%llu", msg.msgSize]];
        [xmppMsg addChild:detail];
    } else {
        sendMsgBody = [NSXMLElement elementWithName:@"body" stringValue:msg.msgBody];
        if (msg.msgType != IMMsgTypeText) {
            [sendMsgBody addAttributeWithName:@"type" stringValue:[XMPPMessage getXMPPMsgTypeStr:msg.msgType]];
            
            if (msg.msgType == IMMsgTypeVideo) {
                IMVideoMsg *picMsg = (IMVideoMsg *)msg;
                [sendMsgBody addAttributeWithName:@"thumb" stringValue:picMsg.fileRemoteUrl];
//                [sendMsgBody addAttributeWithName:@"displayname" stringValue:[picMsg.msgAttach objectForKey:@"disPlayName"]];
            } else if (msg.msgType == IMMsgTypeFile) {
//                [sendMsgBody addAttributeWithName:@"displayname" stringValue:[msg.msgAttach objectForKey:@"disPlayName"]];
            }
        }
        
        if (msg.msgSize > 0) {
            [sendMsgBody addAttributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%llu", msg.msgSize]];
        }
        
    }

	
	[xmppMsg addChild:sendMsgBody];
	
	//update state
	msg.procState = IMMsgProcStateSuc;
	[_msgStorage updateMsgState:msg];
	
	[xmppStream sendElement:xmppMsg];
	return YES;
}

- (void)clearMsgInCache:(IMMsg *)msg
{
	[_msgCacheMgr removeProcessMsg:msg];
	[_msgHandlerCache removeObjectForKey:msg.msgID];
}

- (void)reSendMsg:(IMMsg *)msg
{
	[self sendMsg:msg shouldSave:NO];
}

- (void)sendMsg:(IMMsg *)msg
{
	[self sendMsg:msg shouldSave:YES];
}

- (BOOL)shoudSendMsg:(IMMsg *)msg
{
	if (_clientState != IMClientStateConnected) {
		msg.procState = IMMsgProcStateFaied;
		[_msgStorage updateMsgState:msg];
		return NO;
	}
	return YES;
}

- (void)sendMsg:(IMMsg *)msg shouldSave:(BOOL)shouldSave
{
	if (msg == nil)
		return;
	DDLogVerbose(@"WillSendMsg:%@:%@", msg.msgID, msg.fromUser);
	
	if (shouldSave)
		[self handleRecvMsg:msg];
	
	if (![self shoudSendMsg:msg]) {
		return;
	}
//
	if (msg.msgType == IMMsgTypeText)
	{
		[self sendXmppChatMsg:msg];
	}
	else if (msg.msgType == IMMsgTypeAudio || msg.msgType == IMMsgTypeFile || msg.msgType == IMMsgTypePic
			 || msg.msgType == IMMsgTypeVideo) {
		
		__weak typeof(self) wself = self;
		IMMsgObserveHandler *proHandler = [[IMMsgObserveHandler alloc]initWithMsg:msg keyPath:@"procState"
																  compeletedBolck:^(IMMsgObserveHandler *handler, IMMsg *msg1, NSNumber *nValue, NSNumber *oValue) {
																	  static int i = 0;
																	  NSLog(@"fuck:%d", i++);
																	  typeof(self) sself = wself;
																	  if ([nValue integerValue] == IMMsgProcStateSuc &&
																		  [oValue integerValue] == IMMsgProcStateProcessing) {
																		  DDLogVerbose(@"SendMsg:upload end:%@:%@", msg.msgID, nValue);
																		  [sself sendXmppChatMsg:msg1];
																	  }
																	  
																	  if (([nValue integerValue] == IMMsgProcStateSuc||
																		   [nValue integerValue] == IMMsgProcStateFaied) &&
																		  [oValue integerValue] == IMMsgProcStateProcessing) {
																		  DDLogVerbose(@"sendmsg:remove cache:%@", nValue);
																		  [sself clearMsgInCache:msg1];
																	  }
		}];
		
		[_msgHandlerCache setObject:proHandler forKey:msg.msgID];
		[_msgCacheMgr addProcessMsg:msg];
		[proHandler addObserver];
		IMFileMsg *fileMsg = (IMFileMsg *)msg;
		[fileMsg uploadFile];
		
	}
}

- (void)sendLocalSysNoteMsg:(IMMsg *)msg
{
	if (msg == nil || msg.msgType != IMMsgTypeNotice)
		return;
	
	[self handleRecvMsg:msg];
}

#pragma mark - Users
- (NSArray *)allFirstLetterAndUserInRoster
{
	NSArray *xUserArray = [xmppRosterStorage allUsers];
	NSMutableArray *letterArray = [NSMutableArray array];
	NSMutableDictionary *userArrayForLetter = [NSMutableDictionary dictionary];
	for (XMPPUserObject *xuser in xUserArray) {
		IMUserType type = 0;
		if (xuser.usertype == XMPPUserTypeUser) {
			type |= IMUserTypeP2P;
//			[self.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:xuser.jidStr] ignoreStorage:YES];
		}
		else
			type |= IMUserTypeDiscuss;
		
		if (xuser.isAdmin)
			type |= IMUserTypeAdmin;
		
		IMUser *user = [_userMgr createCacheUserWithID:xuser.jidStr usertype:type nikename:xuser.nickname];
		NSString *letter = [NSString stringWithFormat:@"%c", xuser.firstLetter];
		if (![letterArray containsObject:letter])
			[letterArray addObject:letter];
		
		NSMutableArray *imusers = [userArrayForLetter objectForKey:letter];
		if (imusers == nil) {
			imusers = [NSMutableArray array];
			[userArrayForLetter setObject:imusers forKey:letter];
		}
		
		[imusers addObject:user];
		
	}
	
	NSArray *resultArray = [NSArray arrayWithObjects:letterArray, userArrayForLetter, nil];
	return resultArray;
}

- (NSArray *)searchFriendsWithKey:(NSString *)key
{
	NSArray *xUserArray = [xmppRosterStorage searchUsersWithKey:key];
	
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
@end
