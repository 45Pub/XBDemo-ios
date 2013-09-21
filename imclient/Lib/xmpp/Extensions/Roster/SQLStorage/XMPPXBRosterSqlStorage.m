//
//  XMPPXBRosterSqlStorage.m
//  IMClient
//
//  Created by pengjay on 13-7-16.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "XMPPXBRosterSqlStorage.h"
#import "XMPPUserObject.h"
#import "XMPPGroupObject.h"
#import "XMPPResourceObject.h"
#import "XMPPRosterPrivate.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"
#import "FMDatabase.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPXBRosterSqlStorage




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
- (void)createRosterTable:(FMDatabase *)db
{
	//create roster table
	
	NSString *sql = @"create table roster(\
	mid integer PRIMARY KEY autoincrement, \
	ver integer default 0,\
	barejid varchar(255) UNIQUE default '',\
	fulljid varchar(255) default '',\
	nickname varchar(255) default '',\
	displayname varchar(255) default '',\
	subscription varchar(64) default '',\
	pinyin varchar(255) default '',\
	firstletter integer default 0,\
	usertype integer default 0,\
	extint integer default 0,\
	extstr varchar(255) default '',\
	ask varchar(64) default '')";
	
	[db executeUpdate:sql];
	sql = [NSString stringWithFormat:@"create index roster_userid_index on roster(barejid)"];
    [db executeUpdate:sql];
	
	return;
}

- (void)createDiscussMemeberTable:(FMDatabase *)db
{
	NSString *sql = @"create table rosterDiscussMemeber(\
	mid integer PRIMARY KEY autoincrement, \
	ver integer default 0,\
	dgid varchar(255) default '',\
	dgname varchar(255) default '',\
	userjid varchar(255) default '',\
	nickname varchar(255) default '',\
	isAdmin integer default 0,\
	extint integer default 0,\
	extstr varchar(255) default '',\
	inserttime integer default 0)";
	
	[db executeUpdate:sql];
	sql = [NSString stringWithFormat:@"create index roster_discussmemeber_dgid on rosterDiscussMemeber(dgid)"];
    [db executeUpdate:sql];
	
	return;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - DiscussMemeber

- (void)addDiscussMemeber:(NSString *)memberJid memberName:(NSString *)memberName isAdmin:(BOOL)isAdmin
					 dgid:(NSString *)dgid dgName:(NSString *)dgName
{
	NSString *sql = [NSString stringWithFormat:@"insert into rosterDiscussMemeber(dgid, dgname, userjid,\
					 nickname ,isAdmin, inserttime) values('%@', '%@', '%@', '%@', %d, %ld)", dgid, dgName,
					 memberJid, memberName, isAdmin, time(NULL)];
	
	__weak typeof(self) wself = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		typeof(self) sself = wself;
		BOOL suc = [db executeUpdate:sql];
		if (!suc) {
			if ([db lastErrorCode] == 1) {
				[sself createDiscussMemeberTable:db];
				[db executeUpdate:sql];
			}
		}
	}];
	
}


- (void)removeDiscussMember:(NSString *)memberJid dgid:(NSString *)dgid
{
	NSString *sql = [NSString stringWithFormat:@"delete from rosterDiscussMemeber where userjid='%@' and dgid = '%@'",
					 memberJid, dgid];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}

- (void)removeDiscussAllMemeberWithId:(NSString *)dgid
{
	NSString *sql = [NSString stringWithFormat:@"delete from rosterDiscussMemeber where dgid = '%@'", dgid];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}

- (NSArray *)discussMembersWithdgid:(NSString *)dgid
{
	if (dgid == nil)
		return nil;
	__block NSMutableArray *resultArray = nil;
	
	NSString *sql = [NSString stringWithFormat:@"select userjid, nickname, isAdmin from rosterDiscussMemeber where\
					 dgid = '%@'", dgid];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		resultArray = [NSMutableArray array];
		while ([rs next]) {
			XMPPUserObject *user = [[XMPPUserObject alloc]init];
			user.jidStr = [rs stringForColumn:@"userjid"];
			user.nickname = [rs stringForColumn:@"nickname"];
			user.isAdmin = [rs intForColumn:@"isAdmin"];
			[resultArray addObject:user];
		}
		[rs close];
	}];
	return resultArray;
}

- (BOOL)memberIsAdmin:(NSString *)memberid withDgid:(NSString *)dgid
{
	if (memberid == nil || dgid == nil)
		return NO;
	
	NSString *sql = [NSString stringWithFormat:@"select userjid, nickname, isAdmin from rosterDiscussMemeber where\
					 dgid = '%@' and userjid = '%@'", dgid, memberid];
	__block BOOL flag = NO;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		if ([rs next]) {
			flag = [rs boolForColumn:@"isAdmin"];
		}
		[rs close];
	}];
	return flag;
}

- (BOOL)memberExsit:(NSString *)memberid withDgid:(NSString *)dgid
{
	if (memberid == nil || dgid == nil)
		return NO;
	
	NSString *sql = [NSString stringWithFormat:@"select userjid, nickname, isAdmin from rosterDiscussMemeber where\
					 dgid = '%@' and userjid = '%@'", dgid, memberid];
	__block BOOL flag = NO;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		if ([rs next]) {
			flag = YES;
		}
		[rs close];
	}];
	return flag;
}

- (void)updateDiscussGroupName:(NSString *)newName dgid:(NSString *)dgid
{
	if (newName.length <= 0) {
		return;
	}
	NSString *sql = [NSString stringWithFormat:@"update roster set nickname = '%@', displayname = '%@' where barejid = '%@'", newName, newName, dgid];
	NSString *dsql = [NSString stringWithFormat:@"update rosterDiscussMemeber set dgname = '%@' where dgid = '%@'", newName, dgid];
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
		[db executeUpdate:dsql];
	}];

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
/*<member jid="9ce5e383f4ec5d9dce895333e7d25a462a201da0@qiumihui.cn" name="ppp111" admin="1"/>*/
- (void)insertDiscussMembersWithItem:(NSXMLElement *)item
{
	NSArray *members = [item elementsForName:@"member"];
	NSString *dgid = [item attributeStringValueForName:@"jid"];
	NSString *dgname = [item attributeStringValueForName:@"name"];
	for (NSXMLElement *memberItem in members) {
		NSString *memberJid = [memberItem attributeStringValueForName:@"jid"];
		NSString *memberName = [memberItem attributeStringValueForName:@"name"];
		NSInteger isAdmin = [memberItem attributeIntValueForName:@"admin" withDefaultValue:0];
		if (![self memberExsit:memberJid withDgid:dgid]) {
			[self addDiscussMemeber:memberJid memberName:memberName isAdmin:isAdmin dgid:dgid dgName:dgname];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - super
- (GCDMulticastDelegate <XMPPRosterSqlStorageDelegate, XMPPXBRosterSqlStorageDelegate> *)multicastDelegate
{
	return (GCDMulticastDelegate <XMPPRosterSqlStorageDelegate, XMPPXBRosterSqlStorageDelegate> *)[parent multicastDelegate];
}

- (void)clearRosterTable:(FMDatabase *)db
{
	NSString *sql = @"drop table roster";
	[db executeUpdate:sql];
	sql = @"drop table rosterDiscussMemeber";
	[db executeUpdate:sql];
}


- (void)insertUserObject:(XMPPUserObject *)user
{
	NSString *pinyin = [self getFullPinyin:user.nickname];
	unichar firstletter = [self getFirstLetterWithPinyin:pinyin usertype:user.usertype];

	NSString *sql = [NSString stringWithFormat:@"insert into roster (barejid, fulljid, nickname, displayname, subscription, ask, usertype, pinyin, firstletter) values ('%@', '%@', '%@', '%@', '%@', '%@', %d, '%@', %d)", user.jidStr, user.jidStr, user.nickname, user.displayName, user.subscription, user.ask, user.usertype,
					 pinyin, firstletter];
	
	__weak typeof(self) wself = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		typeof(self) sself = wself;
		BOOL suc = [db executeUpdate:sql];
		if (!suc)
		{
			if ([db lastErrorCode] == 1)
			{
				[sself createRosterTable:db];
				[db executeUpdate:sql];
			}
		}
	}];
}

- (NSArray *)usersWithSql:(NSString *)sql
{
	__block NSMutableArray *resultArray = nil;
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
		resultArray = [NSMutableArray array];
        while ([rs next])
        {
		    XMPPUserObject *user = [[XMPPUserObject alloc]init];
			user.jidStr = [rs stringForColumn:@"barejid"];
			user.streamBareJidStr = [rs stringForColumn:@"barejid"];
			user.nickname = [rs stringForColumn:@"nickname"];
			user.displayName = [rs stringForColumn:@"displayname"];
			user.subscription = [rs stringForColumn:@"subscription"];
			user.ask = [rs stringForColumn:@"ask"];
			user.usertype = [rs intForColumn:@"usertype"];
			user.pinyin = [rs stringForColumn:@"pinyin"];
			user.firstLetter = [rs intForColumn:@"firstletter"];
			[resultArray addObject:user];
			
        }
        [rs close];
    }];
	
	for (XMPPUserObject *user in resultArray)
	{
		user.groups = [NSSet setWithArray:[self groupsForJidStr:user.jidStr]];
		
		user.resources = [NSSet setWithArray:[self resourcesForJidStr:user.jidStr]];
		
		[user recalculatePrimaryResource];
	}
	
	return resultArray;
}
- (NSArray *)allUsers
{
	NSString *sql = [NSString stringWithFormat:@"select barejid, fulljid, nickname, displayname, subscription, ask,\
					 usertype, pinyin, firstletter from roster order by firstletter asc"];
	
	return [self usersWithSql:sql];
}

- (NSArray *)searchUsersWithKey:(NSString *)key
{
	NSMutableArray *array = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"select barejid, fulljid, nickname, displayname, subscription, ask,\
					 usertype, pinyin, firstletter from roster where nickname like '%%%@%%'", key];
	[array addObjectsFromArray:[self usersWithSql:sql]];
	
	sql = [NSString stringWithFormat:@"select barejid, fulljid, nickname, displayname, subscription, ask,\
		   usertype, pinyin, firstletter from roster where pinyin like '%%%@%%'", key];
	[array addObjectsFromArray:[self usersWithSql:sql]];
	return array;
}


- (XMPPUserObject *)userForJidStr:(NSString *)bareJid
{
	NSString *sql = [NSString stringWithFormat:@"select barejid, fulljid, nickname, displayname, subscription, ask,\
					 usertype, pinyin, firstletter from roster where barejid = '%@'", bareJid];
	
	__block XMPPUserObject *user = nil;
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next])
        {
			user = [[XMPPUserObject alloc]init];
			user.jidStr = [rs stringForColumn:@"barejid"];
			user.streamBareJidStr = [rs stringForColumn:@"barejid"];
			user.nickname = [rs stringForColumn:@"nickname"];
			user.displayName = [rs stringForColumn:@"displayname"];
			user.subscription = [rs stringForColumn:@"subscription"];
			user.ask = [rs stringForColumn:@"ask"];
			user.usertype = [rs intForColumn:@"usertype"];
			user.pinyin = [rs stringForColumn:@"pinyin"];
			user.firstLetter = [rs intForColumn:@"firstletter"];
        }
        [rs close];
    }];
	
	if (user)
	{
		user.groups = [NSSet setWithArray:[self groupsForJidStr:bareJid]];
		
		user.resources = [NSSet setWithArray:[self resourcesForJidStr:bareJid]];
		
		[user recalculatePrimaryResource];
		
	}
	
	return user;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)insertUserObjectWithItem:(NSXMLElement *)item bareJidStr:(NSString *)bareJidStr
{
	XMPPUserObject *user = [XMPPUserObject userWithItem:item];
	
	[self insertUserObject:user];
	
	if (user.usertype == XMPPUserTypeDiscussGroup) {
		[self insertDiscussMembersWithItem:item];
	}
	else {
		for (XMPPGroupObject *gobj in user.groups.allObjects)
		{
			[self insertUserGroups:gobj];
		}
	}
}

#pragma mark - Event
- (void)handleEventMessageWithDgid:(NSString *)dgid dgName:(NSString *)dgName event:(NSXMLElement *)event
						xmppStream:(XMPPStream *)stream
{
	/*<event sponsor="9260ed35e38d94a2759b9f30ae0445fbcc602e29@qiumihui.cn" name="&#x5929;&#x5929;" kind="creategroup"><member jid="9260ed35e38d94a2759b9f30ae0445fbcc602e29@qiumihui.cn" name="&#x5929;&#x5929;" admin="1"/><member jid="test111110@qiumihui.cn" admin="0"/><member jid="test111112@qiumihui.cn" admin="0"/><member jid="test111111@qiumihui.cn" admin="0"/></event>*/

	if (dgid == nil || dgName == nil || event == nil)
		return;
	XMPPLogTrace();
	
	NSString *kind = [event attributeStringValueForName:@"kind"];
	NSString *sponsor = [event attributeStringValueForName:@"sponsor"];
	NSString *sponsorName = [event attributeStringValueForName:@"name"];
	if ([sponsor isEqualToString:[[stream myJID] bare]]) {
		XMPPLogVerbose(@"from self :ignore");
//		return;
	}
	
	if ([kind isEqualToString:@"creategroup"]) {
		///add group in roster
		XMPPUserObject *groupUser = [[XMPPUserObject alloc]init];
		groupUser.jidStr = dgid;
		groupUser.nickname = dgName;
		groupUser.usertype = XMPPUserTypeDiscussGroup;
		
		[self insertUserObject:groupUser];
		
		//add members in table
		NSArray *qunItems = [event elementsForName:@"member"];
		NSMutableArray *users = [NSMutableArray array];
		for (NSXMLElement *item in qunItems) {
			NSString *itemjid = [item attributeStringValueForName:@"jid"];
			NSString *itemName = [item attributeStringValueForName:@"name"];
			
			int isadmin = [item attributeIntValueForName:@"admin" withDefaultValue:0];
			
			if (![self memberExsit:itemjid withDgid:dgid]) {
				[self addDiscussMemeber:itemjid memberName:itemName isAdmin:isadmin dgid:dgid dgName:dgName];
			}
			
			NSDictionary *dic = [item attributesAsDictionary];
			if (dic) {
				[users addObject:dic];
			}
		}
		
		[[self multicastDelegate] xmppRoster:self didCreateDiscussGroup:dgid dgName:dgName
									 sponsor:sponsor sponsorName:sponsorName members:users];
		

	}
	else if ([kind isEqualToString:@"removegroup"] || [kind isEqualToString:@"kicked"]) {
		[self removeUserObjectWithBareJidStr:dgid];
		[self removeDiscussAllMemeberWithId:dgid];
		
		if ([kind isEqualToString:@"kicked"]) {
			[[self multicastDelegate] xmppRoster:self didKickedDiscussGroup:dgid dgName:dgName
										 sponsor:sponsor sponsorName:sponsorName];
		}
		else {
			[[self multicastDelegate] xmppRoster:self didDeletedDiscussGroup:dgid dgName:dgName
										 sponsor:sponsor sponsorName:sponsorName];
		}
		
	}
	else if ([kind isEqualToString:@"quitgroup"]) {
		[self removeDiscussMember:sponsor dgid:dgid];
		[[self multicastDelegate] xmppRoster:self didQuitDiscussGroup:dgid dgName:dgName
									 sponsor:sponsor sponsorName:sponsorName];
		
	}
	else if([kind isEqualToString:@"addmember"]) {
		if (![self userObjectIsExsit:dgid]) {
			XMPPUserObject *groupUser = [[XMPPUserObject alloc]init];
			groupUser.jidStr = dgid;
			groupUser.nickname = dgName;
			groupUser.usertype = XMPPUserTypeDiscussGroup;
			
			[self insertUserObject:groupUser];
		}
		
		NSArray *qunItems = [event elementsForName:@"member"];
		NSMutableArray *users = [NSMutableArray array];
		for (NSXMLElement *item in qunItems) {
			NSString *itemjid = [item attributeStringValueForName:@"jid"];
			NSString *itemName = [item attributeStringValueForName:@"name"];
			int isadmin = [item attributeIntValueForName:@"admin" withDefaultValue:0];
			if (![self memberExsit:itemjid withDgid:dgid]) {
				[self addDiscussMemeber:itemjid memberName:itemName isAdmin:isadmin dgid:dgid dgName:dgName];
			}
			
			NSDictionary *dic = [item attributesAsDictionary];
			if (dic) {
				[users addObject:dic];
			}
		}
		
		[[self multicastDelegate] xmppRoster:self didAddDiscussGroupMemebers:users dgid:dgid dgname:dgName
									 sponsor:sponsor sponsorName:sponsorName];
	}
	else if ([kind isEqualToString:@"removemember"]) {
		NSArray *qunItems = [event elementsForName:@"member"];
		NSMutableArray *users = [NSMutableArray array];
		for(NSXMLElement *item in qunItems) {
			NSString *itemjid = [item attributeStringValueForName:@"jid"];
			[self removeDiscussMember:itemjid dgid:dgid];
			NSDictionary *dic = [item attributesAsDictionary];
			if (dic) {
				[users addObject:dic];
			}
		}
		
		[[self multicastDelegate] xmppRoster:self didRemoveDiscussGroupMemebers:users dgid:dgid dgname:dgName
									 sponsor:sponsor sponsorName:sponsorName];
	}
	else if ([kind isEqualToString:@"rename"]) {
		[self updateDiscussGroupName:dgName dgid:dgid];
		[[self multicastDelegate] xmppRoster:self
							  nameDidChanged:dgid
									  dgName:dgName
									 sponsor:sponsor
								 sponsorName:sponsorName];
	}
	[[self multicastDelegate] xmppRosterDidChange:self];
	[[self multicastDelegate] xmppRoster:self
				  didChangedDiscussGroup:dgid
								  dgName:dgName
								 sponsor:sponsor
							 sponsorName:sponsorName];
}
@end
