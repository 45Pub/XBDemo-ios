//
//  IMMsgCellUtil.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgCellUtil.h"
#import "UIImage+PPCategory.h"
#import "UIView+PPCategory.h"
@implementation IMMsgCellUtil

+ (CGFloat)cellHeightForMsg:(id)msg
{
	if([msg isMemberOfClass:[IMMsg class]])
	{
		return [IMTextMsgCell heightForCellWithMsg:msg];
	}
	else if([msg isMemberOfClass:[IMFileMsg class]])
	{
		return [IMFileMsgCell heightForCellWithMsg:msg];
	}
	else if([msg isMemberOfClass:[IMAudioMsg class]])
	{
		return [IMAudioMsgCell heightForCellWithMsg:msg];
	}
	else if([msg isMemberOfClass:[IMPicMsg class]])
	{
		return [IMPicMsgCell heightForCellWithMsg:msg];
	}
	else if([msg isMemberOfClass:[IMVideoMsg class]])
	{
		return [IMVideoMsgCell heightForCellWithMsg:msg];
	}
//	else if ([msg isMemberOfClass:[IMMailMsg class]])
//	{
//		return [IMMailMsgCell heightForCellWithMsg:msg];
//	}
//	else if ([msg isMemberOfClass:[IMNewsMsg class]])
//	{
//		return [IMNewsMsgCell heightForCellWithMsg:msg];
//	}
//	else if ([msg isMemberOfClass:[IMPostMsg class]])
//	{
//		return [IMPostMsgCell heightForCellWithMsg:msg];
//	}
	else if ([msg isMemberOfClass:[IMNoticeMsg class]])
	{
		return [IMNoticeCell heightForCellWithMsg:msg];
	}
	else if ([msg isMemberOfClass:[IMFriendCenterMsg class]]) {
		return [IMFriendCenterCell heightForCellWithMsg:msg];
	}
	else
	{
		return 38.0f;
	}
}

+ (UITableViewCell *)tableView:(UITableView *)tableView cellForMsg:(id)msg
{
	IMMsgCell *cell = nil;
	if([msg isMemberOfClass:[IMMsg class]])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"IMTextMsg"];
		if(cell == nil)
		{
			cell = [[[IMTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMTextMsg"] autorelease];
		}
		
		cell.msg = msg;
	}
	else if([msg isMemberOfClass:[IMFileMsg class]])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"IMFileMsg"];
		if(cell == nil)
		{
			cell = [[[IMFileMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMFileMsg"] autorelease];
		}
		
		cell.msg = msg;
	}
	else if([msg isMemberOfClass:[IMPicMsg class]])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"IMPicMsg"];
		if(cell == nil)
		{
			cell = [[[IMPicMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMPicMsg"] autorelease];
		}
		
		cell.msg = msg;
	}
	else if([msg isMemberOfClass:[IMAudioMsg class]])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"IMAudioMsg"];
		if(cell == nil)
		{
			cell = [[[IMAudioMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMAudioMsg"] autorelease];
		}
		
		cell.msg = msg;
	}
	
	else if([msg isMemberOfClass:[IMVideoMsg class]])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"IMVideoMsg"];
		if(cell == nil)
		{
			cell = [[[IMVideoMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMVideoMsg"] autorelease];
		}
		
		cell.msg = msg;
	}
	else if([msg isKindOfClass:[NSDate class]])
	{
		IMTimeCell *cell1 = nil;
		cell1 = [tableView dequeueReusableCellWithIdentifier:@"TimeLabel"];
		if(cell1 == nil)
		{
			cell1 = [[[IMTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TimeLabel"] autorelease];
		}
		cell1.msgTime = (NSDate *)msg;
		return cell1;
	}
//	else if ([msg isMemberOfClass:[IMMailMsg class]])
//	{
//		cell = [tableView dequeueReusableCellWithIdentifier:@"IMMailMsg"];
//		if(cell == nil)
//		{
//			cell = [[[IMMailMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMMailMsg"] autorelease];
//		}
//		
//		cell.msg = msg;
//	}
//	else if ([msg isMemberOfClass:[IMNewsMsg class]])
//	{
//		cell = [tableView dequeueReusableCellWithIdentifier:@"IMNewsMsg"];
//		if(cell == nil)
//		{
//			cell = [[[IMNewsMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMNewsMsg"] autorelease];
//		}
//		
//		cell.msg = msg;
//
//	}
//	else if ([msg isMemberOfClass:[IMPostMsg class]])
//	{
//		cell = [tableView dequeueReusableCellWithIdentifier:@"IMPostMsg"];
//		if(cell == nil)
//		{
//			cell = [[[IMPostMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMPostMsg"] autorelease];
//		}
//		
//		cell.msg = msg;
//
//	}
//
	else if([msg isMemberOfClass:[IMFriendCenterMsg class]])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"IMFrMsg"];
		if(cell == nil)
		{
			cell = [[[IMFriendCenterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMFrMsg"] autorelease];
		}
		
		cell.msg = msg;
	}
	else if([msg isMemberOfClass:[IMNoticeMsg class]])
	{
		IMNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IMNoticeMsg"];
		if(cell == nil)
		{
			cell = [[[IMNoticeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMNoticeMsg"] autorelease];
		}
		
		cell.msg = msg;
		return cell;
	}
	return cell;
}

@end
