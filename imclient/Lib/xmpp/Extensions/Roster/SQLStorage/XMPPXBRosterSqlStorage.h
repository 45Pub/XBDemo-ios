//
//  XMPPXBRosterSqlStorage.h
//  IMClient
//
//  Created by pengjay on 13-7-16.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "XMPPRosterSqlStorage.h"
#import "XMPPXBRoster.h"
@interface XMPPXBRosterSqlStorage : XMPPRosterSqlStorage <XMPPXBRosterProtocol>
- (NSArray *)discussMembersWithdgid:(NSString *)dgid;
- (BOOL)memberIsAdmin:(NSString *)memberid withDgid:(NSString *)dgid;
- (BOOL)memberExsit:(NSString *)memberid withDgid:(NSString *)dgid;

@end

@protocol XMPPXBRosterSqlStorageDelegate <NSObject>

@optional

/**
 *	@brief create discussGroup event
 *
 *	@param 	sender
 *	@param 	dgid 	discuss group id , like user jid
 *	@param 	dgName 	discuss group name
 *	@param 	sponsor 	user jid who sponsor this event
 *	@param 	sponsorName 	user nickname
 *	@param 	members 	each item is a NSDictionary , contains "jid", "name" 
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didCreateDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName members:(NSArray *)members;

/**
 *	@brief delete discuss group event	
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didDeletedDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName;

/**
 *	@brief you are kicked by the sponer 
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didKickedDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName;
/**
 *	@brief  add discuss group members event
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didAddDiscussGroupMemebers:(NSArray *)memberArray dgid:(NSString *)dgid
			dgname:(NSString *)dgName sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName;

/**
 *	@brief  remove discuss group members event 
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didRemoveDiscussGroupMemebers:(NSArray *)memberArray dgid:(NSString *)dgid
			dgname:(NSString *)dgName sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName;

/**
 *	@brief change discuss group name event 
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender nameDidChanged:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName;

/**
 *	@brief sponsor quit the discuss group 
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didQuitDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName;

/**
 *	@brief discuss group state changed 
 *	other params the same as "create discuss group"
 */
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didChangedDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName;
@end