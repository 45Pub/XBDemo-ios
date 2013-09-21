//
//  XMPPXBRoster.h
//  IMClient
//
//  Created by pengjay on 13-7-16.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "XMPPRoster.h"
static NSString *const XBROSTER_CMD_CREATEGROUP = @"creategroup";
static NSString *const XBROSTER_CMD_DELETEGROUP = @"removegroup";
static NSString *const XBROSTER_CMD_QUITGROUP = @"quitgroup";
static NSString *const XBROSTER_CMD_ADDMEMBER = @"addmember";
static NSString *const XBROSTER_CMD_REMOVEMEMBER = @"removemember";
static NSString *const XBROSTER_CMD_KICKED = @"kicked";
static NSString *const XBROSTER_CMD_RENAME = @"rename";


@interface XMPPXBRoster : XMPPRoster
/**
 *	@brief create discuss group
 *
 *	@param 	dgName discuss group name
 *	@param 	memberDics 	each item is a NSDictionary, contains "jid", "name"
 *
 *	@return	iq seqid
 */
- (NSString *)createDiscussGroup:(NSString *)dgName withMembers:(NSArray *)memberDics;
- (NSString *)deleteDiscussGroup:(NSString *)dgid;
- (NSString *)qiutDiscussGroup:(NSString *)dgid;
- (NSString *)changeDiscussGroup:(NSString *)dgid withNewName:(NSString *)dgName;
- (NSString *)addDiscussGroup:(NSString *)dgid withMembers:(NSArray *)memberDics;
- (NSString *)removeDiscussGroup:(NSString *)dgid withMembers:(NSArray *)memberDics;
@end

@protocol XMPPXBRosterProtocol <NSObject>

@optional
- (void)insertUserObject:(XMPPUserObject *)user;
- (void)insertUserGroups:(XMPPGroupObject *)gobj;
- (void)removeUserObjectWithBareJidStr:(NSString *)bareJidStr;
- (BOOL)userObjectIsExsit:(NSString *)jidstr;
- (NSArray *)groupsForJidStr:(NSString *)barejid;
- (NSArray *)resourcesForJidStr:(NSString *)barejid;
- (void)removeDiscussAllMemeberWithId:(NSString *)dgid;
@required
- (void)handleEventMessageWithDgid:(NSString *)dgid dgName:(NSString *)dgName event:(NSXMLElement *)event
						xmppStream:(XMPPStream *)stream;
- (NSArray *)discussMembersWithdgid:(NSString *)dgid;
@end