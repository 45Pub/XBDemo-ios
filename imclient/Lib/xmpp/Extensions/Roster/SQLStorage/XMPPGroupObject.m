// XMPPGroupObject.m
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

#import "XMPPGroupObject.h"
#import "XMPP.h"
#import "NSNumber+XMPP.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation XMPPGroupObject

+ (NSArray *)usergroupsWithItem:(NSXMLElement *)item
{
	NSMutableArray *array = [[NSMutableArray alloc]init];
	
	NSString *jidStr = [item attributeStringValueForName:@"jid"];
	
	NSArray *groupItems = [item elementsForName:@"group"];
	NSString *groupName = nil;
	
	for (NSXMLElement *groupElement in groupItems)
	{
		groupName = [groupElement stringValue];
		if (groupName)
		{
			XMPPGroupObject *groupObject = [[XMPPGroupObject alloc]init];
			groupObject.jidstr = jidStr;
			groupObject.groupName = groupName;
			[array addObject:groupObject];
		}
	}
	return array;
}

@end
