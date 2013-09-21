// XMPPUserObject.m
// 
// Copyright (c) 2013年 pengjay.cn@gmail.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//   http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "XMPPUserObject.h"
#import "XMPP.h"
#import "NSNumber+XMPP.h"
#import "XMPPGroupObject.h"
#import "XMPPResourceObject.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@implementation XMPPUserObject

+ (XMPPUserObject *)userWithItem:(NSXMLElement *)item
{
	XMPPUserObject *user = [[[self class] alloc] init];
	[user updateWithItem:item];
	return user;
}

+ (XMPPUserType)xmppUserTypeWithJidStr:(NSString *)jidStr
{
	NSArray *array = [jidStr componentsSeparatedByString:@"@"];
	if (array.count >= 2) {
		NSString *flagStr = [array objectAtIndex:1];
		if ([flagStr hasPrefix:@"broadcast"]) {
			return XMPPUserTypeDiscussGroup;
		}
	}
	return XMPPUserTypeUser;
}

- (void)updateWithItem:(NSXMLElement *)item
{
	NSString *jidStr = [item attributeStringValueForName:@"jid"];
	XMPPJID *jid = [XMPPJID jidWithString:jidStr];
	
	if (jid == nil)
	{
		NSLog(@"XMPPUserCoreDataStorageObject: invalid item (missing or invalid jid): %@", item);
		return;
	}
	
	self.jidStr = jidStr;
	self.jid = jid;
	self.nickname = [item attributeStringValueForName:@"name"];
	
	self.displayName = (self.nickname != nil) ? self.nickname : jidStr;
	
	self.subscription = [item attributeStringValueForName:@"subscription"];
	self.ask = [item attributeStringValueForName:@"ask"];
	
	NSArray *groupArray = [XMPPGroupObject usergroupsWithItem:item];
	if (groupArray)
	{
		self.groups = [[NSSet alloc]initWithArray:groupArray];
	}
	
	self.usertype = [[self class] xmppUserTypeWithJidStr:jidStr];

}



////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol 
- (BOOL)isOnline
{
	return (self.primaryResource != nil);
}

- (BOOL)isPendingApproval
{
	// Either of the following mean we're waiting to have our presence subscription approved:
	// <item ask='subscribe' subscription='none' jid='robbiehanson@deusty.com'/>
	// <item ask='subscribe' subscription='from' jid='robbiehanson@deusty.com'/>
	
	NSString *subscription = self.subscription;
	NSString *ask = self.ask;
	
	if ([subscription isEqualToString:@"none"] || [subscription isEqualToString:@"from"])
	{
		if ([ask isEqualToString:@"subscribe"])
		{
			return YES;
		}
	}
	
	return NO;
}

- (id <XMPPResource>)resourceForJID:(XMPPJID *)jid
{
	NSString *jidStr = [jid full];
	
	for (XMPPResourceObject *resource in [self resources])
	{
		if ([jidStr isEqualToString:resource.fullJidStr])
		{
			return resource;
		}
	}
	
	return nil;
}

- (NSArray *)allResources
{
	return [[self resources] allObjects];
}


- (void)recalculatePrimaryResource
{
	self.primaryResource = nil;
	
	NSArray *sortedResources = [[self allResources] sortedArrayUsingSelector:@selector(compare:)];
	if ([sortedResources count] > 0)
	{
		XMPPResourceObject *resource = [sortedResources objectAtIndex:0];
		
		// Primary resource must have a non-negative priority
		if ([resource prioritynum] >= 0)
		{
			self.primaryResource = resource;
			
//			if (resource.shownum >= 3)
//				self.section = 0;
//			else
//				self.section = 1;
		}
	}
	
//	if (self.primaryResource == nil)
//	{
//		self.section = 2;
//	}
}


@end
