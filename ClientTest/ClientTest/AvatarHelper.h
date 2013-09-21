//
//  AvatarHelper.h
//  IMLite
//
//  Created by pengjay on 13-7-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IMUser.h>
#import "UIImageView+WebCache.h"
@interface AvatarHelper : NSObject
+ (void)addAvatar:(IMUser *)user toImageView:(UIImageView *)imageView;
@end
