// XMPPResourceObject.m
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

#import "XMPPResourceObject.h"
#import "XMPPLogging.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPResourceObject

+ (XMPPResourceObject *)resourceWithPresence:(XMPPPresence *)presence
{
	XMPPResourceObject *resouce = [[[self class] alloc]init];
	[resouce updateWithPresence:presence];
	return resouce;
}

- (void)updateWithPresence:(XMPPPresence *)presence
{
	XMPPJID *jid = [presence from];
	
	if (jid == nil)
	{
		XMPPLogWarn(@"%@: %@ - Invalid presence (missing or invalid jid): %@", [self class], THIS_METHOD, presence);
		return;
	}
	
	self.jid = jid;
	self.fullJidStr = [self.jid full];
	self.bareJidStr = [self.jid bare];
	self.presence = presence;
	self.presenceStr = [presence compactXMLString];
	self.prioritynum = [presence priority];
	self.shownum = [presence intShow];
	
	self.type = [presence type];
	self.show = [presence show];
	self.status = [presence status];
}

//////////////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol

- (NSComparisonResult)compare:(id <XMPPResource>)another
{
	XMPPPresence *mp = [self presence];
	XMPPPresence *ap = [another presence];
	
	int mpp = [mp priority];
	int app = [ap priority];
	
	if(mpp < app)
		return NSOrderedDescending;
	if(mpp > app)
		return NSOrderedAscending;
	
	// Priority is the same.
	// Determine who is more available based on their show.
	int mps = [mp intShow];
	int aps = [ap intShow];
	
	if(mps < aps)
		return NSOrderedDescending;
	if(mps > aps)
		return NSOrderedAscending;
	
	// Priority and Show are the same.
	// Determine based on who was the last to receive a presence element.
	NSDate *mpd = [self presenceDate];
	NSDate *apd = [another presenceDate];
	
	return [mpd compare:apd];
}

@end
