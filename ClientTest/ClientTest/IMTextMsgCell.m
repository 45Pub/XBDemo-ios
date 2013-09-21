//
//  IMTextMsgCell.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMTextMsgCell.h"
#import "UIView+PPCategory.h"
#import "NSString+PPCategory.h"
#import "NSAttributedString+Attributes.h"
@implementation IMTextMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		self.textBgBtnView = [IMBgButton buttonWithType:UIButtonTypeCustom];
		[_textBgBtnView addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_textBgBtnView];
		
		UILongPressGestureRecognizer *lpg = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpress:)];
		lpg.cancelsTouchesInView = YES;
		[_textBgBtnView addGestureRecognizer:lpg];
		[lpg release];
		
		_textView = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
		_textView.userInteractionEnabled = NO;
		_textView.backgroundColor = [UIColor clearColor];
		_textView.font = KMsgCellBodyTextFont;
		_textView.textColor = kMsgCellBodyTextColor;
		_textView.lineBreakMode = NSLineBreakByWordWrapping;
		_textView.numberOfLines = 0;
//		_textView.leading = 14.0f;
//		_textView.firstLineIndent = 14.0f;
//		_textView.dataDetectorTypes = UIDataDetectorTypeLink|UIDataDetectorTypePhoneNumber;
		_textView.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
//		_textView.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
//		
//		NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
//		[mutableActiveLinkAttributes setValue:(id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
//		[mutableActiveLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
//		[mutableActiveLinkAttributes setValue:(id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
//		[mutableActiveLinkAttributes setValue:(id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f] CGColor] forKey:(NSString *)kTTTBackgroundStrokeColorAttributeName];
//		[mutableActiveLinkAttributes setValue:(id)[NSNumber numberWithFloat:1.0f] forKey:(NSString *)kTTTBackgroundLineWidthAttributeName];
//		[mutableActiveLinkAttributes setValue:(id)[NSNumber numberWithFloat:5.0f] forKey:(NSString *)kTTTBackgroundCornerRadiusAttributeName];
//		_textView.activeLinkAttributes = mutableActiveLinkAttributes;
		
		
		_textView.highlightedTextColor = [UIColor whiteColor];
//		_textView.shadowColor = [UIColor colorWithWhite:0.87 alpha:1.0];
//		_textView.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_textView.delegate = self;
		[_textBgBtnView addSubview:_textView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
	[_textView setText:@" "];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
//	if(![self.msg isKindOfClass:[IMTextMsg class]])
//		return;
	
	
	IMMsg *textMsg = self.msg;
	[_textView setText:textMsg.msgBody];
	
	
	CGSize size = [_textView.attributedText sizeConstrainedToSize:CGSizeMake(kMsgCellBodyMaxWidth-kMsgCellUserBodyBackGroundHeadingWL-kMsgCellUserBodyBackGroundHeadingWR, CGFLOAT_MAX)];

	if(textMsg.fromType == IMMsgFromLocalSelf || textMsg.fromType == IMMsgFromRemoteSelf)
	{
		_textBgBtnView.frame = CGRectMake(self.userHeadView.left - kMsgCellUserBodyHeadSapce -(size.width+kMsgCellUserBodyBackGroundHeadingWL+kMsgCellUserBodyBackGroundHeadingWR), self.userNameLabel.bottom + kMsgCellUserBodySpace,
										 size.width+kMsgCellUserBodyBackGroundHeadingWR+kMsgCellUserBodyBackGroundHeadingWL, size.height+kMsgCellUserBodyBackGroundHeadingH*2);
	
		[_textBgBtnView setBackgroundImage:kMsgCellChatBubbleGrayImage forState:UIControlStateNormal];
		
		_textView.frame = CGRectMake(kMsgCellUserBodyBackGroundHeadingWR, kMsgCellUserBodyBackGroundHeadingH, size.width, size.height+20);
		self.errorView.frame = CGRectMake(self.textBgBtnView.left - self.errorView.width - kMsgCellPadding, self.textBgBtnView.top + (self.textBgBtnView.height - self.errorView.height)/2, self.errorView.width, self.errorView.height);
	}
	else
	{
		_textBgBtnView.frame = CGRectMake(self.userHeadView.right + kMsgCellUserBodyHeadSapce, self.userNameLabel.bottom + kMsgCellUserBodySpace,
										  size.width+kMsgCellUserBodyBackGroundHeadingWL+kMsgCellUserBodyBackGroundHeadingWR, size.height+kMsgCellUserBodyBackGroundHeadingH*2);
		

			[_textBgBtnView setBackgroundImage:kMsgCellChatBubbleGreenImage forState:UIControlStateNormal];

		
		_textView.frame = CGRectMake(kMsgCellUserBodyBackGroundHeadingWL, kMsgCellUserBodyBackGroundHeadingH, size.width, size.height+20);
		self.errorView.frame = CGRectMake(self.textBgBtnView.right + kMsgCellPadding, self.textBgBtnView.top + (self.textBgBtnView.height - self.errorView.height)/2, self.errorView.width, self.errorView.height);
	}
//	_textView.frame = CGRectInset(_textBgBtnView.bounds, kMsgCellUserBodyBackGroundHeading, kMsgCellUserBodyBackGroundHeading);
	if (self.msg.procState == IMMsgProcStateFaied)
	{
		self.errorView.hidden = NO;
	}
	else
	{
		self.errorView.hidden = YES;
	}
	self.contentView.height = _textBgBtnView.bottom + kMsgCellBottomPadding;
	self.height = _textBgBtnView.bottom + kMsgCellBottomPadding;
	
}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg
{
	TTTAttributedLabel *textView = [[[TTTAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
	textView.backgroundColor = [UIColor clearColor];
	textView.font = KMsgCellBodyTextFont;
	textView.textColor = kMsgCellBodyTextColor;
	textView.lineBreakMode = NSLineBreakByWordWrapping;
	textView.numberOfLines = 0;
	[textView setText:msg.msgBody];
	
	CGSize size = [textView.attributedText sizeConstrainedToSize:CGSizeMake(kMsgCellBodyMaxWidth-kMsgCellUserBodyBackGroundHeadingWL-kMsgCellUserBodyBackGroundHeadingWR, CGFLOAT_MAX)];
	CGFloat bodyHeight = size.height; //[msg.msgBody heightWithFont:KMsgCellBodyTextFont constrainedToWidth:kMsgCellBodyMaxWidth-kMsgCellUserBodyBackGroundHeadingWL-kMsgCellUserBodyBackGroundHeadingWR lineBreakMode:NSLineBreakByWordWrapping];
	if (bodyHeight < kMsgCellAudioCellHeiht - kMsgCellUserBodyBackGroundHeadingH*2)
		bodyHeight = kMsgCellAudioCellHeiht - kMsgCellUserBodyBackGroundHeadingH*2;
	CGFloat userHeight = msg.fromUser.userType&IMUserTypeP2P?-2:16.0f;
	return kMsgCellTopPading + userHeight + kMsgCellUserBodySpace + bodyHeight + kMsgCellUserBodyBackGroundHeadingH*2 + kMsgCellBottomPadding;

}

- (void)cellClick:(id)sender
{
//	NSLog(@"btnClcik");
	[self cellBodyClick:sender];
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
//		UIMenuItem *item1 = [[[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(copy:)] autorelease];
//		UIMenuItem *item2 = [[[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(forward:)] autorelease];
//		UIMenuItem *item3 = [[[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(copy:)] autorelease];
		
		UIMenuController * menu = [UIMenuController sharedMenuController];
//		[menu setMenuItems:@[item2]];
		[menu setTargetRect:_textBgBtnView.frame inView: self];
		[menu setMenuVisible: YES animated: YES];
	}
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSLog(@"%@", url);
}

- (void)dealloc
{
	[_textView release];
	[_textBgBtnView release];
	[super dealloc];
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
        return YES;
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
    else if(action == @selector(forward:)){
        return YES;
    }
    else
    {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)copy:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.msg.msgBody];
}

- (void)forward:(id)sender
{
	PPLOG(@"forwar !");
}

@end
