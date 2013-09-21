//
//  IMAudioMsgCell.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMAudioMsgCell.h"
#import "IMAudioMsg.h"
#import "UIView+PPCategory.h"
#import "PPCore.h"
//#import "IMAudioPlayManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation IMAudioMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		self.bgView = [UIButton buttonWithType:UIButtonTypeCustom];
		[_bgView addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_bgView];
		
		UILongPressGestureRecognizer *lpg = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpress:)];
		lpg.cancelsTouchesInView = YES;
		[_bgView addGestureRecognizer:lpg];
		[lpg release];
		
		_activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.frame = CGRectMake(0, 0, 19, 19);
        _activityView.userInteractionEnabled = NO;
        _activityView.hidesWhenStopped = YES;
        [self addSubview:_activityView];
		
		_playStateView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 19, 17)];
		[self addSubview:_playStateView];
		
		_secLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
		_secLabel.backgroundColor = [UIColor clearColor];
		_secLabel.textColor = [UIColor blackColor];
		_secLabel.font = [UIFont systemFontOfSize:14.0f];
		[self addSubview:_secLabel];
		
	}
	return self;
}

- (void)setMsg:(IMMsg *)msg
{
//	[self.msg removeObserver:self forKeyPath:@"procState"];
	[self.msg removeObserver:self forKeyPath:@"playState"];
	[super setMsg:msg];
//	[self.msg addObserver:self forKeyPath:@"procState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
	//readState
	[self.msg addObserver:self forKeyPath:@"playState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"procState"])
	{
//		NSNumber *n = [change objectForKey:NSKeyValueChangeNewKey];
//		PPLOG(@"testnew::%@", n);
		[self layoutActivityView];
	}
	else if([keyPath isEqualToString:@"playState"])
	{
//		NSNumber *n = [change objectForKey:NSKeyValueChangeNewKey];
//		PPLOG(@"readstate:%@", n);
//		NSInteger readstate = [n integerValue];
		[self layoutPlayView];
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)layoutPlayView
{
	IMAudioMsg *tmpMsg = (IMAudioMsg *)self.msg;

	
	[_playStateView stopAnimating];
	
	if(tmpMsg.playState == IMMsgPlayStateUnPlay)
	{
		_playStateView.animationImages = nil;
		_playStateView.image = [UIImage imageNamed:@"voice_playing_unplay.png"];
	}
	else if(tmpMsg.playState == IMMsgPlayStatePlayed || tmpMsg.playState == IMMsgPlayStatePause)
	{
		_playStateView.animationImages = nil;
		_playStateView.image = [UIImage imageNamed:@"voice_played.png"];
	}
	else
	{
		_playStateView.animationDuration = 0.8f;
		_playStateView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"voice_playing_1.png"],[UIImage imageNamed:@"voice_playing_2.png"],[UIImage imageNamed:@"voice_playing_3.png"], nil];
		[_playStateView startAnimating];
	}
}

- (void)layoutActivityView
{
	IMAudioMsg *tmpMsg = (IMAudioMsg *)self.msg;
	if(tmpMsg.procState == IMMsgProcStateProcessing)
	{
		[_activityView startAnimating];
		self.errorView.hidden = YES;
	}
	else if(tmpMsg.procState == IMMsgProcStateFaied)
	{
		[_activityView stopAnimating];
		self.errorView.hidden = NO;
	}
	else
	{
		[_activityView stopAnimating];
		self.errorView.hidden = YES;
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	IMAudioMsg *tmpMsg = (IMAudioMsg *)self.msg;
	
	CGFloat width = kMsgCellBodyMaxWidth;
	NSInteger sec = (tmpMsg.msgSize/50);
	int padsc = (tmpMsg.msgSize%50) < 25?0:1;
	sec = sec + padsc;
	if(sec < 60)
	{
		width = ceilf((((CGFloat)(kMsgCellBodyMaxWidth - 70.0f)/60.0f)*sec+70.0f));
	}
		
	_secLabel.text = [NSString stringWithFormat:@"%d\"", sec];
	CGSize secSize = [_secLabel.text sizeWithFont:_secLabel.font];
	 
	
	CGFloat height = kMsgCellAudioCellHeiht;
	
	if(tmpMsg.fromType == IMMsgFromLocalSelf || tmpMsg.fromType == IMMsgFromRemoteSelf)
	{
		_bgView.frame = CGRectMake(self.userHeadView.left - kMsgCellUserBodyHeadSapce - width, self.userNameLabel.bottom+kMsgCellUserBodySpace, width, height);

		[_bgView setBackgroundImage:kMsgCellChatBubbleGrayImage forState:UIControlStateNormal];
		_activityView.frame = CGRectMake(self.bgView.left - _activityView.width -kMsgCellHeadUserSpace, self.bgView.top + (height - _activityView.height)/2, _activityView.width, _activityView.height);
		_playStateView.frame = CGRectMake(self.bgView.right - _playStateView.width - kMsgCellUserBodyBackGroundHeadingWL , self.bgView.top + (height - _playStateView.height)/2, _playStateView.width, _playStateView.height);
		_playStateView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
		
		_secLabel.frame = CGRectMake(self.bgView.left + kMsgCellUserBodyBackGroundHeadingWR, self.bgView.top +(height - secSize.height)/2, secSize.width, secSize.height);
		self.errorView.frame = CGRectMake(self.bgView.left - self.errorView.width - kMsgCellPadding, self.bgView.top + (height - self.errorView.height)/2, self.errorView.width, self.errorView.height);
	}
	else
	{
		_bgView.frame = CGRectMake(self.userHeadView.right + kMsgCellUserBodyHeadSapce, self.userNameLabel.bottom+kMsgCellUserBodySpace, width, height);
		
		[_bgView setBackgroundImage:kMsgCellChatBubbleGreenImage forState:UIControlStateNormal];

		_activityView.frame = CGRectMake(self.bgView.right + kMsgCellHeadUserSpace , self.bgView.top + (height - _activityView.height)/2, _activityView.width, _activityView.height);
		_playStateView.frame = CGRectMake(self.bgView.left + kMsgCellUserBodyBackGroundHeadingWL, self.bgView.top + (height - _playStateView.height)/2, _playStateView.width, _playStateView.height);
		_playStateView.layer.transform = CATransform3DIdentity;
		
		_secLabel.frame = CGRectMake(self.bgView.right - kMsgCellUserBodyBackGroundHeadingWR - secSize.width, self.bgView.top +(height - secSize.height)/2, secSize.width, secSize.height);
		self.errorView.frame = CGRectMake(self.bgView.right + kMsgCellPadding, self.bgView.top + (height - self.errorView.height)/2, self.errorView.width, self.errorView.height);
	}
	
	[self layoutActivityView];
	[self layoutPlayView];
	
}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg
{
	CGFloat userHeight = msg.fromUser.userType & IMUserTypeP2P?-2:16.0f;
	return kMsgCellTopPading + userHeight + kMsgCellUserBodySpace + kMsgCellAudioCellHeiht + kMsgCellBottomPadding;
}

- (void)cellClick:(id)sender
{
	[self cellBodyClick:sender];
	
//	[[IMAudioPlayManager sharedIMAudioPlayManager] playMsg:tmpMsg];
}

- (void)longpress:(UIGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
		if([self.delegate respondsToSelector:@selector(imMsgCellLongPress:)])
		{
			[self.delegate imMsgCellLongPress:self];
		}
	}
	if(gesture.state == UIGestureRecognizerStateBegan)
    {
		[self becomeFirstResponder];
		UIMenuController * menu = [UIMenuController sharedMenuController];
		[menu setTargetRect:_bgView.frame inView: self];
		[menu setMenuVisible: YES animated: YES];
	}
}


- (void)dealloc
{
//	[self.msg removeObserver:self forKeyPath:@"procState"];
	[self.msg removeObserver:self forKeyPath:@"playState"];
	[_bgView release];
	[_playStateView release];
	[_secLabel release];
	[super dealloc];
}

@end
