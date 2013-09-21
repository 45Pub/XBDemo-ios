//
//  IMFileDownLoadManager.h
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMFileDownloader.h"

typedef NS_ENUM(NSInteger, MSGDOWNTYPE)
{
	MSGDOWNTYPEFORCELL = 0,
	MSGDOWNTYPEORIGIN,
};

@class IMMsg;
@class IMMsgCacheManager;
@class IMMsgStorage;
typedef void(^IMFileDownloadBlock) (BOOL suc, NSError *error);
@interface IMFileDownLoadManager : NSObject <IMFileDownloaderDelegate>
{
	IMMsgCacheManager *_msgMgr;
	IMMsgStorage *_msgStorage;
	NSMutableDictionary *_downloaderUrlForMsg;
	NSMutableArray *_downloaders;
	NSMutableArray *_downloadInfo;
	NSMutableDictionary *_msgidTypeForMsg;
}

- (void)downloadIMMsg:(IMMsg *)msg downloadType:(MSGDOWNTYPE )type block:(IMFileDownloadBlock)block;
@end
