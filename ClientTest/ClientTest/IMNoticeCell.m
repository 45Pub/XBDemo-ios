//
//  IMNoticeCell.m
//  GoComIM
//
//  Created by 王鹏 on 13-5-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMNoticeCell.h"
#import "UIImage+PPCategory.h"
//#import "IMUtils.h"
#import "IMLiteUtil.h"
#import "UIView+PPCategory.h"
#define BODY_MAX 260

@implementation IMNoticeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UIImage *img = [[UIImage imageNamed:@"chat_time.png"] stretchableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
		
		_bgImageView = [[UIImageView alloc]initWithImage:img];
		_bgImageView.frame = CGRectMake(0, 15, 10, 4);
		
		_bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self.contentView addSubview:_bgImageView];
		[_bgImageView release];
		
		_timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10,5)];
		_timeLabel.backgroundColor = [UIColor clearColor];
//		_timeLabel.textAlignment = UITextAlignmentCenter;
		_timeLabel.textColor = [UIColor whiteColor];
		_timeLabel.font = [UIFont systemFontOfSize:12.0f];
		_timeLabel.numberOfLines = 0;
		_timeLabel.lineBreakMode = UILineBreakModeWordWrap;
		
		[self.contentView addSubview:_timeLabel];
		[_timeLabel release];
    }
    return self;
}

- (void)dealloc
{
	[_msg release];
	[super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (_msg == nil)
	{
		return;
	}
	
	CGSize size = [_msg.msgBody sizeWithFont:_timeLabel.font constrainedToSize:CGSizeMake(BODY_MAX, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
	
	_timeLabel.frame = CGRectMake((self.width - size.width)/2, 6, size.width, size.height);
	_timeLabel.text = _msg.msgBody;

	_bgImageView.width = _timeLabel.width + 10;
	_bgImageView.height = _timeLabel.height + 4;

	_bgImageView.top = _timeLabel.top - 2;
	_bgImageView.left = _timeLabel.left - 5;

}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg
{
	CGSize size = [msg.msgBody sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(BODY_MAX, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
	return size.height + 14;
}

@end