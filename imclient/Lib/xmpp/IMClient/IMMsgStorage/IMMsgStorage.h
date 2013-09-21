//
//  IMMsgStorage.h
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import <Foundation/Foundation.h>
#import "IMMsgStorageProtocol.h"
@class FMDatabaseQueue;
@class IMUserManager;
@class IMMsgCacheManager;

@interface IMMsgStorage : NSObject <IMMsgStorageProtocol>
{
	FMDatabaseQueue	*_dbQueue;
	IMUserManager *_userMgr;
	IMMsgCacheManager *_msgMgr;
}
- (id)initWithdbQueue:(FMDatabaseQueue *)dbQueue userManager:(IMUserManager *)userMgr
		   msgManager:(IMMsgCacheManager *)msgMgr;
@end
