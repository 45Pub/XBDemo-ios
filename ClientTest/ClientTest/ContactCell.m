//
//  ContactCell.m
//  IMLite
//
//  Created by Ethan on 13-8-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ContactCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Public.h"
#import <IMContext.h>
#define LeftMargin 8.0
#define TopMargin 5.5

#define AvatarWidth 35.0
#define NameLabelWidth 200.0
#define NameLabelHeight 35.0

#define Avatar_Username_padding 5.0

@implementation ContactCell

- (void)dealloc {
    
    self.nameLabel = nil;
    self.avatarView = nil;
    self.checkBox = nil;
    Block_release(_accessoryActionBlock);

    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (self.showAvatarView) {
        self.nameLabel.frame = CGRectMake(LeftMargin + AvatarWidth + Avatar_Username_padding, TopMargin, self.frame.size.width-76, NameLabelHeight);
    } else {
        self.nameLabel.frame = CGRectMake(LeftMargin, TopMargin, self.frame.size.width-50, NameLabelHeight);
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(LeftMargin, TopMargin, self.frame.size.width-50, NameLabelHeight)];
//        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:13.0];
//        self.nameLabel.font = [UIFont boldSystemFontOfSize:14.5];
        self.nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self.contentView addSubview:self.nameLabel];
        
        self.checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.checkBox.bounds = CGRectMake(0, 0, 26.0, 26.0);
        self.checkBox.bounds = CGRectMake(0, 0, 40.0, 40.0);
        [self.checkBox setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        [self.checkBox setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
        [self.checkBox addTarget:self action:@selector(checkBoxClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.editingAccessoryView = self.checkBox;

    }
    return self;
}

- (void)checkBoxClicked:(id)sender
{
//    if (self.user.userID == [IMContext sharedContext].loginUser.userID) {
//        self.checkBox.selected = NO;
//        self.isChecked = NO;
//        return;
//    }
    
    self.checkBox.selected = !self.checkBox.selected;
    self.isChecked = self.checkBox.isSelected;
    
    if(self.accessoryActionBlock)
    {
        self.accessoryActionBlock(self.isChecked);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.stateMask == UITableViewCellStateEditingMask)
    {
        self.contentView.frame = self.contentView.bounds;
        //NSLog(@"%f,%f",self.editingAccessoryView.left,self.editingAccessoryView.top);
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    self.stateMask = state;
    
    [super willTransitionToState:state];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    self.checkBox.selected = isChecked;
}

- (void)setUser:(IMUser *)user {
    if(_user != nil)
    {
        [_user release];
        _user = nil;
    }
    _user = [user retain];
    self.nameLabel.text = _user.nickname;
    NSLog(@"%f", self.nameLabel.frame.size.width);
    if (self.showAvatarView) {
        [self setAvatarImage:user.avatarPath overWrite:self.overWrite];
    }
    if ([self.user.userID isEqualToString:[IMContext sharedContext].loginUser.userID]) {
        self.editingAccessoryView = nil;
    }
}

- (void)setShowAvatarView:(BOOL)showAvatarView {
    _showAvatarView = showAvatarView;
    if (self.showAvatarView) {
        if (!_avatarView) {
            _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(LeftMargin, TopMargin, AvatarWidth, AvatarWidth)];
            self.avatarView.layer.cornerRadius = 3.5;
            self.avatarView.layer.masksToBounds = YES;
            [self.contentView addSubview:self.avatarView];
            self.nameLabel.frame = CGRectMake(LeftMargin + AvatarWidth + Avatar_Username_padding, TopMargin, self.frame.size.width-76, NameLabelHeight);
        }
    } else {
        [self.avatarView removeFromSuperview];
        self.avatarView = nil;
        self.nameLabel.frame = CGRectMake(LeftMargin, TopMargin, self.frame.size.width-50, NameLabelHeight);
    }
}

- (void)setAvatarImage:(NSString *)imagePath overWrite:(BOOL)overWrite {
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDir] && !isDir) {
        self.avatarView.image = [UIImage imageWithContentsOfFile:imagePath];
    } else {
        NSString *path = [Public formatUrlPathToLocalAvatarSavePath:imagePath withUserId:self.user.userID];
        isDir = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
            self.avatarView.image = [UIImage imageWithContentsOfFile:path];
        } else {
            self.avatarView.image = [UIImage imageNamed:@"avatar_user"];
        }
    }

    __block typeof(self) weakSelf = self;
    dispatch_async([Public getAvatarDispatchQueue], ^{
        NSString * local = [Public urlImagePathToLocalImagePathAndSave:imagePath user:weakSelf.user overWrite:overWrite];
        weakSelf.user.avatarPath = local;
        weakSelf.avatarView.image = [Public imageOfUser:weakSelf.user];

    });
    
//    if(imagePath)
//    {
//        self.avatarView.image = [UIImage imageWithContentsOfFile:imagePath];
//    }
//    else if(!imagePath)
//    {
//        self.avatarView.image = [UIImage imageNamed:@"avatar_user"];
//    }

}

@end
