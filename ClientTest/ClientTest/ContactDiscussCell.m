//
//  ContactDeptCell.m
//  IMLite
//
//  Created by Ethan on 13-8-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ContactDiscussCell.h"

@implementation ContactDiscussCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.editingAccessoryView = nil;
        self.showAvatarView = NO;
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_btn_info"]];
    }
    return self;
}

@end
