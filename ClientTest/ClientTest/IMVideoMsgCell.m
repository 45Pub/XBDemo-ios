//
//  IMVideoMsgCell.m
//  GoComIM
//
//  Created by 王鹏 on 13-5-8.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMVideoMsgCell.h"
#import <IMContext.h>
#import <IMMsgStorage.h>

@implementation IMVideoMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.timeLabel = [[[UILabel alloc]init] autorelease];
		self.timeLabel.font = [UIFont systemFontOfSize:10.0f];
		self.timeLabel.backgroundColor = [UIColor clearColor];
		self.timeLabel.textColor = [UIColor whiteColor];
		
		[self.bgView addSubview:self.timeLabel];
		
		self.playImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"msg_video.png"]] autorelease];
		[self.bgView addSubview:self.playImageView];
		
		self.optBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_optBtn.hidden = YES;
		_optBtn.frame = CGRectMake(0, 0, 47, 31);
		_optBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[_optBtn addTarget:self action:@selector(optClick:) forControlEvents:UIControlEventTouchUpInside];
		[_optBtn setBackgroundImage:[UIImage imageNamed:@"msg_btn_gray.png"] forState:UIControlStateNormal];
		[_optBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_optBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
		[self addSubview:_optBtn];
		
		
    }
    return self;
}

- (void)dealloc
{
	[_timeLabel release];
	[_playImageView release];
	[_optBtn release];
	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.errorView.hidden = YES;
	IMVideoMsg *videoMsg = (IMVideoMsg *)self.msg;
	self.playImageView.center = self.picView.center;
	
	if (videoMsg.procState == IMMsgProcStateProcessing)
	{
		_optBtn.hidden = NO;
		[_optBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
		_optBtn.top = self.bgView.top + (self.bgView.height - _optBtn.height)/2;
		if (self.msg.fromType == IMMsgFromLocalSelf || self.msg.fromType == IMMsgFromRemoteSelf)
		{
			_optBtn.right = self.bgView.left - 10;
		}
		else
		{
			_optBtn.left = self.bgView.right + 10;
		}
		self.timeLabel.hidden = YES;
	}
	else if(videoMsg.procState == IMMsgProcStateFaied)
	{
		_optBtn.hidden = NO;
		[_optBtn setTitle:NSLocalizedString(@"重试", nil) forState:UIControlStateNormal];
		_optBtn.top = self.bgView.top + (self.bgView.height - _optBtn.height)/2;
		if (self.msg.fromType == IMMsgFromLocalSelf || self.msg.fromType == IMMsgFromRemoteSelf)
		{
			_optBtn.right = self.bgView.left - 10;
		}
		else
		{
			_optBtn.left = self.bgView.right + 10;
		}
		self.timeLabel.hidden = YES;
	}
	else
	{
		_optBtn.hidden = YES;
		self.timeLabel.hidden = NO;
		self.timeLabel.text = [NSString stringWithFormat:@"%02llu:%02llu", videoMsg.msgSize/60, videoMsg.msgSize%60];
		[self.timeLabel sizeToFit];
		self.timeLabel.center = self.playImageView.center;
		self.timeLabel.bottom = self.bgView.height - 5 ;
	}
}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg
{
	return [super heightForCellWithMsg:msg];
}

- (void)optClick:(id)sender
{
	PPLOG(@"cancel");
	if (self.msg.procState == IMMsgProcStateProcessing)
	{
		self.msg.procState = IMMsgProcStateFaied;
		[[IMContext sharedContext].msgStorage updateMsgState:self.msg];

		//Todo cancel send or download
		if ([self.delegate respondsToSelector:@selector(imMsgCellCancelProcess:)])
		{
			[self.delegate imMsgCellCancelProcess:self];
		}
	}
	else if (self.msg.procState == IMMsgProcStateFaied || self.msg.procState == IMMsgProcStateUnproc)
	{
		if ([self.delegate respondsToSelector:@selector(imMsgCellReProcess:)])
		{
			[self.delegate imMsgCellReProcess:self];
		}
	}
	else if (self.msg.procState == IMMsgProcStateSuc)
	{
		//todo review Files
		if ([self.delegate respondsToSelector:@selector(imMsgCellGotoPreView:)])
		{
			[self.delegate imMsgCellGotoPreView:self];
		}
	}

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
