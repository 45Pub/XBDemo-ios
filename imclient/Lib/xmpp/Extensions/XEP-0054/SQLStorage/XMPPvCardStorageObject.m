// XMPPvCardStorageObject.m
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

#import "XMPPvCardStorageObject.h"
#import "XMPPvCardTemp.h"
#import "NSData+XMPP.h"
#import <objc/runtime.h>



@implementation XMPPvCardStorageObject


+ (NSString *)vCardsavePath
{
	NSString *filePath = [NSString stringWithFormat:@"%@/Library/Caches/vCardTemp", NSHomeDirectory()];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	NSLog(@"%@", filePath);
	return filePath;
}

+ (NSString *)vCardDbPath
{
	return [[[self class] vCardsavePath] stringByAppendingPathExtension:@"vCard.db"];
}

+(NSString *)vCardPhotoSavePath:(NSString *)jidstr
{
	NSString *filePath = [NSString stringWithFormat:@"%@/Library/Caches/photo", NSHomeDirectory()];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
	}

	NSString *key = [[jidstr dataUsingEncoding:NSUTF8StringEncoding] md5HashStr];
	return [filePath stringByAppendingPathComponent:key];
}

+ (NSString *)vCardTempSavePath:(NSString *)jidstr;
{
	NSString *filePath = [[self class] vCardsavePath];
	NSString *key = [[jidstr dataUsingEncoding:NSUTF8StringEncoding] md5HashStr];
	return [filePath stringByAppendingPathComponent:key];
}

+ (XMPPvCardTemp *)readvCardTemp:(XMPPJID *)jid
{
	XMPPvCardTemp *vCardTemp = nil;
	NSString *content = [NSString stringWithContentsOfFile:[[self class] vCardTempSavePath:[jid bare]] encoding:NSUTF8StringEncoding error:nil];
	if (content)
	{
		NSXMLElement *element = [[NSXMLElement alloc]initWithXMLString:content error:nil];
		if (element)
		{
			object_setClass(element, [XMPPvCardTemp class]);
			vCardTemp = (XMPPvCardTemp *)element;
		}
	}
	
	return vCardTemp;
}

+ (void)writevCardTemp:(XMPPvCardTemp *)vCardTemp forJid:(XMPPJID *)jid
{
	NSString *content = [vCardTemp compactXMLString];
	if (content)
	{
		NSString *path = [[self class] vCardTempSavePath:[jid bare]];
		[content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}

+ (void)removevCardTempForJid:(XMPPJID *)jid
{
	NSString *path = [[self class] vCardTempSavePath:[jid bare]];
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -


@end
