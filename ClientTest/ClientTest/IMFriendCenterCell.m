//
//  IMFriendCenterCell.m
//  IMLite
//
//  Created by pengjay on 13-7-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFriendCenterCell.h"
#import <IMContext.h>
#import <IMMsgStorage.h>
@implementation IMFriendCenterCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		self.bgImageView = [[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.width-10, 10)] autorelease];
		self.bgImageView.image = [[UIImage imageNamed:@"addnotice_bubble.png"] stretchableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 5, 20)];
		[self.contentView addSubview:self.bgImageView];
		[self.contentView sendSubviewToBack:self.bgImageView];
		
		self.accessImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 15)];
		self.accessImageView.image = [UIImage imageNamed:@"arrow.png"];
		[self.contentView addSubview:self.accessImageView];
		
		self.userNameLabel.font = [UIFont systemFontOfSize:15.0f];
		self.userNameLabel.textColor = UICOLOR_RGB(27, 27, 27);
		
		self.contentLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
		self.contentLabel.font = [UIFont systemFontOfSize:12.0f];
		self.contentLabel.textColor = UICOLOR_RGB(125, 125, 125);
		self.contentLabel.numberOfLines = 0;
		self.contentLabel.lineBreakMode	= UILineBreakModeWordWrap;
		[self.contentView addSubview:self.contentLabel];
		
		self.detailLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
		self.detailLabel.font = [UIFont systemFontOfSize:12.0f];
		[self.contentView addSubview:_detailLabel];
    }
    return self;
}

- (void)dealloc
{
	[_detailLabel release];
	[_accessImageView release];
	[_bgImageView release];
	[_contentLabel release];
	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	PPLOG(@"%@", self.msg.msgBody);
	self.userHeadView.left = self.bgImageView.left + 8;
	self.userHeadView.top = self.bgImageView.top + 8;
	self.userNameLabel.left = self.userHeadView.right + 8;
	self.userNameLabel.top = self.bgImageView.top + 8;
	
	CGSize size = [self.msg.msgBody sizeWithFont:self.contentLabel.font constrainedToSize:CGSizeMake(160, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	self.contentLabel.frame = CGRectMake(self.userHeadView.right + 8, self.userNameLabel.bottom + 8, size.width, size.height);
	self.contentLabel.text = self.msg.msgBody;
	
	
	self.accessImageView.left = self.bgImageView.right -8 - self.accessImageView.width;
	self.bgImageView.height = MAX(self.contentLabel.bottom + 10 - self.bgImageView.top, self.userHeadView.height + 16);
	self.accessImageView.top = self.bgImageView.top + (self.bgImageView.height - self.accessImageView.height)/2;
	
	NSString *detailstr = @"已添加";
	CGSize size1 = [detailstr sizeWithFont:self.detailLabel.font];
//	if([[IMContext sharedContext].msgStorage getFrinedCenterProcStateWithUser:self.msg.msgUser] == IMMsgProcStateSuc)
    if(self.msg.procState == IMMsgProcStateSuc || [[IMContext sharedContext].msgStorage getFrinedCenterProcStateWithUser:self.msg.msgUser] == IMMsgProcStateSuc)
	{
		
		self.detailLabel.textColor = UICOLOR_RGB(125, 125, 125);
        self.accessImageView.hidden = YES;
		
	}
	else
	{
		detailstr = @"未处理";
		self.detailLabel.textColor = UICOLOR_RGB(235, 97, 0);
        self.accessImageView.hidden = NO;
	}
	self.detailLabel.text = detailstr;
	self.detailLabel.frame = CGRectMake(self.accessImageView.left - size1.width - 10, self.bgImageView.top + (self.bgImageView.height - size1.height)/2, size1.width, size1.height);
}


//- (void)confirmclick:(id)sender
//{
//	PPLOG(@"confirm click");
//	[del.xmppDelegate confireFriendAskto:self.msg.msgUser.userID];
//}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg
{
	CGSize size = [msg.msgBody sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(160, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	return MAX(size.height + 5 + 8 + 15 + 8 + 10 + 5, kMsgCellUserHeadViewHeight + 16 + 10);
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
