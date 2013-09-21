//
//  IMPicMsgCell.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMPicMsgCell.h"
#import "IMPicMsg.h"
#import "UIView+PPCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+PPCategory.h"
#import "UITableView+PPCategory.h"
#import "UserAvatarCache.h"

@implementation IMPicMsgCell

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
		
		_picView = [[UIImageView alloc]initWithFrame:CGRectZero];
		_picView.backgroundColor = [UIColor clearColor];
		_picView.clipsToBounds = YES;
		_picView.layer.masksToBounds = YES;
		_picView.layer.cornerRadius = 5.0f;
		
		[_bgView addSubview:_picView];
		
		UIImage * backgroundImage = [[UIImage imageNamed:@"loading_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 3, 2, 3)];
		UIImage * foregroundImage = [[UIImage imageNamed:@"loading"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 3, 2, 3)];
		_progressBarView = [[MCProgressBarView alloc] initWithFrame:CGRectMake(10, 0, 70, 7)
													backgroundImage:backgroundImage
													foregroundImage:foregroundImage];
		[_bgView addSubview:_progressBarView];
		self.errorView.hidden = NO;
	}
	return self;
}

- (void)setMsg:(IMMsg *)msg
{
//	[self.msg removeObserver:self forKeyPath:@"procState"];
	[self.msg removeObserver:self forKeyPath:@"progress"];
//	[self.msg removeObserver:self forKeyPath:@"thumbnailChangeflag"];
	[super setMsg:msg];

	if ((msg.procState == IMMsgProcStateUnproc || msg.procState == IMMsgProcStateFaied) && msg.fromType != IMMsgFromLocalSelf) {
		IMPicMsg *picMsg = (IMPicMsg *)msg;
		[picMsg downloadFile];
	}
//	[self.msg addObserver:self forKeyPath:@"procState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
	[self.msg addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
//	[self.msg addObserver:self forKeyPath:@"thumbnailChangeflag" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)reloadSuperViewCell
{
	dispatch_async(dispatch_get_main_queue(), ^{
	if ([self.superview isKindOfClass:[UITableView class]]) {
		UITableView *tabView = (UITableView *)self.superview;
//		if ([tabView.visibleCells containsObject:self])
		{
			[tabView reloadData];
		}
//		[tabView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
		
		//				[tabView scrollToLastRow:YES];
		
	}
	});
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"procState"] )
	{
		NSNumber *n = [change objectForKey:NSKeyValueChangeNewKey];
		PPLOG(@"testnew::%@", n);
		dispatch_async(dispatch_get_main_queue(), ^{
			[self  setNeedsLayout];
		});
	}
//	else if ([keyPath isEqualToString:@"thumbnailChangeflag"])
//	{
//		[self reloadSuperViewCell];
//		[self performSelector:@selector(reloadSuperViewCell) withObject:nil afterDelay:0];
//		[self performSelectorOnMainThread:@selector(reloadSuperViewCell) withObject:nil waitUntilDone:NO];
//	}
	else if([keyPath isEqualToString:@"progress"])
	{
		NSNumber *n = [change objectForKey:NSKeyValueChangeNewKey];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			_progressBarView.progress = [n floatValue];
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	
	IMPicMsg *tmpMsg = (IMPicMsg *)self.msg;
	
	UIImage *thumbImage = nil;
		if ([[NSFileManager defaultManager] fileExistsAtPath:tmpMsg.fileLocalPath])
		{
			thumbImage = [[UserAvatarCache sharedUserAvatarCache] cacheImageWithPath:tmpMsg.fileLocalPath];
		}
		
		if (!thumbImage)
		{
			if (self.msg.msgType == IMMsgTypePic)
				thumbImage = [UIImage imageNamed:kMsgPicCellDefaultPic];
			else
				thumbImage = [UIImage imageNamed:kMsgVideoCellDefualtPic];
		}
	


	CGFloat width = thumbImage.size.width;
	CGFloat height = thumbImage.size.height;

	if(width > kMsgPicCellMaxWidth || height > kMsgPicCellMaxHeight)
	{
		CGFloat factor1 = kMsgPicCellMaxWidth/width;
		CGFloat factor2 = kMsgPicCellMaxHeight/height;
		CGFloat factor = MIN(factor1, factor2);
		width = width *factor;
		height = height *factor;
	}

	if(tmpMsg.fromType == IMMsgFromRemoteSelf || tmpMsg.fromType == IMMsgFromLocalSelf)
	{
		_bgView.frame = CGRectMake(self.userHeadView.left - kMsgCellUserBodyHeadSapce - (width+kMsgPicCellBodyLeftPadding + kMsgPicCellBodyPadding), self.userNameLabel.bottom+kMsgCellUserBodySpace, width+kMsgPicCellBodyLeftPadding + kMsgPicCellBodyPadding, height + 2*kMsgPicCellBodyPadding);
		_picView.frame = CGRectMake(kMsgPicCellBodyPadding, kMsgPicCellBodyPadding, width, height);
		[_bgView setBackgroundImage:kMsgCellChatBubbleGrayImage forState:UIControlStateNormal];
		self.errorView.frame = CGRectMake(self.bgView.left - self.errorView.width - kMsgCellPadding, self.bgView.top + (self.bgView.height - self.errorView.height)/2, self.errorView.width, self.errorView.height);
	}
	else
	{
		_bgView.frame = CGRectMake(self.userHeadView.right + kMsgCellUserBodyHeadSapce, self.userNameLabel.bottom+kMsgCellUserBodySpace, width+kMsgPicCellBodyLeftPadding + kMsgPicCellBodyPadding, height + 2*kMsgPicCellBodyPadding);
		_picView.frame = CGRectMake(kMsgPicCellBodyLeftPadding, kMsgPicCellBodyPadding, width, height);
		
		[_bgView setBackgroundImage:kMsgCellChatBubbleGreenImage forState:UIControlStateNormal];
		self.errorView.frame = CGRectMake(self.bgView.right + kMsgCellPadding, self.bgView.top + (self.bgView.height - self.errorView.height)/2, self.errorView.width, self.errorView.height);
	}
	_picView.image = thumbImage;
	if (self.msg.procState == IMMsgProcStateProcessing)
	{
		_progressBarView.hidden = NO;
		_progressBarView.progress = tmpMsg.progress;
		
		_progressBarView.left = _picView.left + 5;
		_progressBarView.bottom = _picView.bottom - 5;
		_progressBarView.width = _picView.width - 10;
	}
	else
	{
		_progressBarView.hidden = YES;
	}
	
	if (self.msg.procState == IMMsgProcStateFaied)
	{
		self.errorView.hidden = NO;
	}
	else
	{
		self.errorView.hidden = YES;
	}

}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg
{
	IMPicMsg *tmpMsg = (IMPicMsg *)msg;
	UIImage *thumbImage = nil;
//	if(tmpMsg.thumbImage == nil)
	{
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:tmpMsg.fileLocalPath])
		{
			thumbImage = [[UserAvatarCache sharedUserAvatarCache] cacheImageWithPath:tmpMsg.fileLocalPath];
		}
		
		if (!thumbImage)
		{
			if (msg.msgType == IMMsgTypePic)
				thumbImage = [UIImage imageNamed:kMsgPicCellDefaultPic];
			else
				thumbImage = [UIImage imageNamed:kMsgVideoCellDefualtPic];
		}
	}
	
	CGFloat width = thumbImage.size.width;
	CGFloat height = thumbImage.size.height;
	
	if(width > kMsgPicCellMaxWidth || height > kMsgPicCellMaxHeight)
	{
		CGFloat factor1 = kMsgPicCellMaxWidth/width;
		CGFloat factor2 = kMsgPicCellMaxHeight/height;
		CGFloat factor = MIN(factor1, factor2);
		width = width *factor;
		height = height *factor;
	}

	CGFloat userHeight = msg.fromUser.userType == IMUserTypeP2P?-2:16.0f;
	
	return kMsgCellTopPading + userHeight + kMsgCellUserBodySpace + height + 2*kMsgPicCellBodyPadding + kMsgCellBottomPadding;
}

- (void)cellClick:(id)sender
{
	[self cellBodyClick:sender];
//	IMPicMsg *tmpMsg = (IMPicMsg *)self.msg;
//	NSLog(@"djkfjkdjfkdj");
//	if(self.msg.procState == IMMsgProcStateFaied)
//	{
//		if(self.msg.fromSelf == YES)
//		{//todo send failed
//			PPLOG(@"resend!!");
//		}
//		else
//		{
//			PPLOG(@"redownload");
//			[tmpMsg downLoadFile];
//		}
//	}
//	else
//	{
//		NSLog(@"click");
//		if(self.delegate && [self.delegate respondsToSelector:@selector(imMsgCellPicDidSelected:)])
//		{
//			PPLOG(@"clik");
//			[self.delegate imMsgCellPicDidSelected:self];
//		}
//	}
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
//	[self.msg removeObserver:self forKeyPath:@"procState"];
	[self.msg removeObserver:self forKeyPath:@"progress"];
//	[self.msg removeObserver:self forKeyPath:@"thumbnailChangeflag"];
	[_bgView release];
	[_picView release];
	[_progressBarView release];
	[super dealloc];
}

@end
