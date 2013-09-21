//
//  UserAvatarCache.m
//  GoComIM
//
//  Created by 王鹏 on 13-6-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "UserAvatarCache.h"
#import "NSString+PPCategory.h"
@interface UserAvatarCache()
@property (nonatomic, retain) NSCache *imageCache;
@end

@implementation UserAvatarCache

+ (UserAvatarCache *)sharedUserAvatarCache
{
    static dispatch_once_t once;
    static UserAvatarCache *__singleton__;
    dispatch_once(&once, ^ { __singleton__ = [[[self class] alloc] init]; });
    return __singleton__;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.imageCache = [[[NSCache alloc]init] autorelease];
		[self.imageCache setCountLimit:50];
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_imageCache release];
	_imageCache = nil;
	[super dealloc];
}

- (void)clearMemory
{
	[self.imageCache removeAllObjects];
}

- (UIImage *)cacheImageWithPath:(NSString *)path
{
	NSString *key = [path md5Hash];
	UIImage *img = [self.imageCache objectForKey:key];
	if (!img)
	{
		img = [UIImage imageWithContentsOfFile:path];
		if (img)
		{
			[self.imageCache setObject:img forKey:key];
		}
//		else
//		{
//			img = [UIImage imageNamed:@"avatar_user"];
//		}
	}
	return img;
}
@end
