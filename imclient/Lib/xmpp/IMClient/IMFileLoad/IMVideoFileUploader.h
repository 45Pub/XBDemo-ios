//
//  IMVideoFileUploader.h
//  IMClient
//
//  Created by pengjay on 13-7-23.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFileUploader.h"
@class IMVideoMsg;
@interface IMVideoFileUploader : IMFileUploader
{
	NSInteger sendBytes;
	NSURL *thubmailPostURL;
	NSString *thumbType;
	NSString *originType;
	NSString *originPath;
	ASIFormDataRequest *videoReuest;
	NSMutableDictionary *respDic;
}
- (void)uploadVideoMsg:(IMVideoMsg *)msg;

@end
