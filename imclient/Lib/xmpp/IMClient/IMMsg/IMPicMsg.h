//
//  IMPicMsg.h
//  IMClient
//
//  Created by pengjay on 13-7-15.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFileMsg.h"

@interface IMPicMsg : IMFileMsg
{
	NSString *_originFilePath;
}

- (NSString *)originFileLocalPath;
- (NSString *)originFileRemoteUrl;
- (NSUInteger)originFileSize;
- (void)setOriginFileRemoteURL:(NSString *)originRemtoeURL;
- (void)setFileRemoteURL:(NSString *)remoteURL;
@end
