//
//  IMMsgStorage.m
//  iPhoneXMPP
//
//  Created by on 13-7-8.
//
//

#import "IMMsgStorage.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "IMUser.h"
#import "JSONKit.h"
#import "IMUserManager.h"
#import "XMPPLogging.h"

#import "IMChatSession.h"
#import "IMMsgCacheManager.h"
#import "IMMsgFactory.h"

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_OFF;
#endif

@interface NSMutableArray(Storage)
- (void)reverse;
@end

@implementation NSMutableArray(Storage)
- (void)reverse {
	for (int i=0; i<(floor([self count]/2.0)); i++) {
		[self exchangeObjectAtIndex:i withObjectAtIndex:([self count]-(i+1))];
    }
}
@end


@implementation IMMsgStorage

- (id)initWithdbQueue:(FMDatabaseQueue *)dbQueue userManager:(IMUserManager *)userMgr
		   msgManager:(IMMsgCacheManager *)msgMgr
{
	self = [super init];
	if (self) {
		_dbQueue = dbQueue;
		_userMgr = userMgr;
		_msgMgr = msgMgr;
	}
	return self;
}

///////////////////////////////////////////////////////////////
- (NSString *)tableNameForMsg:(IMMsg *)msg
{
	return [self tableNameForUser:msg.fromUser];
}

- (NSString *)tableNameForUser:(IMUser *)user
{
	return [self tableNameForUserID:user.userID userType:user.userType];
}

- (NSString *)tableNameForUserID:(NSString *)userid userType:(IMUserType)type
{
	NSString *fixstr = userid;
	return [NSString stringWithFormat:@"immsg_%d_%@", type, fixstr];
}

- (NSString *)emptyStringWhenNil:(NSString *)str
{
	if (str == nil) {
		return @"";
	}
	return str;
}
///////////////////////////////////////////////////////////////
//SQL
- (void)createMsgTable:(IMMsg *)msg db:(FMDatabase *)db
{
	NSString *tableName = [self tableNameForMsg:msg];
	
	NSString *sql = [NSString stringWithFormat:@"create table `%@` \
					 (mid integer PRIMARY KEY autoincrement,\
					 msgver integer default 1,\
					 msgid varchar(128) default '',\
					 userid varchar(64) default '',\
					 nickname varchar(128) default '',\
					 usertype integer default 0,\
					 msgtype integer default 1,\
					 msgbody text, msgsize integer,\
					 msgattach text default '',\
					 readstate integer,\
					 procstate integer,\
					 playstate integer,\
					 fromtype integer default 0,\
					 msgtime integer, \
					 remotetime integer, \
					 inserttime integer, \
					 colIntRes1 integer default 0,\
					 colIntRes2 integer default 0,\
					 colIntRes3 integer default 0,\
					 colStrRes1 Text default '',\
					 colStrRes2 Text default '',\
					 colStrRes3 Text default '')", tableName];
	
	[db executeUpdate:sql];
	sql = [NSString stringWithFormat:@"create index `%@_msgid_index` on `%@`(msgid)", tableName, tableName];
	[db executeUpdate:sql];
}

- (NSString *)makeMsgInsertSql:(IMMsg *)msg
{
	NSString *sql = nil;
	NSString *tableName = [self tableNameForMsg:msg];
	
	sql = [NSString stringWithFormat:@"insert into `%@`(msgid,msgver,userid,nickname,usertype,msgtype,msgbody,msgsize,msgattach,readstate,procstate,playstate,fromtype,msgtime,remotetime,inserttime) values('%@',%d,'%@','%@',%d,%d,'%@',%llu,'%@',%d,%d,%d,%d,%lu,%lu,%lu)", tableName, msg.msgID,msg.msgVer, msg.msgUser.userID, msg.msgUser.nickname,msg.msgUser.userType, msg.msgType, msg.msgBody, msg.msgSize,[self emptyStringWhenNil:[msg.msgAttach JSONString]], msg.readState, msg.procState, msg.playState, msg.fromType,(unsigned long)[msg.msgTime timeIntervalSince1970] , (unsigned long)[msg.msgTime timeIntervalSince1970], time(NULL)];
	
	return sql;
}

- (NSInteger )getMidWithMsgid:(NSString *)msgid tableName:(NSString *)tableName
{
	__block NSInteger mid = -1;
	NSString *sql = [NSString stringWithFormat:@"select mid from `%@` where msgid='%@'", tableName, msgid];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs;
		rs = [db executeQuery:sql];
		if([rs next])
		{
			mid = [rs intForColumn:@"mid"];
		}
		[rs close];
	}];
	return mid;
}

- (IMMsg *)getCachedMsg:(IMUser *)fromUser msgid:(NSString *)msgid
{
	IMMsg *cacheMsg = [_msgMgr getProcessCachedMsgWithUser:fromUser msgid:msgid];
	if (cacheMsg == nil) {
		cacheMsg = [_msgMgr getSessionCachedMsgWithUser:fromUser msgid:msgid];
	}
	return cacheMsg;
}

- (NSMutableArray *)getUserMsginDB:(FMDatabase *)db SQL:(NSString *)sql fromUser:(IMUser *)fromUser
{
	
	NSMutableArray *tmpArray = [NSMutableArray array];
	//		NSMutableDictionary *cacheDic = [NSMutableDictionary dictionary];
	FMResultSet *rs = [db executeQuery:sql];
	while ([rs next]) {
		IMMsgType type = [rs intForColumn:@"msgtype"];
		
		
		NSString *msguserID = [rs stringForColumn:@"userid"];
		IMUserType msguserType = [rs intForColumn:@"usertype"];
		NSString *msgID = [rs stringForColumn:@"msgid"];
		
		IMMsg *cacheMsg = [self getCachedMsg:fromUser msgid:msgID];
		if (cacheMsg != nil) {
			[tmpArray addObject:cacheMsg];
			continue;
		}
		
		IMUser *msgUser = [_userMgr createCacheUserWithID:msguserID usertype:msguserType];
//		IMMsg *msg = [[IMMsg alloc]init];
//		msg.msgUser = msgUser;
//		msg.fromUser = fromUser;
//		msg.msgID = [rs stringForColumn:@"msgid"];
//		msg.msgType = type;
//		msg.msgBody = [rs stringForColumn:@"msgbody"];
//		msg.msgSize = [rs unsignedLongLongIntForColumn:@"msgsize"];
//		msg.msgAttach = [[rs stringForColumn:@"msgattach"] objectFromJSONString];
//		msg.readState = [rs intForColumn:@"readstate"];
//		msg.procState = [rs intForColumn:@"procstate"];
//		msg.playState = [rs intForColumn:@"playstate"];
//		msg.fromType = [rs boolForColumn:@"fromtype"];
//		msg.msgTime = [NSDate dateWithTimeIntervalSince1970:[rs unsignedLongLongIntForColumn:@"msgtime"]];
		
		IMMsg *msg = [IMMsgFactory handleMsgWithFromUser:fromUser msgUser:msgUser msgid:[rs stringForColumn:@"msgid"] msgTime:[NSDate dateWithTimeIntervalSince1970:[rs unsignedLongLongIntForColumn:@"msgtime"]] isDelay:NO msgBody:[rs stringForColumn:@"msgbody"] attach:[[rs stringForColumn:@"msgattach"] objectFromJSONString] msgType:type msgSize:[rs unsignedLongLongIntForColumn:@"msgsize"]  fromType:[rs intForColumn:@"fromtype"] readState:[rs intForColumn:@"readstate"] procState:[rs intForColumn:@"procstate"] playState:[rs intForColumn:@"playstate"]];
		
		[tmpArray addObject:msg];
	}
	
	[rs close];
	return tmpArray;
}

- (NSMutableArray *)getUserMsgWithSql:(NSString *)sql fromUser:(IMUser *)fromUser
{
	__block NSMutableArray *resultArray = nil;
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		resultArray = [self getUserMsginDB:db SQL:sql fromUser:fromUser];
	}];
	return resultArray;
}

- (void)updateWithSql:(NSString *)sql
{
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol
- (void)saveMsg:(IMMsg *)msg
{
	if(msg == nil || _dbQueue == nil)
		return;
	
	XMPPLogVerbose(@"save db:%@", msg);
	NSString *insertSql = [self makeMsgInsertSql:msg];
	__weak IMMsgStorage * wself = self;
	[_dbQueue inDatabase:^(FMDatabase *adb) {
		IMMsgStorage *sself = wself;
		BOOL suc = [adb executeUpdate:insertSql];
		if(suc == NO)
		{
			XMPPLogError(@"%d", [adb lastErrorCode]);
			if([adb lastErrorCode] == 1)
			{
				[sself createMsgTable:msg db:adb];
				[adb executeUpdate:insertSql];
			}
		}
		
	}];
}

- (void)delMsg:(IMMsg *)msg
{
	if(msg == nil || _dbQueue  == nil)
		return;
	
	NSString *tableName = [self tableNameForUser:msg.fromUser];
	
	NSString *sql = [NSString stringWithFormat:@"delete from `%@` where msgid = '%@'", tableName, msg.msgID];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}

- (void)delAllMsg:(IMUser *)user
{
	if (user == nil)
		return;
	NSString *tableName = [self tableNameForUser:user];
	
	NSString *sql = [NSString stringWithFormat:@"drop table `%@`", tableName];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}

- (NSMutableArray *)getUserLastMsg:(IMUser *)user count:(int)cnt
{
	NSString *tableName = [self tableNameForUser:user];
	
	NSString *sql = [NSString stringWithFormat:@"select msgid,userid,nickname,usertype,msgtype,msgbody,msgsize,msgattach,\
					 readstate,procstate,playstate,fromtype,msgtime,remotetime,inserttime from `%@` order by mid desc\
					 limit %d", tableName, cnt];
	NSMutableArray *resultArray = [self getUserMsgWithSql:sql fromUser:user];
	[resultArray reverse];
	return resultArray;
}

- (IMMsg *)getMessage:(IMUser *)user msgid:(NSString *)msgid db:(FMDatabase *)db
{
	
	NSString *tableName = [self tableNameForUser:user];
	
	NSString *sql = [NSString stringWithFormat:@"select msgid,userid,nickname,usertype,msgtype,msgbody,msgattach, \
					msgsize,readstate,procstate,playstate,fromtype,msgtime,remotetime,inserttime from `%@` where\
					msgid = '%@'", tableName, msgid];
	NSMutableArray *resultArray = [self getUserMsginDB:db SQL:sql fromUser:user];
	if (resultArray.count <= 0) {
		return nil;
	}
	return [resultArray objectAtIndex:0];
}

- (BOOL)msgExistwithMsgid:(NSString *)msgid user:(IMUser *)user
{
	__block BOOL flag = NO;
	__weak IMMsgStorage *wself = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		IMMsgStorage *sself = wself;
		if ([sself getMessage:user msgid:msgid db:db] != nil)
		{
			flag = YES;
		}
	}];
	return flag;
}

- (NSMutableArray *)getUserOlderMsg:(IMUser *)user msgid:(NSString *)msgid count:(int)cnt
{
	NSString *tableName = [self tableNameForUser:user];
	NSInteger mid = [self getMidWithMsgid:msgid tableName:tableName];
	if(mid < 0)
		return nil;
	
	NSString *sql = [NSString stringWithFormat:@"select msgid,userid,nickname,usertype,msgtype,msgbody,msgsize,\
				msgattach,readstate,procstate,playstate,fromtype,msgtime,remotetime,inserttime from `%@` where\
					 mid < %d order by mid desc limit %d", tableName, mid,cnt];
	NSMutableArray *resultArray = [self getUserMsgWithSql:sql fromUser:user];
	[resultArray reverse];
	return resultArray;
}

//update
- (void)updateMsgState:(IMMsg *)msg
{
	if(msg == nil)
		return;
	NSString *tableName = [self tableNameForMsg:msg];
	NSString *sql = [NSString stringWithFormat:@"update `%@` set readstate = %d, procstate = %d, playstate = %d where\
					 msgid = '%@'", tableName, msg.readState, msg.procState, msg.playState, msg.msgID];
	[self updateWithSql:sql];
}

- (void)updateMsgAttach:(IMMsg *)msg
{
	if (msg == nil)
		return;
	
	NSString *tableName = [self tableNameForMsg:msg];
	NSString *sql = [NSString stringWithFormat:@"update `%@` set msgattach = '%@' where msgid = '%@'",
					 tableName, [msg.msgAttach JSONString], msg.msgID];
	[self updateWithSql:sql];
}

- (void)updateMsgBody:(IMMsg *)msg
{
	if (msg == nil)
		return;
	
	NSString *tableName = [self tableNameForMsg:msg];
	NSString *sql = [NSString stringWithFormat:@"update `%@` set msgbody = '%@' where msgid = '%@'",
					 tableName, msg.msgBody, msg.msgID];
	[self updateWithSql:sql];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - ChatSession
- (void)createChatSessionTable:(FMDatabase *)db
{
	NSString *sql = @"create table chatsession(\
	mid integer PRIMARY KEY autoincrement, \
	tbver integer default 1,\
	userid varchar(128) UNIQUE default '',\
	nickname varchar(128) default '',\
	usertype integer default 0,\
	lastmsgid varchar(128) default '', \
	unreadnum integer default 0,\
	updatetime integer,\
	createtime integer)";
	[db executeUpdate:sql];
	
	sql = [NSString stringWithFormat:@"create index userid_index on chatsession(userid)"];
    [db executeUpdate:sql];
	sql = [NSString stringWithFormat:@"create index updatetime_index on chatsession(updatetime)"];
    [db executeUpdate:sql];
}

- (NSString *)makeChatRecordInsertSql:(IMMsg *)msg
{
	int num = 1;
	if(msg.fromType != IMMsgFromOther || msg.readState == IMMsgReadStateReaded)
		num = 0;
	
	NSString *sql = [NSString stringWithFormat:@"insert into chatsession(userid, nickname, usertype, lastmsgid,\
					 unreadnum, updatetime, createtime) values('%@','%@',%d, '%@', %d, %lu, %lu)",
					 msg.fromUser.userID, msg.fromUser.nickname, msg.fromUser.userType, msg.msgID, num,
					 (unsigned long)[msg.msgTime timeIntervalSince1970], time(NULL)];
	return sql;
}

- (NSString *)makeChatRecordUpdateSql:(IMMsg *)msg
{
	NSString *sql = nil;
	if(msg.fromType == IMMsgFromLocalSelf || msg.readState == IMMsgReadStateReaded)
	{
		sql = [NSString stringWithFormat:@"update chatsession set nickname='%@', lastmsgid='%@', unreadnum=0,\
			   updatetime=%lu where userid='%@'", msg.fromUser.nickname, msg.msgID,
			   (unsigned long)[msg.msgTime timeIntervalSince1970], msg.fromUser.userID];
	}
	else if(msg.fromType == IMMsgFromRemoteSelf)
	{
		sql = [NSString stringWithFormat:@"update chatsession set nickname='%@', lastmsgid='%@',updatetime=%lu\
			   where userid='%@'", msg.fromUser.nickname, msg.msgID,  (unsigned long)[msg.msgTime timeIntervalSince1970],
			   msg.fromUser.userID];
	}
	else
	{
		sql = [NSString stringWithFormat:@"update chatsession set nickname='%@', lastmsgid='%@', unreadnum=unreadnum+1,\
			   updatetime=%lu where userid='%@'", msg.fromUser.nickname, msg.msgID,
			   (unsigned long)[msg.msgTime timeIntervalSince1970], msg.fromUser.userID];
	}
	return sql;
}

- (BOOL)hasChatRecord:(IMUser *)user
{
	NSString *sql = [NSString stringWithFormat:@"select userid from chatsession where userid = '%@'", user.userID];
	__block BOOL flag = NO;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		if([rs next])
			flag = YES;
		[rs close];
	}];
	return flag;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)delAllChatSession
{
	NSArray *sessions = [self getChatSessionList:0];
	for (IMChatSession *se in sessions) {
		[self delChatSession:se.fromUser];
	}
}

//delete msg table and session 
- (void)delChatSession:(IMUser *)user
{
	NSString *sql = [NSString stringWithFormat:@"delete from chatsession where userid = '%@'", user.userID];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
	
	NSString *tableName = [self tableNameForUser:user];
	sql = [NSString stringWithFormat:@"drop table `%@`", tableName];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}

//delete msg table and reset session content
- (void)clearChatSessionContent:(IMUser *)user
{
	NSString *sql = [NSString stringWithFormat:@"update chatsession set unreadnum=0, lastmsgid = '' where userid = '%@'", user.userID];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
	
	NSString *tableName = [self tableNameForUser:user];
	sql = [NSString stringWithFormat:@"drop table `%@`", tableName];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
		[db commit];
	}];
}

- (void)addChatSession:(IMMsg *)msg
{
	if (msg == nil)
		return;
	
	NSString *insertSql = nil;
	if([self hasChatRecord:msg.fromUser])
	{
		insertSql = [self makeChatRecordUpdateSql:msg];
	}
	else
	{
		insertSql = [self makeChatRecordInsertSql:msg];
	}
	__weak IMMsgStorage *wself = self;
	
	[_dbQueue inDatabase:^(FMDatabase *adb) {
		IMMsgStorage *sself = wself;
		BOOL suc = [adb executeUpdate:insertSql];
		if(suc == NO)
		{
			if([adb lastErrorCode] == 1)
			{
				[sself createChatSessionTable:adb];
				[adb executeUpdate:insertSql];
			}
		}
		
	}];
}

- (NSMutableArray *)getChatSessionList:(NSInteger)cnt
{
	NSString *sql = [NSString stringWithFormat:@"select userid, nickname, usertype, lastmsgid, unreadnum, updatetime\
					 from chatsession order by updatetime desc limit %d", cnt];
	
	if (cnt == 0) {
		sql = [NSString stringWithFormat:@"select userid, nickname, usertype, lastmsgid, unreadnum, updatetime from\
			   chatsession order by updatetime desc"];
	}
	
	__block NSMutableArray *resultArray = nil;
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		
		NSMutableArray *tmpArray = [NSMutableArray array];
		FMResultSet *rs = [db executeQuery:sql];
		while ([rs next]) {
			IMChatSession *chatSession = [[IMChatSession alloc]init];
			
			NSString *userid = [rs stringForColumn:@"userid"];
			NSString *nickName = [rs stringForColumn:@"nickname"];
			IMUserType userType = [rs intForColumn:@"usertype"];
			chatSession.fromUser = [_userMgr createCacheUserWithID:userid usertype:userType nikename:nickName];
			chatSession.unreadNum = [rs intForColumn:@"unreadnum"]; 
			
			NSString *lastMsgid = [rs stringForColumn:@"lastmsgid"];
			
			//search cache first
			IMMsg *cacheMsg = [self getCachedMsg:chatSession.fromUser msgid:lastMsgid];
			if (cacheMsg) {
				chatSession.msg = cacheMsg;
			}
			else {
				chatSession.msg = [self getMessage:chatSession.fromUser msgid:lastMsgid db:db];
				[_msgMgr addSessionMsgWithUser:chatSession.fromUser msg:chatSession.msg];
			}
			
			[tmpArray addObject:chatSession];
		}
		
		[rs close];
		resultArray = tmpArray;
	}];
	return resultArray;
}

- (NSUInteger)unreadTotalNum
{
	NSString *sql = [NSString stringWithFormat:@"select sum(unreadnum) as b from chatsession where unreadnum>0"];
	__block NSInteger num = 0;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		if([rs next])
			num = [rs intForColumn:@"b"];
		[rs close];
	}];
	return num;
}

- (NSMutableArray *)searchUsersInChatSessionWithKeyword:(NSString *)keywrod
{
	NSString *sql = [NSString stringWithFormat:@"select userid, nickname, usertype from chatsession where nickname \
					 like '%%%@%%'", keywrod];
	
	__block NSMutableArray *resultArray = nil;
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		
		NSMutableArray *tmpArray = [NSMutableArray array];
		FMResultSet *rs = [db executeQuery:sql];
		while ([rs next]) {
			NSString *userid = [rs stringForColumn:@"userid"];
			NSString *nickName = [rs stringForColumn:@"nickname"];
			IMUserType userType = [rs intForColumn:@"usertype"];
			
			IMUser *user = [_userMgr createCacheUserWithID:userid usertype:userType nikename:nickName];
			
			[tmpArray addObject:user];
		}
		
		[rs close];
		resultArray = tmpArray;
	}];
	return resultArray;
}

- (void)setAllMsgReaded:(IMUser *)user
{
	NSString *sql = [NSString stringWithFormat:@"update chatsession set unreadnum=0 where userid = '%@'", user.userID];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IMMsgProcState)getFrinedCenterProcStateWithUser:(IMUser *)user
{
	IMUser *friendCenter = [IMUser friendCenterUser];
	NSString *tableName = [self tableNameForUser:friendCenter];
	NSString *sql = [NSString stringWithFormat:@"select procstate from `%@` where userid = '%@' order by mid desc limit 1", tableName, user.userID];
	__block IMMsgProcState st = -1;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs;
		rs = [db executeQuery:sql];
		if([rs next])
		{
			st = [rs intForColumn:@"procstate"];
		}
		[rs close];
	}];
	return st;
}

- (void)updateFriendCenterProcState:(IMMsgProcState)state withUser:(IMUser *)user
{
	IMUser *friendCenter = [IMUser friendCenterUser];
	NSString *tableName = [self tableNameForUser:friendCenter];
	NSString *sql = [NSString stringWithFormat:@"update `%@` set procstate = %d where userid = '%@'", tableName, state, user.userID];
	[self updateWithSql:sql];
}
@end
