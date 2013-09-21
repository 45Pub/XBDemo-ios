//
//  XMPPXBPrivacy.h
//  IMClient
//
//  Created by pengjay on 13-7-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "XMPPModule.h"
typedef NS_ENUM(NSInteger, FriendAuthType)
{
	FriendAuthTypeNone = 0,
	FriendAuthTypeAuth,
	FriendAuthTypeDeny,
};

@interface XMPPXBPrivacy : XMPPModule
{
	NSMutableArray *_blackArray;
}
@property (nonatomic) BOOL autoFetchBlackList;
@property (nonatomic, readonly) NSArray *blackArray;
@property (nonatomic) FriendAuthType mAuthType;
- (void)setFriendAuthType:(FriendAuthType)type;
- (void)addBlackList:(NSArray *)array;
- (void)removeBlackList:(NSArray *)array;
@end



@protocol XMPPXBPrivacyDelegate <NSObject>

- (void)xmppXBPrivacy:(XMPPXBPrivacy *)sender
  didReceiveBlackList:(NSMutableArray *)list
		   authType:(FriendAuthType)authAtype;

@optional

@end
