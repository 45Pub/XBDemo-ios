//
//  ContactUserCell.m
//  IMLite
//
//  Created by admins on 13-7-23.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ContactUserCell.h"

@implementation ContactUserCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_btn_info"]];
        self.showAvatarView = YES;
        
    }
    return self;
}

@end
