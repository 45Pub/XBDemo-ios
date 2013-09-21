// XMPPRosterSqlStorage.m
// 
// Copyright (c) 2013年 pengjay.cn@gmail.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//   http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "XMPPRosterSqlStorage.h"
#import "XMPPUserObject.h"
#import "XMPPGroupObject.h"
#import "XMPPResourceObject.h"
#import "XMPPRosterPrivate.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"
#import "FMDatabase.h"
#import "CharToPinyin.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

#define AssertPrivateQueue() \
NSAssert(dispatch_get_specific(storageQueueTag), @"Private method: MUST run on storageQueue");

@implementation XMPPRosterSqlStorage

//////////////////////////////////////////////////////

- (instancetype)initWithdbQueue:(FMDatabaseQueue *)dbQueue
{
	self = [super initWithdbQueue:dbQueue];
	if (self)
	{
		rosterPopulationSet = [[NSMutableSet alloc]init];
	}
	
	return self;
}


- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
	if (parentQueue)
		dispatch_release(parentQueue);
#endif
}
///////////////////////////////////////////////////////////////////////////////
- (GCDMulticastDelegate <XMPPRosterSqlStorageDelegate> *)multicastDelegate
{
	return (GCDMulticastDelegate <XMPPRosterSqlStorageDelegate> *)[parent multicastDelegate];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark PinYin
- (NSString *)getFullPinyin:(NSString *)nickName
{
	if (nickName == nil) {
		return @"#";
	}
	
	NSString *pinyin = [[CharToPinyin shared] translate:nickName withSpaceString:@"" options:CPSpellOptionsNone];
	if (pinyin.length <= 0)
		pinyin = @"#";
	return pinyin;
}

- (unichar)getFirstLetterWithPinyin:(NSString *)pinyin usertype:(NSInteger)type
{
	if (type == XMPPUserTypeUser) {
		return [pinyin characterAtIndex:0];
	}
	else {
		return '$';
	}
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private 
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
					 ask varchar(64) default '')";
	
	[db executeUpdate:sql];
	sql = [NSString stringWithFormat:@"create index roster_userid_index on roster(barejid)"];
    [db executeUpdate:sql];
	
	return;
}

- (void)createUserGroupTable:(FMDatabase *)db
{
	//create user groups table
	NSString *sql = @"create table usergroups(\
					 ver integer default 0,\
					mid integer PRIMARY KEY autoincrement, \
					 barejid varchar(255) default '',\
					 groupname varchar(255)  default '')";
	
	[db executeUpdate:sql];
}

- (void)createUserResourceTable:(FMDatabase *)db
{
	NSString *sql = @"create table userresource(\
					 ver integer default 0,\
					mid integer PRIMARY KEY autoincrement, \
					 barejid varchar(255) default '',\
					 fulljid varchar(255) default '',\
					 presencestr text default '',\
					 presencedate integer default 0,\
					 prioritynum integer default 0,\
					 shownum integer default 0,\
					 show varchar(64) default '',\
					 status varchar(64) default '',\
					 type varchar(64) default '')";
	
	[db executeUpdate:sql];
	sql = [NSString stringWithFormat:@"create index user_resource_userid_index on userresource(barejid)"];
    [db executeUpdate:sql];
}

///////////////////////////////////////////////////////////////////////////////
- (void)clearRosterTable:(FMDatabase *)db
{
	NSString *sql = @"drop table roster";
	[db executeUpdate:sql];
}


- (void)clearUserGroupTable:(FMDatabase *)db
{
	NSString *sql = @"drop table usergroups";
	[db executeUpdate:sql];
}


- (void)clearUserResourceTable:(FMDatabase *)db
{
	NSString *sql = @"drop table userresource";
	[db executeUpdate:sql];
}

- (void)insertUserObject:(XMPPUserObject *)user
{
	NSString *pinyin = [self getFullPinyin:user.nickname];
	unichar firstletter = [self getFirstLetterWithPinyin:pinyin usertype:user.usertype];
	NSString *sql = [NSString stringWithFormat:@"insert into roster (barejid, fulljid, nickname, displayname, subscription, ask, pinyin, firstletter) values ('%@', '%@', '%@', '%@', '%@', '%@', '%@', %d)", user.jidStr, user.jidStr, user.nickname==nil?@"":user.nickname, user.displayName, user.subscription, user.ask, pinyin, firstletter];
	__weak XMPPRosterSqlStorage* wself = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		XMPPRosterSqlStorage *sself = wself;
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

- (void)insertUserGroups:(XMPPGroupObject *)gobj
{
	NSString * gsql = [NSString stringWithFormat:@"insert into usergroups(barejid, groupname) values('%@', '%@')", gobj.jidstr, gobj.groupName];
	__weak XMPPRosterSqlStorage* wself = self;
		[_dbQueue inDatabase:^(FMDatabase *db) {
			XMPPRosterSqlStorage *sself = wself;
			BOOL suc = [db executeUpdate:gsql];
			if (!suc)
			{
				if ([db lastErrorCode] == 1)
				{
					[sself createUserGroupTable:db];
					[db executeUpdate:gsql];
				}
			}
		}];

}

- (void)insertUserResource:(XMPPResourceObject *)resource
{
	NSString *sql = [NSString stringWithFormat:@"insert into userresource (barejid, fulljid, presencestr, presencedate, prioritynum, shownum, show, status, type) values ('%@', '%@', '%@', %llu, %d, %d, '%@', '%@', '%@')", resource.bareJidStr, resource.fullJidStr, resource.presenceStr, (unsigned long long)[resource.presenceDate timeIntervalSince1970], resource.prioritynum, resource.shownum, resource.show, resource.status, resource.type];
	__weak XMPPRosterSqlStorage* wself = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		XMPPRosterSqlStorage *sself = wself;
		BOOL suc = [db executeUpdate:sql];
		if (!suc)
		{
			if ([db lastErrorCode] == 1)
			{
				[sself createUserResourceTable:db];
				[db executeUpdate:sql];
			}
		}
	}];
}

- (void)updateUserResource:(XMPPResourceObject *)resource
{
	NSString *sql = [NSString stringWithFormat:@"update userresource set barejid = '%@', presencestr = '%@', presencedate = %llu, prioritynum = %d, shownum = %d, show = '%@', status = '%@', type = '%@' where fulljid = '%@'", resource.bareJidStr, resource.presenceStr, (unsigned long long)[resource.presenceDate timeIntervalSince1970], resource.prioritynum, resource.shownum, resource.show, resource.status, resource.type , resource.fullJidStr];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}
////////////////////////////////////////////////////////////////////////////////
#pragma mark -
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
					 pinyin, firstletter from roster order by firstletter asc"];
	
	return [self usersWithSql:sql];
}

- (NSArray *)searchUsersWithKey:(NSString *)key
{
	NSMutableArray *array = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"select barejid, fulljid, nickname, displayname, subscription, ask,\
					 pinyin, firstletter from roster where nickname like '%%%@%%'", key];
	[array addObjectsFromArray:[self usersWithSql:sql]];
	
	sql = [NSString stringWithFormat:@"select barejid, fulljid, nickname, displayname, subscription, ask,\
					 pinyin, firstletter from roster where pinyin like '%%%@%%'", key];
	[array addObjectsFromArray:[self usersWithSql:sql]];
	return array;
}

- (XMPPUserObject *)userForJidStr:(NSString *)bareJid
{
	NSString *sql = [NSString stringWithFormat:@"select barejid, fulljid, nickname, displayname, subscription, ask,\
					 pinyin, firstletter from roster where barejid = '%@'", bareJid];
	
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

- (NSArray *)groupsForJidStr:(NSString *)barejid
{
	__block NSMutableArray *result = nil;
	
    NSString *sql = [NSString stringWithFormat:@"select groupname from usergroups where barejid = '%@'", barejid];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        result = [NSMutableArray array];
        while([rs next])
        {
            NSString *gpname = [rs stringForColumn:@"groupname"];
			XMPPGroupObject *gpobj = [[XMPPGroupObject alloc]init];
			gpobj.groupName = gpname;
			gpobj.jidstr = barejid;
			[result addObject:gpobj];
        }
        [rs close];
    }];
    return result;
}

- (NSArray *)resourcesForJidStr:(NSString *)barejid
{
	NSString *sql = [NSString stringWithFormat:@"select barejid, fulljid, presencestr, presencedate, prioritynum, shownum, show, status, type from userresource where barejid = '%@'", barejid];
	
	__block NSMutableArray *result = nil;
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		result = [NSMutableArray array];
		while ([rs next])
		{
			XMPPResourceObject *res = [[XMPPResourceObject alloc]init];
			
			res.bareJidStr = [rs stringForColumn:@"barejid"];
			res.fullJidStr = [rs stringForColumn:@"fulljid"];
			res.presenceStr = [rs stringForColumn:@"presencestr"];
			res.presenceDate = [rs dateForColumn:@"presencedate"];
			res.prioritynum = [rs intForColumn:@"prioritynum"];
			res.shownum = [rs intForColumn:@"shownum"];
			res.show = [rs stringForColumn:@"show"];
			res.status = [rs stringForColumn:@"status"];
			res.type = [rs stringForColumn:@"type"];
			
			[result addObject:res];
		}
		[rs close];
	}];
	return result;
}
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
- (XMPPResourceObject *)userResourceForFullJid:(NSString *)fulljid
{
	NSString *sql = [NSString stringWithFormat:@"select barejid, fulljid, presencestr, presencedate, prioritynum, shownum, show, status, type from userresource where fulljid = '%@'", fulljid];
	
	__block XMPPResourceObject *result = nil;
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		if ([rs next])
		{
			result = [[XMPPResourceObject alloc]init];
				
			result.bareJidStr = [rs stringForColumn:@"barejid"];
			result.fullJidStr = fulljid;
			result.presenceStr = [rs stringForColumn:@"presencestr"];
			result.presenceDate = [rs dateForColumn:@"presencedate"];
			result.prioritynum = [rs intForColumn:@"prioritynum"];
			result.shownum = [rs intForColumn:@"shownum"];
			result.show = [rs stringForColumn:@"show"];
			result.status = [rs stringForColumn:@"status"];
			result.type = [rs stringForColumn:@"type"];
		}
		[rs close];
	}];
	return result;
}

- (void)removeUserResourceWithFullJid:(NSString *)fulljid
{
	NSString *sql = [NSString stringWithFormat:@"delete from userresource where fulljid = '%@'", fulljid];
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}

- (void)insertUserObjectWithItem:(NSXMLElement *)item bareJidStr:(NSString *)bareJidStr
{
	XMPPUserObject *user = [XMPPUserObject userWithItem:item];
	
	[self insertUserObject:user];
	
	for (XMPPGroupObject *gobj in user.groups.allObjects)
	{
		[self insertUserGroups:gobj];
	}
}

- (void)removeUserObjectWithBareJidStr:(NSString *)bareJidStr
{
	if (bareJidStr == nil)
		return;
	NSString *sql = [NSString stringWithFormat:@"delete from roster where barejid = '%@'", bareJidStr];
	NSString *dsql = [NSString stringWithFormat:@"delete from usergroups where barejid = '%@'", bareJidStr];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
		[db executeUpdate:dsql];
	}];
}

- (BOOL)userObjectIsExsit:(NSString *)jidstr
{
	NSString *sql = [NSString stringWithFormat:@"select * from roster where barejid = '%@'", jidstr];
	__block BOOL result = NO;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		if ([rs next])
		{
			result = YES;
		}
		[rs close];
	}];
	return result;
}

- (void)updateUserObjectWithItem:(NSXMLElement *)item bareJidStr:(NSString *)bareJidStr
{
	XMPPUserObject *user = [XMPPUserObject userWithItem:item];
	NSString *pinyin = [self getFullPinyin:user.nickname];
	unichar firstletter = [self getFirstLetterWithPinyin:pinyin usertype:user.usertype];
	
	NSString *sql = [NSString stringWithFormat:@"update roster set nickname = '%@', displayname = '%@', subscription = '%@', ask = '%@', pinyin = '%@', firstletter=%d where barejid = '%@'",user.nickname, user.displayName, user.subscription, user.ask, pinyin, firstletter, user.jidStr];
	if (user.nickname.length <= 0) {
		sql = [NSString stringWithFormat:@"update roster set  subscription = '%@', ask = '%@', pinyin = '%@', firstletter=%d where barejid = '%@'", user.subscription, user.ask, pinyin, firstletter, user.jidStr];
	}
	__weak XMPPRosterSqlStorage* wself = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		XMPPRosterSqlStorage *sself = wself;
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
	
	//remove groups 
	NSString *dsql = [NSString stringWithFormat:@"delete from usergroups where barejid = '%@'", bareJidStr];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:dsql];
	}];
	
	for (XMPPGroupObject *gobj in user.groups.allObjects)
	{
		[self insertUserGroups:gobj];
	}

}

- (void)updateWithPresence:(XMPPPresence *)presence streamBareJidStr:(NSString *)streamBareJidStr
{
	XMPPJID *jid = [presence from];
	
	XMPPResourceObject *resource = [self userResourceForFullJid:[jid full]];
	if ([[presence type] isEqualToString:@"unavailable"] || [presence isErrorPresence])
	{
		if (resource)
		{
			[self removeUserResourceWithFullJid:[jid full]];
			
			[[self multicastDelegate] xmppRoster:self didRemoveResource:resource withUser:[jid bare]];

		}
	}
	else
	{
		if (resource)
		{
			[self updateUserResource:[XMPPResourceObject resourceWithPresence:presence]];
			
			[[self multicastDelegate] xmppRoster:self didUpdateResource:resource withUser:[jid bare]];

		}
		else
		{
			[self insertUserResource:[XMPPResourceObject resourceWithPresence:presence]];
			
			[[self multicastDelegate] xmppRoster:self didAddResource:resource withUser:[jid bare]];

		}
	}
}


//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////
#pragma mark - Protocl

- (BOOL)configureWithParent:(XMPPRoster *)aParent queue:(dispatch_queue_t)queue
{
	NSParameterAssert(aParent != nil);
	NSParameterAssert(queue != NULL);
	
	@synchronized(self)
	{
		if ((parent == nil) && (parentQueue == NULL))
		{
			parent = aParent;
			parentQueue = queue;
			parentQueueTag = &parentQueueTag;
			dispatch_queue_set_specific(parentQueue, parentQueueTag, parentQueueTag, NULL);
			
#if !OS_OBJECT_USE_OBJC
			dispatch_retain(parentQueue);
#endif
			
			return YES;
		}
	}
    
    return NO;
}


- (void)beginRosterPopulationForXMPPStream:(XMPPStream *)stream
{
	XMPPLogTrace();
	
	[rosterPopulationSet addObject:[NSNumber numberWithPtr:(__bridge void *)stream]];

	__weak XMPPRosterSqlStorage* wself = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		XMPPRosterSqlStorage *sself = wself;
		[sself clearRosterTable:db];
		[sself clearUserGroupTable:db];
		[sself clearUserResourceTable:db];
	}];
	
}


- (void)endRosterPopulationForXMPPStream:(XMPPStream *)stream
{
	XMPPLogTrace();
	
	[rosterPopulationSet removeObject:[NSNumber numberWithPtr:(__bridge void *)stream]];
	
	[[self multicastDelegate] xmppRosterDidPopulate:self];
	[[self multicastDelegate] xmppRosterDidChange:self];
}

- (void)handleRosterItem:(DDXMLElement *)itemSubElement xmppStream:(XMPPStream *)stream
{
	XMPPLogTrace();
	
	NSXMLElement *item = [itemSubElement copy];
	
	if ([rosterPopulationSet containsObject:[NSNumber numberWithPtr:(__bridge void *)stream]])
	{
		[self insertUserObjectWithItem:item bareJidStr:nil];
	}
	else
	{
		NSString *jidStr = [item attributeStringValueForName:@"jid"];
		
		
		NSString *subscription = [item attributeStringValueForName:@"subscription"];
		if ([subscription isEqualToString:@"remove"])
		{
			[self removeUserObjectWithBareJidStr:jidStr];
			
			[[self multicastDelegate] xmppRoster:self didRemoveUser:jidStr];
			[[self multicastDelegate] xmppRosterDidChange:self];
		}
		else
		{
			BOOL flag = [self userObjectIsExsit:jidStr];
			if (flag)
			{
				[self updateUserObjectWithItem:item bareJidStr:nil];
				
				[[self multicastDelegate] xmppRoster:self didUpdateUser:jidStr];
				[[self multicastDelegate] xmppRosterDidChange:self];
			}
			else
			{
				[self insertUserObjectWithItem:item bareJidStr:nil];
				[[self multicastDelegate] xmppRoster:self didAddUser:jidStr];
				[[self multicastDelegate] xmppRosterDidChange:self];
			}
		}
	}
}

- (void)handlePresence:(XMPPPresence *)presence xmppStream:(XMPPStream *)stream
{
	XMPPLogTrace();
	
	XMPPJID *jid = [presence from];
	
	BOOL flag = [self userObjectIsExsit:[jid bare]];
	if (flag == NO && [parent allowRosterlessOperation])
	{
		XMPPUserObject *user = [[XMPPUserObject alloc]init];
		user.jidStr = [jid bare];
		user.jid = jid;
		user.displayName = [jid bare];
		[self insertUserObject:user];
		
		[[self multicastDelegate] xmppRoster:self didAddUser:user.jidStr];
		[[self multicastDelegate] xmppRosterDidChange:self];
	}
	[self updateWithPresence:presence streamBareJidStr:nil];
}

- (void)clearAllResourcesForXMPPStream:(XMPPStream *)stream
{
    __weak XMPPRosterSqlStorage* wself = self;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        XMPPRosterSqlStorage *sself = wself;
        [sself clearUserResourceTable:db];
    }];
	
	[[self multicastDelegate] xmppRosterDidChange:self];
}


- (void)clearAllUsersAndResourcesForXMPPStream:(XMPPStream *)stream
{
    __weak XMPPRosterSqlStorage* wself = self;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        XMPPRosterSqlStorage *sself = wself;
        [sself clearRosterTable:db];
        [sself clearUserGroupTable:db];
        [sself clearUserResourceTable:db];
    }];
	
	[[self multicastDelegate] xmppRosterDidChange:self];
}

- (NSArray *)jidsForXMPPStream:(XMPPStream *)stream
{
    __block NSMutableArray *result = nil;

    NSString *sql = [NSString stringWithFormat:@"select barejid from roster"];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        result = [NSMutableArray array];
        while([rs next])
        {
            NSString *barejid = [rs stringForColumn:@"barejid"];
           [result addObject:barejid];
        }
        [rs close];
    }];
    return result;
}

- (BOOL)userExistsWithJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
	return [self userObjectIsExsit:jid.bare];
}
@end
