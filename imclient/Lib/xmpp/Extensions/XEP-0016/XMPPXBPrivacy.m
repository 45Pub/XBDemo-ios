//
//  XMPPXBPrivacy.m
//  IMClient
//
//  Created by pengjay on 13-7-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "XMPPXBPrivacy.h"
#import "XMPPLogging.h"
#import "XMPPPrivacy.h"
#import "NSNumber+XMPP.h"
#import "XMPP.h"

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#ifdef DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPXBPrivacy
- (id)init
{
	return [self initWithDispatchQueue:nil];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
	if((self = [super initWithDispatchQueue:queue]))
	{
		self.autoFetchBlackList = YES;
		_blackArray = [NSMutableArray array];
	}
	return self;
}

- (NSArray *)blackArray
{
	if (dispatch_get_specific(moduleQueueTag)) {
		return _blackArray;
	} else {
		__block NSMutableArray *result;
		dispatch_sync(moduleQueue, ^{
			result = [_blackArray copy];
		});
		return result;
	}
}

/*<iq from=”niaojuuu@doctor.cn/Spark 2.6.3” type=”get”>
 <query xmlns=”jabber:iq:privacy”>
 <list name=”default”/>
 </query>
 </iq>
 */
- (void)requestBackListAndAuth
{
	NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
	[list addAttributeWithName:@"name" stringValue:@"default"];
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
	[query addChild:list];
	NSString *uuid = [xmppStream generateUUID];
	XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:nil elementID:uuid child:query];
	[iq addAttributeWithName:@"from" stringValue:[[xmppStream myJID] bare]];
	[xmppStream sendElement:iq];
}

/*<iq from=”niaojuuu@doctor.cn/Spark 2.6.3” type=”set”>
 <query xmlns=”jabber:iq:privacy” type=”auth”>
 <list name=”default” type=”1”/>
 </query>
 </iq>
 */
- (void)setFriendAuthType:(FriendAuthType)type
{
	dispatch_block_t block = ^{
		NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
		[list addAttributeWithName:@"name" stringValue:@"default"];
		[list addAttributeWithName:@"type" stringValue:[NSString stringWithFormat:@"%d", type]];
		NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
		[query addAttributeWithName:@"type" stringValue:@"auth"];
		[query addChild:list];
		NSString *uuid = [xmppStream generateUUID];
		XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:uuid child:query];
		[iq addAttributeWithName:@"from" stringValue:[[xmppStream myJID] bare]];
		[xmppStream sendElement:iq];
	};
	
	if (dispatch_get_specific(moduleQueueTag)) 
		block();
	else
		dispatch_async(moduleQueue, block);
}
/*<iq from=”niaojuuu@doctor.cn/Spark 2.6.3” type=”set”>
 <query xmlns=”jabber:iq:privacy” type=”addblack”>
 <list name=”default”>
 <item type=”jid” value=”1111@doctor.cn” action=”deny”>
 <item type=”jid” value=”1112@doctor.cn” action=”deny”>
 </list>
 </query>
 </iq>
 */
- (void)addBlackList:(NSArray *)array
{
	dispatch_block_t block = ^{
		NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
		[list addAttributeWithName:@"name" stringValue:@"default"];
		for (NSString *jid in array)
		{
			NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
			[item addAttributeWithName:@"type" stringValue:@"jid"];
			[item addAttributeWithName:@"value" stringValue:jid];
			[item addAttributeWithName:@"action" stringValue:@"deny"];
			[list addChild:item];
		}
		
		NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
		[query addAttributeWithName:@"type" stringValue:@"addblack"];
		[query addChild:list];
		NSString *uuid = [xmppStream generateUUID];
		XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:uuid child:query];
		
		[xmppStream sendElement:iq];
	};
	
	if (dispatch_get_specific(moduleQueueTag)) 
		block();
	else
		dispatch_async(moduleQueue, block);
}

/*<iq from=”niaojuuu@doctor.cn/Spark 2.6.3” type=”set”>
 <query xmlns=”jabber:iq:privacy” type=”delblack”>
 <list name=”default”>
 <item type=”jid” value=”1111@doctor.cn” action=”deny”>
 <item type=”jid” value=”1112@doctor.cn” action=”deny”>
 </list>
 </query>
 </iq>
 */
- (void)removeBlackList:(NSArray *)array
{
	dispatch_block_t block = ^{
		NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
		[list addAttributeWithName:@"name" stringValue:@"default"];
		for (NSString *jid in array)
		{
			NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
			[item addAttributeWithName:@"type" stringValue:@"jid"];
			[item addAttributeWithName:@"value" stringValue:jid];
			[item addAttributeWithName:@"action" stringValue:@"deny"];
			[list addChild:item];
		}
		
		NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
		[query addAttributeWithName:@"type" stringValue:@"delblack"];
		[query addChild:list];
		NSString *uuid = [xmppStream generateUUID];
		XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:uuid child:query];
		
		[xmppStream sendElement:iq];
	};
	
	if (dispatch_get_specific(moduleQueueTag)) 
		block();
	else
		dispatch_async(moduleQueue, block);
}



- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	if(self.autoFetchBlackList)
	{
		[self requestBackListAndAuth];
	}
}
/*
 <iq xmlns="jabber:client" type="result" id="9304DAEC-E344-451B-BE30-56DD2C9D75CF" to="16678cefd3c1f0a47c8d1fda04aacba51e47e75e@doctor.cn/ios"><query xmlns="jabber:iq:privacy"><list xmlns="" name="default" type="0"><item action="allow" order="999999"/></list></query></iq>
 
 <iq to=”niaojuuu@doctor.cn/Spark 2.6.3” type=”result”>
 <query xmlns=”jabber:iq:privacy”>
 <list name=”default” type=“0“>
 <item type=”jid” value=”aaa@doctor.cn” action=”deny” order=”1” />
 <item type=”jid” value=”bbb@doctor.cn” action=”deny” order=”2” />
 <item action=”allow” order=”99999” />
 </list>
 </query>
 </iq>
 */

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSString *type = [iq type];
	
	if([type isEqualToString:@"result"])
	{
		NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:privacy"];
		if (query) {
			NSString *queryType = [query attributeStringValueForName:@"type"];
			NSXMLElement *list = [query elementForName:@"list"];
			
			if(queryType == nil) {
				int listType = [list attributeIntValueForName:@"type"];
				_mAuthType = listType;
				
				NSArray *items = [list elementsForName:@"item"];
				[_blackArray removeAllObjects];
				for(NSXMLElement *item in items) {
					NSString *action = [item attributeStringValueForName:@"action"];
					if([action isEqualToString:@"deny"]) {
						NSString *jid = [item attributeStringValueForName:@"value"];
						if(jid != nil)
							[_blackArray addObject:jid];
					}
					
				}
				[multicastDelegate xmppXBPrivacy:self didReceiveBlackList:_blackArray authType:_mAuthType];
				
			} else if([queryType isEqualToString:@"auth"]) {
				int listType = [list attributeIntValueForName:@"type"];
				_mAuthType = listType;
				[multicastDelegate xmppXBPrivacy:self didReceiveBlackList:_blackArray authType:_mAuthType];
				
			} else if([queryType isEqualToString:@"addblack"] || [queryType isEqualToString:@"delblack"]) {
				[self requestBackListAndAuth];
			}
			
			return YES;
		}
		
	}
	return NO;
}

@end
