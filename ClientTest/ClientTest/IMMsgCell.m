//
//  IMMsgCell.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AvatarHelper.h"
@implementation IMMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.detailTextLabel.hidden = YES;
		self.textLabel.hidden = YES;
		self.layer.shouldRasterize = YES;
		self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		self.userHeadView = [[[UIImageView alloc]initWithFrame:CGRectMake(kMsgCellLeftPading, kMsgCellTopPading, kMsgCellUserHeadViewWidth, kMsgCellUserHeadViewHeight)] autorelease];
		/////////
		self.userHeadView.layer.masksToBounds = YES;
		self.userHeadView.layer.cornerRadius = 2.0f;
		///////
		[self.contentView addSubview:self.userHeadView];
		self.userHeadView.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headViewClick:)];
        tapGesture1.numberOfTapsRequired = 1;
        tapGesture1.numberOfTouchesRequired = 1;
        [self.userHeadView addGestureRecognizer:tapGesture1];
        [tapGesture1 release];

		
		self.userNameLabel = [[[UILabel alloc]initWithFrame:CGRectZero] autorelease];
//        self.userNameLabel.frame
		self.userNameLabel.backgroundColor = [UIColor clearColor];
		self.userNameLabel.textColor = kMsgCellUserNameColor;
		self.userNameLabel.font = kMsgCellUserNameFont;
		
		[self.contentView addSubview:_userNameLabel];
		
//		self.errorView = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 19)] autorelease];
//		self.errorView.image = [UIImage imageNamed:@"msg_wrong.png"];
		
		self.errorView = [UIButton buttonWithType:UIButtonTypeCustom];
		self.errorView.frame = CGRectMake(0, 0, 10, 19);
		[self.errorView setBackgroundImage:[UIImage imageNamed:@"msg_wrong"] forState:UIControlStateNormal];
		[self.errorView addTarget:self action:@selector(errorClick:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_errorView];
		self.errorView.hidden = YES;
		self.canDelete = YES;
    }
    return self;
}

- (void)setMsg:(IMMsg *)msg
{
	if (_msg == msg)
		return;
	if (_msg != nil)
	{
		[_msg.msgUser removeObserver:self forKeyPath:@"changeFlag"];
		[self.msg removeObserver:self forKeyPath:@"procState"];

		[_msg release];
	}
	_msg = msg;
	[msg retain];
	
	[_msg.msgUser addObserver:self forKeyPath:@"changeFlag" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
	[self.msg addObserver:self forKeyPath:@"procState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
	
	[self setNeedsLayout];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"procState"])
	{
		//		NSNumber *n = [change objectForKey:NSKeyValueChangeNewKey];
		//		PPLOG(@"testnew::%@", n);
		dispatch_async(dispatch_get_main_queue(), ^{
			//			[self refreshPic];
			[self setNeedsLayout];
		});
	}
	else if ([keyPath isEqualToString:@"changeFlag"])
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self setNeedsLayout];
		  		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)layoutSubviews
{
	if (_msg == nil)
	{
		[super layoutSubviews];
		return;
	}
//	self.userHeadView.image = [[UserAvatarCache sharedUserAvatarCache] cacheImageWithPath:self.msg.msgUser.avatarPath];
	[AvatarHelper addAvatar:_msg.msgUser toImageView:self.userHeadView];
	if (!(self.msg.fromUser.userType & IMUserTypeP2P))
	{
		self.userNameLabel.text = self.msg.msgUser.nickname;
		[self.userNameLabel sizeToFit];
        if (self.userNameLabel.width >= 190) {
            self.userNameLabel.width = 190;
            self.userNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        NSLog(@"user name label size::::%f", self.userNameLabel.frame.size.width);
	}
	else
	{
		self.userNameLabel.text = nil;
		
	}
	
	
	if (_msg.fromType == IMMsgFromOther)
	{
		_userHeadView.frame = CGRectMake(kMsgCellLeftPading, kMsgCellTopPading, kMsgCellUserHeadViewWidth, kMsgCellUserHeadViewHeight);
		self.userNameLabel.left = self.userHeadView.right + kMsgCellHeadUserSpace;
		self.userNameLabel.top = kMsgCellTopPading;
	}
	else
	{
		_userHeadView.frame = CGRectMake(self.width-kMsgCellUserHeadViewWidth-kMsgCellLeftPading, kMsgCellTopPading, kMsgCellUserHeadViewWidth, kMsgCellUserHeadViewHeight);
		self.userNameLabel.left = self.userHeadView.left - self.userNameLabel.width - kMsgCellHeadUserSpace;
		self.userNameLabel.top = kMsgCellTopPading;
	}
	
	if (self.msg.fromUser.userType & IMUserTypeP2P)
	{
		self.userNameLabel.bottom -= kMsgCellUserBodySpace;
	}

}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg
{
	return kMsgCellUserHeadViewHeight + kMsgCellTopPading;
}

- (void)errorClick:(id)sender
{
	if(_delegate && [_delegate respondsToSelector:@selector(imMsgCellErrorClick:)])
	{
		[_delegate imMsgCellErrorClick:self];
	}
}

- (void)cellBodyClick:(id)sender
{
	if(_delegate && [_delegate respondsToSelector:@selector(imMsgCellBodyDidSelected:)])
	{
		[_delegate imMsgCellBodyDidSelected:self];
	}
}

- (void)headViewClick:(id)sender
{
	if(_delegate && [_delegate respondsToSelector:@selector(imMsgCellHeadDidSelected:)])
	{
		[_delegate imMsgCellHeadDidSelected:self];
	}
}

- (void)dealloc
{
	if (_msg != nil)
	{
		[_msg.msgUser removeObserver:self forKeyPath:@"changeFlag"];
		[self.msg removeObserver:self forKeyPath:@"procState"];
		[_msg release];
		_msg = nil;
	}
	[_userHeadView release];
	[_userNameLabel release];
	[_errorView release];
	[_indexPath release];
	[super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(cut:)){
        return NO;
    }
    else if(action == @selector(copy:)){
        return NO;
    }
    else if(action == @selector(paste:)){
        return NO;
    }
    else if(action == @selector(select:)){
        return NO;
    }
    else if(action == @selector(selectAll:)){
        return NO;
    }
	else if(action == @selector(delete:))
	{
		return self.canDelete;
	}
    else
    {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)delete:(id)sender
{
	if([self.delegate respondsToSelector:@selector(imMsgCellShouldDelete:)])
	{
		[self.delegate imMsgCellShouldDelete:self];
	}
}

@end
