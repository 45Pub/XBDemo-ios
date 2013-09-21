//
//  IMFileMsgCell.m
//  GoComIM
//
//  Created by 王鹏 on 13-5-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFileMsgCell.h"
#import "MCProgressBarView.h"
#import "UIHelper.h"
#import "IMLiteUtil.h"
#import <IMContext.h>
#import <IMMsgStorage.h>
@implementation IMFileMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
		_bodyBgView = [UIButton buttonWithType:UIButtonTypeCustom];
		[_bodyBgView addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];

		[self.contentView addSubview:_bodyBgView];
		UILongPressGestureRecognizer *lpg = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpress:)];
		lpg.cancelsTouchesInView = YES;
		[_bodyBgView addGestureRecognizer:lpg];
		[lpg release];
		_bodyIconView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"msg_icon_office.png"]];
		[_bodyBgView addSubview:_bodyIconView];
		
		_nameLabel = [[UILabel alloc]init];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.numberOfLines = 0;
		_nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
		_nameLabel.font = KMsgCellBodyTextFont;
		_nameLabel.textColor = kMsgCellBodyTextColor;
		
		[_bodyBgView addSubview:_nameLabel];
		
		_stateLabel = [[UILabel alloc]init];
		_stateLabel.backgroundColor = [UIColor clearColor];
		_stateLabel.font = [UIFont systemFontOfSize:11.0f];
		
		[_bodyBgView addSubview:_stateLabel];
		
        UIImage * backgroundImage = [[UIImage imageNamed:@"loading_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 3, 2, 4)];
		UIImage * foregroundImage = [[UIImage imageNamed:@"loading"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 3, 2, 4)];
		_progressBar = [[MCProgressBarView alloc] initWithFrame:CGRectMake(10, 0, 110, 7)
													backgroundImage:backgroundImage
													foregroundImage:foregroundImage];
		[_bodyBgView addSubview:_progressBar];
		_progressBar.hidden = YES;
		
		_optBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_optBtn.frame = CGRectMake(0, 0, 47, 31);
		_optBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[_optBtn addTarget:self action:@selector(optFiles:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.contentView addSubview:_optBtn];
		
		self.errorView.hidden = YES;
    }
    return self;
}

- (void)dealloc
{
	[self.msg removeObserver:self forKeyPath:@"progress"];
	
	[_bodyIconView release];
	[_nameLabel release];
	[_stateLabel release];
	[_optBtn release];
	[_progressBar release];
	[super dealloc];
}

- (void)setMsg:(IMMsg *)msg
{
	[self.msg removeObserver:self forKeyPath:@"progress"];
	[super setMsg:msg];
	
	[self.msg addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	 if([keyPath isEqualToString:@"progress"])
	{
		NSNumber *n = [change objectForKey:NSKeyValueChangeNewKey];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			_progressBar.progress = [n floatValue];
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (NSString *)displayName
{
//	return [self.msg.msgAttach objectForKey:@"displayName"];
	IMFileMsg *filemsg = (IMFileMsg *)self.msg;
	return [[filemsg fileLocalPath] lastPathComponent];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	IMFileMsg *fileMsg = (IMFileMsg *)self.msg;

	CGFloat width = kMsgCellFileBodyWidth;
	
	CGFloat nameWidth = width - kMsgCellUserBodyBackGroundHeadingWL - kMsgCellUserBodyBackGroundHeadingWR - kMsgBodyIconSize - kMsgCellPadding;
	CGSize namesize = [self.displayName sizeWithFont:_nameLabel.font constrainedToSize:CGSizeMake(nameWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGFloat height = namesize.height + kMsgCellUserBodySpace + kMsgCellUserBodyBackGroundHeadingH *2 + 11;
	
	if(fileMsg.fromType == IMMsgFromLocalSelf || fileMsg.fromType == IMMsgFromRemoteSelf)
	{
		_bodyBgView.frame = CGRectMake(self.userHeadView.left - kMsgCellUserBodyHeadSapce - width, self.userNameLabel.bottom+kMsgCellUserBodySpace, width, height);
		[_bodyBgView setBackgroundImage:kMsgCellChatBubbleGrayImage forState:UIControlStateNormal];
		_bodyIconView.top = kMsgCellUserBodyBackGroundHeadingH;
		_bodyIconView.left = kMsgCellUserBodyBackGroundHeadingWR;
			
		
	}
	else
	{
		_bodyBgView.frame = CGRectMake(self.userHeadView.right + kMsgCellUserBodyHeadSapce, self.userNameLabel.bottom+kMsgCellUserBodySpace, width, height);
		
		[_bodyBgView setBackgroundImage:kMsgCellChatBubbleGreenImage forState:UIControlStateNormal];
		
		_bodyIconView.top = kMsgCellUserBodyBackGroundHeadingH;
		_bodyIconView.left = kMsgCellUserBodyBackGroundHeadingWL;

	}
	
	_nameLabel.frame = CGRectMake(_bodyIconView.right + kMsgCellPadding, _bodyIconView.top, namesize.width, namesize.height);
	_nameLabel.text = self.displayName;
		

	if(self.msg.procState == IMMsgProcStateUnproc)
	{
		if (self.msg.fromType == IMMsgFromLocalSelf) {
			_optBtn.hidden = YES;
		}
		else
			_optBtn.hidden = NO;
		
		_progressBar.hidden = YES;
		NSString *str = [NSString stringWithFormat:@"文件大小 %@", [IMLiteUtil presentationalFileSizeWithSize:self.msg.msgSize]];
		_stateLabel.text = str;
		[_stateLabel sizeToFit];
		_stateLabel.left = _nameLabel.left;
		_stateLabel.top = _nameLabel.bottom + kMsgCellUserBodySpace;
		_stateLabel.textColor = UICOLOR_RGB(83, 83, 83);
		[_optBtn setBackgroundImage:[UIImage imageNamed:@"msg_btn_green.png"] forState:UIControlStateNormal];
		[_optBtn setTitle:NSLocalizedString(@"接收", nil) forState:UIControlStateNormal];
		[_optBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_optBtn setTitleShadowColor:UICOLOR_RGB(49, 93, 0) forState:UIControlStateNormal];
		_optBtn.titleLabel.shadowOffset = CGSizeMake(0, 1);
	}
	else if (self.msg.procState == IMMsgProcStateProcessing)
	{
		_progressBar.hidden = NO;
		_optBtn.hidden = NO;	
		NSString *str = NSLocalizedString(@"接收中", nil);
		if (self.msg.fromType == IMMsgFromLocalSelf)
		{
			str = NSLocalizedString(@"发送中", nil);
		}
		_stateLabel.text = str;
		[_stateLabel sizeToFit];
		_stateLabel.left = _nameLabel.left;
		_stateLabel.top = _nameLabel.bottom + kMsgCellUserBodySpace;
		_stateLabel.textColor = UICOLOR_RGB(83, 83, 83);
		
		_progressBar.progress = fileMsg.progress;
		_progressBar.left = _stateLabel.right + 5;
		_progressBar.top = (_stateLabel.height - _progressBar.height)/2 + _stateLabel.top;
		_progressBar.width = 110;
		
		[_optBtn setBackgroundImage:[UIImage imageNamed:@"msg_btn_gray.png"] forState:UIControlStateNormal];
		[_optBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
		[_optBtn setTitleColor:UICOLOR_RGB(164, 0, 0) forState:UIControlStateNormal];
		_optBtn.titleLabel.shadowOffset = CGSizeMake(0, 0);
	}
	else if (self.msg.procState == IMMsgProcStateFaied)
	{
		_progressBar.hidden = YES;
		_optBtn.hidden = NO;
		NSString *str =  NSLocalizedString(@"传输中断，请重试", nil);
		_stateLabel.text = str;
		[_stateLabel sizeToFit];
		_stateLabel.left = _nameLabel.left;
		_stateLabel.top = _nameLabel.bottom + kMsgCellUserBodySpace;
		_stateLabel.textColor = UICOLOR_RGB(164, 0, 0);
		
		[_optBtn setBackgroundImage:[UIImage imageNamed:@"msg_btn_gray.png"] forState:UIControlStateNormal];
		[_optBtn setTitle:NSLocalizedString(@"重试", nil) forState:UIControlStateNormal];
		[_optBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		_optBtn.titleLabel.shadowOffset = CGSizeMake(0, 0);
	
	}
	else if (self.msg.procState == IMMsgProcStateSuc)
	{
		_progressBar.hidden = YES;
		_optBtn.hidden = NO;
		NSString *str = [NSString stringWithFormat:@"文件大小 %@", [IMLiteUtil presentationalFileSizeWithSize:self.msg.msgSize]];
		_stateLabel.text = str;
		[_stateLabel sizeToFit];
		_stateLabel.left = _nameLabel.left;
		_stateLabel.top = _nameLabel.bottom + kMsgCellUserBodySpace;
		_stateLabel.textColor = UICOLOR_RGB(83, 83, 83);
		
		[_optBtn setBackgroundImage:[UIImage imageNamed:@"msg_btn_green.png"] forState:UIControlStateNormal];
		[_optBtn setTitle:NSLocalizedString(@"查看", nil) forState:UIControlStateNormal];
		[_optBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_optBtn.titleLabel.shadowOffset = CGSizeMake(0, 1);
	}
	
	
	_optBtn.top =_bodyBgView.top + (_bodyBgView.height - _optBtn.height)/2;
	if (self.msg.fromType == IMMsgFromLocalSelf || self.msg.fromType == IMMsgFromRemoteSelf)
	{
		_optBtn.right = _bodyBgView.left - 10;
	}
	else
	{
		_optBtn.left = _bodyBgView.right + 10;
	}
	
	self.contentView.height = _bodyBgView.bottom;
}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg
{
//	IMFileMsg *fileMsg = (IMFileMsg *)msg;
	CGFloat nameWidth = kMsgCellFileBodyWidth - kMsgCellUserBodyBackGroundHeadingWL - kMsgCellUserBodyBackGroundHeadingWR - kMsgBodyIconSize - kMsgCellPadding;
	NSString *disPlayName = [[((IMFileMsg *)msg) fileLocalPath] lastPathComponent];
	CGSize namesize = [disPlayName sizeWithFont:KMsgCellBodyTextFont constrainedToSize:CGSizeMake(nameWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGFloat userHeight = msg.fromUser.userType & IMUserTypeP2P?-2:16.0f;
	return kMsgCellTopPading + userHeight +namesize.height + kMsgCellUserBodySpace + kMsgCellUserBodyBackGroundHeadingH *2 + 12 + kMsgCellBottomPadding;
}

- (void)optFiles:(id)sender
{
//	PPLOG(@"%@", NSStringFromClass([self class]));
//	self.msg.procState = IMMsgProcStateProcessing;
//	IMFileMsg *fileMsg = (IMFileMsg *)self.msg;
	if (self.msg.procState == IMMsgProcStateProcessing)
	{
		self.msg.procState = IMMsgProcStateFaied;
//		[self.msg saveMsgState];
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
		[menu setTargetRect:_bodyBgView.frame inView: self];
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

@end
