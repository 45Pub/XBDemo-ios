//
//  GOContactCell.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOContactCell.h"
#import "UIButton+PPCategory.h"
#import "UIView+PPCategory.h"
#import <QuartzCore/QuartzCore.h>
#import <IMUser.h> 
#import "UIImageView+WebCache.h"
#import "AvatarHelper.h"

@interface GOContactCell ()
@property (nonatomic, retain) UIButton *accessoryButton;
@end

@implementation GOContactCell

- (void)dealloc
{
	if (_imUser) {
//		[_imUser removeObserver:self forKeyPath:@"changeFlag"];
	}
	
	[_imUser release];
	_imUser = nil;
    Block_release(_accessoryActionBlock);
    [_accessoryButton release];
    
    [super dealloc];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithCheckBoxPosition:GOMultiSelectCellCheckBoxPositionRight reuseIdentifier:reuseIdentifier]) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"list_bg_124"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 20.0, 0.0, 0.0)];
		self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:14.5];
        
        self.accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.accessoryButton setImage:[UIImage imageNamed:@"list_btn_info"] forState:UIControlStateNormal];
        [self.accessoryButton addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        self.accessoryButton.bounds = CGRectMake(0.0, 0.0, 44.0, 40.0);
        
        self.accessoryView = self.accessoryButton;
        
		self.imageView.layer.cornerRadius = 3.0f;
		self.imageView.layer.masksToBounds = YES;
        
        self.canMultiSelected = YES;
    }
    
    return self;
}

- (void)accessoryButtonTapped:(UIButton *)sender
{
    if (self.accessoryActionBlock) {
        self.accessoryActionBlock(self);
    }
}

- (void)setThumbnail:(UIImage *)thumbnail name:(NSString *)nameString
{
    self.textLabel.text = nameString;
    self.imageView.image = thumbnail;
    self.accessoryButton.bounds = CGRectMake(0.0, 0.0, 44.0, 40.0);
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	if (_imUser) {
		[AvatarHelper addAvatar:_imUser toImageView:self.imageView];
		self.textLabel.text = self.imUser.nickname;
	}

//    if (self.isEditing) {
//        self.imageView.frame = CGRectMake(40, 8, 35, 35);
//    } else {
        self.imageView.frame = CGRectMake(8, 8, 35, 35);
//    }

	self.textLabel.left = self.imageView.right + 8;
//	
//	if (self.imUser.userType == IMUserTypeP2P && self.showDepart == YES)
//	{
//		[self.textLabel sizeToFit];
//		self.textLabel.top = self.imageView.top;
////		if (_departLabel == nil)
////		{
////			_departLabel = [[UILabel alloc]initWithFrame:CGRectZero];
////			_departLabel.font = [UIFont systemFontOfSize:12.0f];
////			_departLabel.backgroundColor = [UIColor clearColor];
////			_departLabel.textColor = [UIColor grayColor];
////			[self.contentView addSubview:_departLabel];
////			[_departLabel release];
////		}
////		_departLabel.text = [self.imUser departAndDutyString];
////		[_departLabel sizeToFit];
////		_departLabel.left = self.imageView.right + 8;
////		_departLabel.top = self.textLabel.bottom + 2;
//	}
//	else
//	{
		[self.textLabel sizeToFit];
    self.textLabel.width = 200.0;
		self.textLabel.top = self.imageView.top + (self.imageView.height - self.textLabel.height)/2;
//		_departLabel.text = nil;
//	}
    self.accessoryView.left = 245;
    self.editingAccessoryView.left = 265.0;
    
    if (self.imUser.userType == IMUserTypeDiscuss || !self.canMultiSelected) {
        [self disableEditingAccessoryView];
    } else {
        [self enableEditingAccerroryView];
    }
}


#pragma mark - Observe User avatar chagne

- (void)setImUser:(IMUser *)imUser
{
	if (_imUser == imUser) 
		return;
	
	if (_imUser) {
//		[_imUser removeObserver:self forKeyPath:@"changeFlag"];
		[_imUser release];
		_imUser = nil;
	}

	_imUser = [imUser retain];
//	[_imUser addObserver:self forKeyPath:@"changeFlag" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
	[self setNeedsLayout];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"changeFlag"])
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

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
}

@end
