//
//  UserAvatarCache.h
//  GoComIM
//
//  Created by 王鹏 on 13-6-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAvatarCache : NSObject
- (UIImage *)cacheImageWithPath:(NSString *)path;
+ (UserAvatarCache *)sharedUserAvatarCache;
@end
