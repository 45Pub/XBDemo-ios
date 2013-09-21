//
//  ContactDepartmentCell.m
//  IMLite
//
//  Created by admins on 13-7-23.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ContactDepartmentCell.h"
#import "UIView+PPCategory.h"

@implementation ContactDepartmentCell

- (void)dealloc
{
    [_stateView release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.avatarView removeFromSuperview];
        self.isOpen = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:13.0];
        
        UIImage *backImage = [[UIImage imageNamed:@"contacts_department_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)];
        self.backgroundView = [[[UIImageView alloc] initWithImage:backImage] autorelease];
        
        _stateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19.0, 19.0)];
        self.stateView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.stateView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.isOpen)
    {
        self.stateView.image = [UIImage imageNamed:@"contacts_department_1"];
    }
    else
    {
        self.stateView.image = [UIImage imageNamed:@"contacts_department_2"];
    }
    
    self.stateView.left = LeftMargin;
    self.stateView.top = (self.contentView.height - self.stateView.height) / 2;
    
    self.nameLabel.left = self.stateView.right + Avatar_Username_padding;
    self.nameLabel.top = (self.contentView.height - self.nameLabel.height) / 2;
    
    if(self.stateMask == UITableViewCellStateEditingMask)
    {
        self.editingAccessoryView.left = 284.0;
    }
}

- (void)setIsOpen:(BOOL)isOpen
{
    if(_isOpen == isOpen)
        return;
    
    _isOpen = isOpen;
    
    [UIView animateWithDuration:0.2 animations:^{
        if(_isOpen)
        {
            self.stateView.image = [UIImage imageNamed:@"contacts_department_1"];
        }
        else
        {
            self.stateView.image = [UIImage imageNamed:@"contacts_department_2"];
        }
    }];
}

- (void)setUserName:(NSString *)userName
{
    if(_userName != nil)
    {
        [_userName release];
        _userName = nil;
    }
    _userName = [userName retain];
    self.nameLabel.text = _userName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

























