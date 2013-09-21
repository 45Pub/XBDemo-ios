//
//  GOMessageCell.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-27.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOMessageCell.h"
#import "PPCore.h"
#import "PPBadgeView.h"
#import <IMUser.h>
#import "UIView+PPCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "AvatarHelper.h"

#define THUMBNAIL_ORIGIN_X 4.0
#define THUMBNAIL_WIDTH 45.0

#define TIME_WIDTH 40.0

#define OFFSET_X 4.0
#define OFFSET_Y 2.0

@interface GOMessageCell ()

@property (nonatomic, retain) UIImageView *thumbnailView;

@property (nonatomic, retain) UILabel *sourceLabel;

@property (nonatomic, retain) UILabel *subtitleLabel;

@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, retain) PPBadgeView *badgeView;

@property (nonatomic, retain) IMUser *imUser;

@end

@implementation GOMessageCell

- (void)dealloc
{
	if (self.imUser)
	{
//		[self.imUser removeObserver:self forKeyPath:@"changeFlag"];
		[_imUser release];
		_imUser = nil;
	}
    PP_RELEASE(_thumbnailView);
    PP_RELEASE(_sourceLabel);
    PP_RELEASE(_subtitleLabel);
    PP_RELEASE(_timeLabel);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//		UIImage *image = [[UIImage imageNamed:@"list_bg_124.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
//		self.backgroundView = [[[UIImageView alloc]initWithImage:image] autorelease];
	
        _thumbnailView = [[UIImageView alloc] init];
        self.thumbnailView.frame = CGRectMake(8.0, 8.0, THUMBNAIL_WIDTH, THUMBNAIL_WIDTH);
        self.thumbnailView.layer.masksToBounds = YES;
		self.thumbnailView.layer.cornerRadius = 3.0;
        
        _sourceLabel = [[UILabel alloc] init];
        self.sourceLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.sourceLabel.textColor = [UIColor blackColor];
        self.sourceLabel.backgroundColor = [UIColor clearColor];
        
        _subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.font = [UIFont systemFontOfSize:13.0];
        self.subtitleLabel.textColor = [UIColor lightGrayColor];
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        
        _timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont systemFontOfSize:13.5];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:self.thumbnailView];
        [self.contentView addSubview:self.sourceLabel];
        [self.contentView addSubview:self.subtitleLabel];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)setNeedsShowBadgeView
{
    if (self.badgeView == nil) {
        _badgeView = [[PPBadgeView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
        self.badgeView.userInteractionEnabled = NO;
        self.badgeView.badgeColor = [UIColor redColor];
        [self.contentView addSubview:_badgeView];
		
    }
}

- (void)setCellInfoWithFromUser:(IMUser *)fromUser
                    unreadCount:(NSUInteger)unreadCount
                      msgSource:(NSString *)source
                       subtitle:(NSString *)subtitle
                           time:(NSString *)time
{
//	if (self.imUser)
//	{
//		[self.imUser removeObserver:self forKeyPath:@"changeFlag"];
//	}
	self.imUser = fromUser;
//	[self.imUser addObserver:self forKeyPath:@"changeFlag" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
	
//    self.thumbnailView.image = [[UserAvatarCache sharedUserAvatarCache] cacheImageWithPath:[self.imUser avatarPath]];
	[AvatarHelper addAvatar:_imUser toImageView:_thumbnailView];
    self.sourceLabel.text = self.imUser.nickname;
	[self.sourceLabel sizeToFit];
	self.sourceLabel.left = self.thumbnailView.right + 8;
	self.sourceLabel.top = 14;
	if (self.sourceLabel.width > 200)
	{
		self.sourceLabel.width = 200;
	}
	
    self.subtitleLabel.text = subtitle;
	[self.subtitleLabel sizeToFit];
	self.subtitleLabel.left = self.thumbnailView.right + 8;
	self.subtitleLabel.top = self.sourceLabel.bottom + 5;
	if (self.subtitleLabel.width > (self.contentView.width - self.subtitleLabel.left - 48))
	{
		self.subtitleLabel.width = self.contentView.width - self.subtitleLabel.left - 48;
	}
	
    self.timeLabel.text = time;
	[self.timeLabel sizeToFit];
	self.timeLabel.top = 14;
	self.timeLabel.right = self.width - 8;
    
    if (unreadCount > 0) {
        [self setNeedsShowBadgeView];
        [self.badgeView setBadgeString:[NSString stringWithFormat:@"%d", unreadCount]];
		self.badgeView.top = 4;
		self.badgeView.right = self.thumbnailView.right + 6;
    }
    else if (self.badgeView) {
        [self.badgeView removeFromSuperview];
        self.badgeView = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//	if ([keyPath isEqualToString:@"changeFlag"])
//	{
//		dispatch_async(dispatch_get_main_queue(), ^{
//		    self.thumbnailView.image = [[UserAvatarCache sharedUserAvatarCache] cacheImageWithPath:[self.imUser avatarPath]];
//			self.sourceLabel.text = self.imUser.nickName;
//			[self.sourceLabel sizeToFit];
//			if (self.sourceLabel.width > 200)
//			{
//				self.sourceLabel.width = 200;
//			}
//			self.subtitleLabel.top = self.sourceLabel.bottom + 5;
//		});
//	}
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
	if (self.isEditing)
	{
		self.timeLabel.hidden = YES;
		
	}
	else
	{
		self.timeLabel.hidden = NO;
		
	}
//    self.thumbnailView.center = CGPointMake(THUMBNAIL_ORIGIN_X + 0.5 * THUMBNAIL_WIDTH, CGRectGetHeight(self.bounds) / 2.0);
//    self.sourceLabel.frame = CGRectMake(self.thumbnailView.frame.origin.x + self.thumbnailView.frame.size.width + OFFSET_X, 8.0, 200.0, 20.0);
//    self.subtitleLabel.frame = CGRectMake(self.sourceLabel.frame.origin.x, self.sourceLabel.frame.origin.y + CGRectGetHeight(self.sourceLabel.frame) + OFFSET_Y, CGRectGetWidth(self.sourceLabel.frame), CGRectGetHeight(self.sourceLabel.frame));
//    self.timeLabel.frame = CGRectMake(316 - TIME_WIDTH, 10.0, TIME_WIDTH, 20.0);
//    
//    if (self.badgeView != nil) {
////        self.badgeView.frame = CGRectMake(CGRectGetWidth(self.thumbnailView.bounds) - CGRectGetWidth(self.badgeView.bounds) - 1.0, 1.0, CGRectGetWidth(self.badgeView.bounds), CGRectGetHeight(self.badgeView.bounds));
//        self.badgeView.center = CGPointMake(CGRectGetWidth(self.thumbnailView.bounds) - 3.0, 2.0);
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
