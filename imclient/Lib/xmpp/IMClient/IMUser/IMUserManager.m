//
//  IMUserManager.m
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import "IMUserManager.h"
#import "IMUser.h"
#import "NSData+XMPP.h"
#import "IMBaseClient.h"
@implementation IMUserManager

//+ (IMUserManager *)sharedIMUserMgr
//{
//	static dispatch_once_t once;
//    static IMUserManager *__singleton__;
//    dispatch_once(&once, ^ { __singleton__ = [[[self class] alloc] init]; });
//    return __singleton__;
//}

- (id)initWithClient:(IMBaseClient *)client
{
	self = [super init];
	if (self)
	{
		_userCache = [[NSCache alloc]init];
		[_userCache setCountLimit:200];
		
		_client = client;
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
}

- (void)clearMemory
{
	[_userCache removeAllObjects];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IMUser *)createCacheUserWithID:(NSString *)userID usertype:(IMUserType)type
{
	return [self createCacheUserWithID:userID usertype:type nikename:nil];
}

- (IMUser *)createCacheUserWithID:(NSString *)userID usertype:(IMUserType)type nikename:(NSString *)nickName
{
	return [self createCacheUserWithID:userID usertype:type nikename:nickName avatar:nil];
}

- (IMUser *)createCacheUserWithID:(NSString *)userID usertype:(IMUserType)type nikename:(NSString *)nickName
						   avatar:(NSString *)avatarURL
{
	if (userID == nil)
		return nil;
	
	//create hash key with 'type' and 'userid'
	NSString *key = [NSString stringWithFormat:@"%@", userID];
	key = [[key dataUsingEncoding:NSUTF8StringEncoding] md5HashStr];
	IMUser *user = [self.userCache objectForKey:key];
	if (user == nil) {
		user = [[IMUser alloc]init];
		user.userID = userID;
		user.userType = type;
		
		//read nickname and avatarURL from vcard
		if ((nickName == nil || avatarURL == nil) && type == IMUserTypeP2P) {
			XMPPvCardTemp *temp = [self.client.xmppvCardTempModule vCardTempForJID:[XMPPJID jidWithString:userID]
																	   shouldFetch:YES];
			if (temp) {
				if (nickName.length <= 0) {
					nickName = temp.nickname;
				}
				
				if (avatarURL.length <= 0) {
					avatarURL = temp.description;
				}
			}
		}
		
		user.nickname = nickName;
        //TODO
		user.avatarPath = avatarURL;
		
		[self.userCache setObject:user forKey:key];
	}
	else {
		//update from new nickname and avatarURL
		if (nickName.length > 0) {
			user.nickname = nickName;
		}
		
		if (avatarURL.length > 0) {
			user.avatarPath = avatarURL;
		}
	}
	return user;
}

- (void)updateCacheUserWithvCard:(XMPPvCardTemp *)vCard
{
	NSString *userID = [[vCard jid] bare];
	NSString *key = [NSString stringWithFormat:@"%@", userID];
	key = [[key dataUsingEncoding:NSUTF8StringEncoding] md5HashStr];
	IMUser *user = [self.userCache objectForKey:key];
#warning vcard update
	if (user) {
		if ([vCard nickname].length <= 0 && user.nickname.length <= 0) {
			user.nickname = userID;
		} else if (user.nickname.length <= 0)
			user.nickname = [vCard nickname];
		user.avatarPath = [vCard description];
	}
	return;
}

- (void)updateCacheUser:(NSString *)userID userType:(IMUserType)userType nickName:(NSString *)nickName
				 avatar:(NSString *)avatarURL
{
	if (userID == nil) {
		return;
	}
	
	NSString *key = [NSString stringWithFormat:@"%@", userID];
	key = [[key dataUsingEncoding:NSUTF8StringEncoding] md5HashStr];
	IMUser *user = [self.userCache objectForKey:key];
	
	if (user) {
		if (nickName) {
			user.nickname = nickName;
		}
		
		if (avatarURL) {
			user.avatarPath = avatarURL;
		}
	}
	
	return;
}
@end
