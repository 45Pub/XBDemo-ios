//
//  ContactCell.h
//  IMLite
//
//  Created by Ethan on 13-8-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IMUser.h>

@interface ContactCell : UITableViewCell

@property (nonatomic, retain) UIImageView *avatarView;

@property (nonatomic, retain) UILabel *nameLabel;

@property (nonatomic, retain) UIButton *checkBox;

@property (nonatomic, retain) IMUser *user;

@property (nonatomic, assign) BOOL showAvatarView;

@property (nonatomic, assign) BOOL isChecked;

@property (nonatomic, assign) BOOL overWrite;

@property (nonatomic, copy) void (^accessoryActionBlock)(BOOL);

@property (nonatomic, assign)UITableViewCellStateMask stateMask;

@end
