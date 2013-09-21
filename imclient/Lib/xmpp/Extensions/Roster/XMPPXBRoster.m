//
//  XMPPXBRoster.m
//  IMClient
//
//  Created by pengjay on 13-7-16.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "XMPPXBRoster.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"
#import "DDList.h"
#import "XMPPIDTracker.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif


@implementation XMPPXBRoster

- (BOOL)isRosterItem:(NSXMLElement *)item
{
	return YES;
}



#pragma mark -
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if ([message isChatMessageWithEvent]) {
        NSString *groupid = [message attributeStringValueForName:@"from"];
		NSString *groupName = [message attributeStringValueForName:@"nick"];
		
		if ([XMPPUserObject xmppUserTypeWithJidStr:groupid] == XMPPUserTypeDiscussGroup) {
			NSXMLElement *event = [message elementForName:@"event"];
			if ([xmppRosterStorage  conformsToProtocol:@protocol(XMPPXBRosterProtocol)]) {
				id<XMPPXBRosterProtocol> storage = (id<XMPPXBRosterProtocol>)xmppRosterStorage;
				[storage handleEventMessageWithDgid:groupid dgName:groupName event:event xmppStream:sender];
			}
		}
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	// This method is invoked on the moduleQueue.
	
	XMPPLogTrace();
	
	// Note: Some jabber servers send an iq element with an xmlns.
	// Because of the bug in Apple's NSXML (documented in our elementForName method),
	// it is important we specify the xmlns for the query.
	
	NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:roster"];
	if (query)
	{
		NSString *type = [query attributeStringValueForName:@"type"];
		if (type == nil || type.length <= 0) {
			return [super xmppStream:sender didReceiveIQ:iq];
		}
		NSString *groupid = [query attributeStringValueForName:@"groupid"];
		if ([type isEqualToString:XBROSTER_CMD_QUITGROUP] || [type isEqualToString:XBROSTER_CMD_DELETEGROUP]) {
			[((id<XMPPXBRosterProtocol>)xmppRosterStorage) removeUserObjectWithBareJidStr:groupid];
			[((id<XMPPXBRosterProtocol>)xmppRosterStorage) removeDiscussAllMemeberWithId:groupid];
			[multicastDelegate xmppRosterDidChange:xmppRosterStorage];
		}
		[_rosterTracker invokeForID:[iq elementID] withObject:iq];
		
	}
	
	return NO;
}


#pragma mark - Method
- (NSString *)createDiscussGroup:(NSString *)dgName withMembers:(NSArray *)memberDics
{
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addAttributeWithName:@"type" stringValue:@"creategroup"];
    [query addAttributeWithName:@"groupname" stringValue:dgName];
	
    for(NSDictionary *user in memberDics) {
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
		NSString *jidstr = [user objectForKey:@"jid"];
		NSString *name = [user objectForKey:@"name"];
		if (jidstr)
			[item addAttributeWithName:@"jid" stringValue:jidstr];
		if (name.length > 0)
            [item addAttributeWithName:@"name" stringValue:name];
        [query addChild:item];
    }
    NSString *elemId = [xmppStream generateUUID];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:elemId];
    [iq addChild:query];
    [xmppStream sendElement:iq];
	[self addTrackerID:elemId timeout:ROSTER_TIMEOUT];
    return elemId;
}

- (NSString *)deleteDiscussGroup:(NSString *)dgid
{
	if (dgid == nil)
		return nil;
	
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addAttributeWithName:@"type" stringValue:@"removegroup"];
    [query addAttributeWithName:@"groupid" stringValue:dgid];
	NSString *elemId = [xmppStream generateUUID];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:elemId];
    [iq addChild:query];
    [xmppStream sendElement:iq];
	[self addTrackerID:elemId timeout:ROSTER_TIMEOUT];
    return elemId;

}

- (NSString *)qiutDiscussGroup:(NSString *)dgid
{
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addAttributeWithName:@"type" stringValue:@"quitgroup"];
    [query addAttributeWithName:@"groupid" stringValue:dgid];
	NSString *elemId = [xmppStream generateUUID];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:elemId];
    [iq addChild:query];
    [xmppStream sendElement:iq];
	[self addTrackerID:elemId timeout:ROSTER_TIMEOUT];
    return elemId;
}

- (NSString *)changeDiscussGroup:(NSString *)dgid withNewName:(NSString *)dgName
{
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addAttributeWithName:@"type" stringValue:@"changename"];
    [query addAttributeWithName:@"groupid" stringValue:dgid];
    [query addAttributeWithName:@"name" stringValue:dgName];
    
    NSString *elemId = [xmppStream generateUUID];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:elemId];
    [iq addChild:query];
    [xmppStream sendElement:iq];
    return elemId;
}

- (NSString *)addDiscussGroup:(NSString *)dgid withMembers:(NSArray *)memberDics
{
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addAttributeWithName:@"type" stringValue:@"addmember"];
    [query addAttributeWithName:@"groupid" stringValue:dgid];
	
	for(NSDictionary *user in memberDics) {
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
		NSString *jidstr = [user objectForKey:@"jid"];
		NSString *name = [user objectForKey:@"name"];
		if (jidstr)
			[item addAttributeWithName:@"jid" stringValue:jidstr];
		if (name.length > 0)
            [item addAttributeWithName:@"name" stringValue:name];
        [query addChild:item];
    }
    NSString *elemId = [xmppStream generateUUID];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:elemId];
    [iq addChild:query];
    [xmppStream sendElement:iq];
	[self addTrackerID:elemId timeout:ROSTER_TIMEOUT];
    return elemId;
}

- (NSString *)removeDiscussGroup:(NSString *)dgid withMembers:(NSArray *)memberDics
{
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addAttributeWithName:@"type" stringValue:@"removemember"];

	[query addAttributeWithName:@"groupid" stringValue:dgid];
	
	for(NSDictionary *user in memberDics) {
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
		NSString *jidstr = [user objectForKey:@"jid"];
		NSString *name = [user objectForKey:@"name"];
		if (jidstr)
			[item addAttributeWithName:@"jid" stringValue:jidstr];
		if (name.length > 0)
            [item addAttributeWithName:@"name" stringValue:name];
        [query addChild:item];
    }
    NSString *elemId = [xmppStream generateUUID];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:elemId];
    [iq addChild:query];
    [xmppStream sendElement:iq];
    return elemId;
}

@end
