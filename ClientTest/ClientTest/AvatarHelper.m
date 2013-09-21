//
//  AvatarHelper.m
//  IMLite
//
//  Created by pengjay on 13-7-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "AvatarHelper.h"

@implementation AvatarHelper
+ (void)addAvatar:(IMUser *)user toImageView:(UIImageView *)imageView
{
	if (user.userType & IMUserTypeDiscuss) {
		imageView.image = [UIImage imageNamed:@"avatar_discussion"];
	} else if (user.userType & IMUserTypeFriendCenter) {
		imageView.image = [UIImage imageNamed:@"avatar_request"];
	} else {
		
		if (user.avatarPath.length <= 0)
			imageView.image = [UIImage imageNamed:@"avatar_user"];
		else {
            if ([[NSFileManager defaultManager] fileExistsAtPath:user.avatarPath]) {
                [imageView setImage:[UIImage imageWithContentsOfFile:user.avatarPath]];
            } else {
                [imageView setImageWithURL:[NSURL URLWithString:user.avatarPath]
                          placeholderImage:[UIImage imageNamed:@"avatar_user"]];
            }
        }
	}

}
@end
