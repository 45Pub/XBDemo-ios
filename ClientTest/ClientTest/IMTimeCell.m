//
//  IMTimeCell.m
//  DoctorChat
//
//  Created by 王鹏 on 13-3-5.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMTimeCell.h"
#import "UIImage+PPCategory.h"
#import "IMLiteUtil.h"
#import "UIView+PPCategory.h"
@implementation IMTimeCell

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
		_timeLabel.textAlignment = UITextAlignmentCenter;
		_timeLabel.textColor = [UIColor whiteColor];
		_timeLabel.font = [UIFont systemFontOfSize:12.0f];
		
		[_bgImageView addSubview:_timeLabel];
		[_timeLabel release];
    }
    return self;
}

- (void)setMsgTime:(NSDate *)msgTime
{
	if(_msgTime != msgTime)
	{
		[_msgTime release];
		_msgTime = [msgTime retain];
	}
	[self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	NSString *timestr = [IMLiteUtil getChatTimeLabelWithDate:_msgTime];
//	CGSize size = [timestr sizeWithFont:[UIFont systemFontOfSize:12]];
//	_bgImageView.frame = CGRectMake(0, 15, size.width+10, size.height+4);
//	_bgImageView.center = CGPointMake(320/2, (size.height+4)/2 + 4);
	

	_timeLabel.text = timestr;
	[_timeLabel sizeToFit];
	_bgImageView.width = _timeLabel.width + 10;
	_bgImageView.height = _timeLabel.height + 4;
	_bgImageView.top = 13;
	_bgImageView.left = (self.width -  _bgImageView.width)/2;
	_timeLabel.centerX = _bgImageView.width/2;
	_timeLabel.centerY = _bgImageView.height/2;

}
@end
