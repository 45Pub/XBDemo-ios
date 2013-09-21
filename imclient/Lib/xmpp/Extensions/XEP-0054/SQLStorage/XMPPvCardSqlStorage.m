// XMPPvCardSqlStorage.m
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

#import "XMPPvCardSqlStorage.h"
#import "XMPPvCardStorageObject.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "XMPPLogging.h"
#import "XMPP.h"
#import "XMPPvCardTemp.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_OFF;
#endif

enum {
	kXMPPvCardTempNetworkFetchTimeout = 10,
};


@implementation XMPPvCardSqlStorage



- (id)init
{
	self = [super init];
	if (self)
	{
		_dbQueue = [FMDatabaseQueue databaseQueueWithPath:[XMPPvCardStorageObject vCardDbPath]];
	}
	return self;
}

#pragma mark -

- (void)createvCardTable:(FMDatabase *)db
{
	NSString *sql = @"create table vCard(\
					mid integer PRIMARY KEY autoincrement, \
					ver integer default 0,\
					barejid varchar(255) UNIQUE default '',\
					lastupdate integer default 0,\
					waitfetch integer default 0,\
					photohash varchar(255) default '')";

	[db executeUpdate:sql];
	sql = [NSString stringWithFormat:@"create index vCard_userid_index on vCard(barejid)"];
    [db executeUpdate:sql];
}




#pragma mark -

- (XMPPvCardStorageObject *)vCardObjectForBareJidStr:(NSString *)bareJid
{
	NSString *sql = [NSString stringWithFormat:@"select lastupdate, waitfetch, photohash from vCard where barejid = '%@'", bareJid];
	
	__block XMPPvCardStorageObject *vCard = nil;
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:sql];
		if ([rs next])
		{
			vCard = [[XMPPvCardStorageObject alloc]init];
			vCard.jidStr = bareJid;
			vCard.lastUpdated = [rs dateForColumn:@"lastupdate"];
			vCard.waitingForFetch = [rs boolForColumn:@"waitfetch"];
			vCard.photoHash = [rs stringForColumn:@"photohash"];
			
		}
		[rs close];
	}];
	return vCard;
}

- (void)updatevCard:(XMPPvCardStorageObject *)vCard saveTemp:(BOOL)bSave
{
	NSString *sql = [NSString stringWithFormat:@"update vCard set lastupdate = %llu, waitfetch = %d, photohash = '%@' where barejid = '%@'", (unsigned long long)[vCard.lastUpdated timeIntervalSince1970], vCard.waitingForFetch, vCard.photoHash, vCard.jidStr];
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
	

	if (bSave)
	{
		XMPPJID *jid = [XMPPJID jidWithString:vCard.jidStr];
		[XMPPvCardStorageObject writevCardTemp:vCard.vCardTemp forJid:jid];
		
		if (vCard.vCardTemp.photo.length > 0)
		{
			NSString *photoPath = [XMPPvCardStorageObject vCardPhotoSavePath:[jid bare]];
			[vCard.vCardTemp.photo writeToFile:photoPath atomically:YES];
		}
	}
}

- (void)savevCard:(XMPPvCardStorageObject *)vCard saveTemp:(BOOL)bSave
{
	NSString *sql = [NSString stringWithFormat:@"insert into vCard(barejid, lastupdate, waitfetch, photohash) values('%@', %llu, %d, '%@')", vCard.jidStr, (unsigned long long)[vCard.lastUpdated timeIntervalSince1970], vCard.waitingForFetch, vCard.photoHash];
	
	__weak XMPPvCardSqlStorage* wself = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		XMPPvCardSqlStorage *sself = wself;
		BOOL suc = [db executeUpdate:sql];
		if (!suc)
		{
			if ([db lastErrorCode] == 1)
			{
				[sself createvCardTable:db];
				[db executeUpdate:sql];
			}
		}
	}];
	
	
	if (bSave)
	{
		XMPPJID *jid = [XMPPJID jidWithString:vCard.jidStr];
		[XMPPvCardStorageObject writevCardTemp:vCard.vCardTemp forJid:jid];
		
		if (vCard.vCardTemp.photo.length > 0)
		{
			NSString *photoPath = [XMPPvCardStorageObject vCardPhotoSavePath:[jid bare]];
			[vCard.vCardTemp.photo writeToFile:photoPath atomically:YES];
		}
	}
}
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPvCardTempModule Protocol -
- (BOOL)configureWithParent:(XMPPvCardTempModule *)aParent queue:(dispatch_queue_t)queue
{
	return YES;
}

- (XMPPvCardTemp *)vCardTempForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
	XMPPLogTrace();
	
	XMPPvCardTemp *vCardTemp = [XMPPvCardStorageObject readvCardTemp:jid];
	return vCardTemp;
}
/**
 * Used to set the vCardTemp object when we get it from the XMPP server.
 **/
- (void)setvCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
	XMPPLogTrace();
	
	
	XMPPvCardStorageObject *vCard = [self vCardObjectForBareJidStr:[jid bare]];
	BOOL flag = NO;
	if (vCard == nil)
	{
		vCard = [[XMPPvCardStorageObject alloc]init];
		flag = YES;
	}
	vCard.waitingForFetch = NO;
	vCard.vCardTemp = vCardTemp;
	vCard.jidStr = [jid bare];
	// Update photo and photo hash
	vCard.photoData = vCardTemp.photo;
	
	vCard.lastUpdated = [NSDate date];
	
	if (flag)
	{
		[self savevCard:vCard saveTemp:YES];
	}
	else
		[self updatevCard:vCard saveTemp:YES];
}

/**
 * Returns My vCardTemp object or nil
 **/
- (XMPPvCardTemp *)myvCardTempForXMPPStream:(XMPPStream *)stream
{
	return [XMPPvCardStorageObject readvCardTemp:[stream myJID]];
}

/**
 * Asks the backend if we should fetch the vCardTemp from the network.
 * This is used so that we don't request the vCardTemp multiple times.
 **/
- (BOOL)shouldFetchvCardTempForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
	XMPPLogTrace();
	
	BOOL result = NO;
	
	XMPPvCardStorageObject *vCard = [self vCardObjectForBareJidStr:[jid bare]];
	
	if (vCard == nil)
	{
		result = YES;
	}
	else if(!vCard.waitingForFetch)
	{
		if ([jid isEqualToJID:[stream myJID] options:XMPPJIDCompareBare])
		{
			if ([vCard.lastUpdated timeIntervalSinceNow] < - 30 * 60)
			{
				result = YES;
			}
		}
		else
		{
			if ([vCard.lastUpdated timeIntervalSinceNow] < -60 * 60)
			{
				result = YES;
			}
		}
		
	}
	else if([vCard.lastUpdated timeIntervalSinceNow] < -kXMPPvCardTempNetworkFetchTimeout)
	{
		result = YES;
	}
	
	if (![stream isAuthenticated])
	{
		result = NO;
	}
	
	if (result)
	{
		if (!vCard)
		{
			vCard = [[XMPPvCardStorageObject alloc]init];
			vCard.jidStr = [jid bare];
			vCard.lastUpdated = [NSDate date];
			vCard.waitingForFetch = YES;
			[self savevCard:vCard saveTemp:NO];
		}
		else
		{
			vCard.lastUpdated = [NSDate date];
			vCard.waitingForFetch = YES;
			[self updatevCard:vCard saveTemp:NO];
		}
	}
	
	return result;
}

#pragma mark - XMPPAvatar -
- (NSData *)photoDataForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
	NSString *photoPath = [XMPPvCardStorageObject vCardPhotoSavePath:[jid bare]];
	NSData *data = [NSData dataWithContentsOfFile:photoPath];
	return data;
}

- (NSString *)photoHashForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
	XMPPvCardStorageObject *vCard = [self vCardObjectForBareJidStr:[jid bare]];
	return vCard.photoHash;
}

/**
 * Clears the vCardTemp from the store.
 * This is used so we can clear any cached vCardTemp's for the JID.
 **/
- (void)clearvCardTempForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
	NSString *sql = [NSString stringWithFormat:@"delete from vCard where barejid = '%@'", [jid bare]];
	
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
	
	[XMPPvCardStorageObject removevCardTempForJid:jid];
}


@end
