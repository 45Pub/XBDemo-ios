//
//  IMUserManager.h
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import <Foundation/Foundation.h>
#import "IMUser.h"
#import "XMPPvCardTemp.h"
@class IMBaseClient;
@interface IMUserManager : NSObject
@property (nonatomic, strong) NSCache *userCache;
@property (nonatomic, readonly, weak) IMBaseClient *client;

- (id)initWithClient:(IMBaseClient *)client;

- (IMUser *)createCacheUserWithID:(NSString *)userID usertype:(IMUserType)type;

- (IMUser *)createCacheUserWithID:(NSString *)userID usertype:(IMUserType)type nikename:(NSString *)nickName;

- (IMUser *)createCacheUserWithID:(NSString *)userID usertype:(IMUserType)type nikename:(NSString *)nickName
						   avatar:(NSString *)avatarURL;

- (void)updateCacheUserWithvCard:(XMPPvCardTemp *)vCard;

- (void)updateCacheUser:(NSString *)userID userType:(IMUserType)userType nickName:(NSString *)nickName
				 avatar:(NSString *)avatarURL;
@end
