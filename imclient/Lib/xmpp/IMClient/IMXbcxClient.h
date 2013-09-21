//
//  IMXbcxClient.h
//  IMClient
//
//  Created by pengjay on 13-7-16.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMBaseClient.h"
//for xbcx
#import "XMPPXBRoster.h"
#import "XMPPXBRosterSqlStorage.h"
#import "XMPPXBPrivacy.h"

@interface IMXbcxClient : IMBaseClient
@property (nonatomic, strong, readonly) XMPPXBPrivacy *xmppXBPrivacy;
- (XMPPXBRoster *)xbRoster;
- (XMPPXBRosterSqlStorage *)xbRosterStorage;
- (NSArray *)membersForDiscussGroup:(NSString *)dgid;


//Friend
- (void)sendAddFriendAsk:(NSString *)text to:(NSString *)jidstr;
- (void)confireFriendAskto:(NSString *)jidstr;
@end
