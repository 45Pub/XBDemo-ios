//
//  AssembleeMsgTool.m
//  DoctorChat
//
//  Created by 王鹏 on 13-2-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "AssembleeMsgTool.h"

#define BEGIN_FLAG @"["
#define END_FLAG @"]"
static NSArray *faceArray = nil;
@implementation AssembleeMsgTool

+ (void)getFaceRange:(NSString *)message inArray:(NSMutableArray *)array
{
	if(message == nil || [message length] <= 0)
		return;
	
	NSRange range = [message rangeOfString:BEGIN_FLAG];
	NSRange endRange = [message rangeOfString:END_FLAG];

	if(range.length > 0 && endRange.length > 0)
	{
		if(range.location > 0)
		{
			[array addObject:[message substringToIndex:range.location]];
			[array addObject:[message substringWithRange:NSMakeRange(range.location, endRange.location+1-range.location)]];
			NSString *str = [message substringFromIndex:endRange.location + 1];
			[self getFaceRange:str inArray:array];
		}
		else
		{
			NSString *nextStr = [message substringWithRange:NSMakeRange(range.location, endRange.location + 1 - range.location)];
			if(![nextStr isEqualToString:@""])
			{
				[array addObject:nextStr];
				NSString *str = [message substringFromIndex:endRange.location + 1];
				[self getFaceRange:str inArray:array];
			}
			else
				return;
		}
	}
	else
	{
		[array addObject:message];
	}
}

+ (NSMutableArray *)getAssembleArrayWithStr:(NSString *)msgstr
{
	if(msgstr == nil || [msgstr length] <= 0)
		return nil;
	NSMutableArray *array = [NSMutableArray array];
	[self getFaceRange:msgstr inArray:array];
	return array;
}

+ (NSArray *)getFaceArray
{
	if(faceArray == nil)
	{
		faceArray = [[NSArray arrayWithObjects:@"[微笑]",
					 @"[撇嘴]",
					 @"[色]",
					 @"[发呆]",
					 @"[得意]",
					 @"[流泪]",
					 @"[害羞]",
					 @"[闭嘴]",
					 @"[睡]",
					 @"[大哭]",
					 @"[尴尬]",
					 @"[发怒]",
					 @"[调皮]",
					 @"[呲牙]",
					 @"[惊讶]",
					 @"[难过]",
					 @"[酷]",
					 @"[冷汗]",
					 @"[抓狂]",
					 @"[吐]",
					 @"[偷笑]",
					 @"[愉快]",
					 @"[白眼]",
					 @"[傲慢]",
					 @"[饥饿]",
					 @"[困]",
					 @"[惊恐]",
					 @"[流汗]",
					 @"[憨笑]",
					 @"[大兵]",
					 @"[奋斗]",
					 @"[咒骂]",
					 @"[疑问]",
					 @"[嘘]",
					 @"[晕]",
					 @"[折磨]",
					 @"[衰]",
					 @"[骷髅]",
					 @"[敲打]",
					 @"[再见]",
					 @"[擦汗]",
					 @"[抠鼻]",
					 @"[鼓掌]",
					 @"[糗大了]",
					 @"[坏笑]",
					 @"[左哼哼]",
					 @"[右哼哼]",
					 @"[哈欠]",
					 @"[鄙视]",
					 @"[委屈]",
					 @"[快哭了]",
					 @"[阴险]",
					 @"[亲亲]",
					 @"[吓]",
					 @"[可怜]",
					 @"[菜刀]",
					 @"[西瓜]",
					 @"[啤酒]",
					 @"[篮球]",
					 @"[乒乓]",
					 @"[咖啡]",
					 @"[饭]",
					 @"[猪头]",
					 @"[玫瑰]",
					 @"[凋谢]",
					 @"[示爱]",
					 @"[爱心]",
					 @"[心碎]",
					 @"[蛋糕]",
					 @"[闪电]",
					 @"[炸弹]",
					 @"[刀]",
					 @"[足球]",
					 @"[瓢虫]",
					 @"[便便]",
					 @"[月亮]",
					 @"[太阳]",
					 @"[礼物]",
					 @"[拥抱]",
					 @"[强]",
					 @"[弱]",
					 @"[握手]",
					 @"[胜利]",
					 @"[抱拳]",
					 @"[勾引]",
					 @"[拳头]",
					 @"[差劲]",
					 @"[爱你]",
					 @"[NO]",
					 @"[OK]",
					 @"[爱情]",
					 @"[飞吻]",
					 @"[跳跳]",
					 @"[发抖]",
					 @"[怄火]",
					 @"[转圈]",
					 @"[磕头]",
					 @"[回头]",
					 @"[跳绳]",
					 @"[挥手]",
					 @"[激动]",
					 @"[街舞]",
					 @"[献吻]",
					 @"[左太极]",
					 @"[右太极]",
					 nil] retain];

	}
	return faceArray;
}

+ (BOOL)isFaceStr:(NSString *)str
{
	NSArray *array = [self getFaceArray];
	if([array containsObject:str])
	{
		return YES;
	}
	return NO;
}

+ (NSString *)getFaceImageWithStr:(NSString *)str
{
	NSArray *array = [self getFaceArray];
	NSInteger idx = [array indexOfObject:str];
	if(idx != NSNotFound)
	{
		return [NSString stringWithFormat:@"smiley_%d.png", idx];
	}
	return nil;
}

@end
