// XMPPCapabilityiesSqlStorage.m
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

#import "XMPPCapabilitiesSqlStorage.h"
#import "XMPPCapaStorageObject.h"
#import "XMPPCapaResourceStorageObject.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "FMDatabase.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
  static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPCapabilitiesSqlStorage



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)configureWithParent:(XMPPCapabilities *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createCapaTable:(FMDatabase *)db
{
    NSString *sql = @"create table capability(\
                    mid integer PRIMARY KEY autoincrement, \
					ver integer default 0,\
					hashstr varchar(255) default '',\
                    hashalgo varchar(255) default '',\
                    capabilitystr varchar(255) default '')";

    [db executeUpdate:sql];
}

- (void)createCapaResourceTable:(FMDatabase *)db
{
    NSString *sql = @"create table caparesource(\
                    mid integer PRIMARY KEY autoincrement, \
					ver integer default 0,\
                    jidstr varchar(255) default '',\
                    havefailed integer default 0,\
                    node varchar(255) default '',\
                    verstr varchar(255) default '',\
                    ext varchar(255) default '',\
					hashstr varchar(255) default '',\
                    hashalgo varchar(255) default '')";

    [db executeUpdate:sql];

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)escapNilToSpace:(NSString *)str
{
	return str == nil ? @"":str;
}

- (NSArray *)AllResources
{
    __block NSMutableArray *array = nil;
	
    NSString *sql = [NSString stringWithFormat:@"select jidstr, havefailed,node, verstr, ext, hashstr, hashalgo from caparesource"];
	
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        array = [[NSMutableArray alloc]init];
        while ([rs next])
        {
            XMPPCapaResourceStorageObject *resource = [[XMPPCapaResourceStorageObject alloc] init];
            resource.jidStr = [rs stringForColumn:@"jidstr"];
            resource.haveFailed = [rs boolForColumn:@"havefailed"];
            resource.node = [rs stringForColumn:@"node"];
            resource.ver = [rs stringForColumn:@"verstr"];
            resource.ext = [rs stringForColumn:@"ext"];
            resource.hashStr = [rs stringForColumn:@"hashstr"];
            resource.hashAlgorithm = [rs stringForColumn:@"hashalgo"];
			[array addObject:resource];
        }
        [rs close];
    }];
	
    return array;
}

- (NSArray *)resourcesForJID:(XMPPJID *)jid
{
    __block NSMutableArray *array = nil;

    NSString *sql = [NSString stringWithFormat:@"select havefailed,node, verstr, ext, hashstr, hashalgo from caparesource where jidstr = '%@'", [jid full]];

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        array = [[NSMutableArray alloc]init];
        while ([rs next])
        {
            XMPPCapaResourceStorageObject *resource = [[XMPPCapaResourceStorageObject alloc] init];
            resource.jidStr = [jid full];
            resource.haveFailed = [rs boolForColumn:@"havefailed"];
            resource.node = [rs stringForColumn:@"node"];
            resource.ver = [rs stringForColumn:@"verstr"];
            resource.ext = [rs stringForColumn:@"ext"];
            resource.hashStr = [rs stringForColumn:@"hashstr"];
            resource.hashAlgorithm = [rs stringForColumn:@"hashalgo"];
           [array addObject:resource];
        }
        [rs close];
    }];

    return array;
}

- (void)removeResourceWithJID:(XMPPJID *)jid
{
    NSString *sql = [NSString stringWithFormat:@"delete from caparesource where jidstr = '%@'", [jid full]];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)addResource:(XMPPCapaResourceStorageObject *)resource
{
    NSString *sql = [NSString stringWithFormat:@"insert into caparesource(jidstr, havefailed, node, verstr, ext, hashstr, hashalgo) values('%@', %d, '%@', '%@', '%@', '%@', '%@')", resource.jidStr, resource.haveFailed, resource.node, resource.ver, resource.ext, [self escapNilToSpace:resource.hashStr],[self  escapNilToSpace:resource.hashAlgorithm]];

    __weak XMPPCapabilitiesSqlStorage* wself = self;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        XMPPCapabilitiesSqlStorage *sself = wself;
        BOOL suc = [db executeUpdate:sql];
        if (!suc)
        {
            if ([db lastErrorCode] == 1)
            {
                [sself createCapaResourceTable:db];
                [db executeUpdate:sql];
            }
        }
    }];
}



- (XMPPCapaResourceStorageObject *)resourceForJID:(XMPPJID *)jid
{
    NSString *sql = [NSString stringWithFormat:@"select havefailed,node, verstr, ext, hashstr, hashalgo from caparesource where jidstr = '%@' order by mid desc limit 1", [jid full]];

    __block XMPPCapaResourceStorageObject *resource = nil;

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next])
        {
            resource = [[XMPPCapaResourceStorageObject alloc] init];
            resource.jidStr = [jid full];
            resource.haveFailed = [rs boolForColumn:@"havefailed"];
            resource.node = [rs stringForColumn:@"node"];
            resource.ver = [rs stringForColumn:@"verstr"];
            resource.ext = [rs stringForColumn:@"ext"];
            resource.hashStr = [rs stringForColumn:@"hashstr"];
            resource.hashAlgorithm = [rs stringForColumn:@"hashalgo"];

        }
        [rs close];
    }];

    return resource;
}

- (XMPPCapaStorageObject *)capsForHash:(NSString *)hash algorithm:(NSString *)hashAlg
{
    XMPPLogTrace2(@"%@: capsForHash:%@ algorithm:%@", THIS_FILE, hash, hashAlg);

    if (hash == nil) return nil;
    if (hashAlg == nil) return nil;

    __block XMPPCapaStorageObject *caps = nil;

    NSString *sql = [NSString stringWithFormat:@"select capabilitystr from capability where hashstr ='%@' and hashalgo = '%@'", hash, hashAlg];

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next])
        {
            caps = [[XMPPCapaStorageObject alloc] init];
            caps.hashStr = hash;
            caps.hashAlgorithm = hashAlg;
            caps.capabilitiesStr = [rs stringForColumn:@"capabilitystr"];
        }
    }];

    return caps;
}

- (void)removeCapaStorageObjectForHash:(NSString *)hash algorithm:(NSString *)hashAlg
{
	if (hash == nil || hashAlg == nil)
	{
		return;
	}
	
	
	NSString *sql = [NSString stringWithFormat:@"delete from capability where hashstr = '%@' and hashalgo = '%@'", hash, hashAlg];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
}

- (void)addCapaStoreageObjectForHash:(NSString *)hash algorithm:(NSString *)hashAlg capabilitystr:(NSString *)capastr
{
	
	NSString *sql = [NSString stringWithFormat:@"insert into capability(hashstr, hashalgo, capabilitystr) values('%@','%@','%@')",
					 hash, hashAlg, capastr];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql];
	}];
	
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)_clearAllNonPersistentCapabilitiesForXMPPStream:(XMPPStream *)stream
{
	
	NSArray *reuslts = [self AllResources];
	for (XMPPCapaResourceStorageObject *resource in reuslts)
	{
		NSString *hash = resource.hashStr;
		NSString *hashAlg = resource.hashAlgorithm;
		
		BOOL nonPersistentCapabilities = ((hash.length <= 0) || (hashAlg.length <= 0));
		
		if (nonPersistentCapabilities)
		{
			[self removeCapaStorageObjectForHash:hash algorithm:hashAlg];
		}
		[self removeResourceWithJID:[XMPPJID jidWithString:resource.jidStr]];
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol -
- (BOOL)areCapabilitiesKnownForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();

    BOOL result = NO;
    XMPPCapaResourceStorageObject *resource = [self resourceForJID:jid];
    XMPPCapaStorageObject *caps = [self capsForHash:resource.hashStr algorithm:resource.hashAlgorithm];
    if (resource && caps)
        result = YES;

    return result;

}

- (NSXMLElement *)capabilitiesForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();

    return [self capabilitiesForJID:jid ext:nil xmppStream:stream];
}

- (NSXMLElement *)capabilitiesForJID:(XMPPJID *)jid ext:(NSString **)extPtr xmppStream:(XMPPStream *)stream
{
    // By design this method should not be invoked from the storageQueue.
//    NSAssert(!dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");

    XMPPLogTrace();

    __block NSXMLElement *result = nil;
    __block NSString *ext = nil;

	XMPPCapaResourceStorageObject *resource = [self resourceForJID:jid];
	if (resource)
	{
		XMPPCapaStorageObject *cap = [self capsForHash:resource.hashStr algorithm:resource.hashAlgorithm];
		if (cap)
		{
			result = [cap capabilities];
			ext = [resource ext];
		}
	}

    if (extPtr)
        *extPtr = ext;

    return result;
}

- (BOOL)setCapabilitiesNode:(NSString *)node
                        ver:(NSString *)ver
                        ext:(NSString *)ext
                       hash:(NSString *)hash
                  algorithm:(NSString *)hashAlg
                     forJID:(XMPPJID *)jid
                 xmppStream:(XMPPStream *)stream
      andGetNewCapabilities:(NSXMLElement **)newCapabilitiesPtr
{

    XMPPLogTrace();

    __block BOOL result = NO;
    __block NSXMLElement *newCapabilities = nil;

	XMPPCapaResourceStorageObject *resource = [[XMPPCapaResourceStorageObject alloc]init];
	resource.jidStr = [jid full];
	resource.node = node;
	resource.ver = ver;
	resource.ext = ext;
	resource.hashStr = hash;
	resource.hashAlgorithm = hashAlg;
	
	[self removeResourceWithJID:jid];
	[self addResource:resource];
	
	XMPPCapaStorageObject *cap = [self capsForHash:hash algorithm:hashAlg];
	newCapabilities = [cap capabilities];
	if (newCapabilities)
	{
		if (newCapabilitiesPtr)
			*newCapabilitiesPtr = newCapabilities;
	}
	
	if (cap)
	{
		result = YES;
	}
	
    return result;
}

- (BOOL)getCapabilitiesHash:(NSString **)hashPtr
                  algorithm:(NSString **)hashAlgPtr
                     forJID:(XMPPJID *)jid
                 xmppStream:(XMPPStream *)stream
{
    // By design this method should not be invoked from the storageQueue.
//    NSAssert(!dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");

    XMPPLogTrace();

    __block BOOL result = NO;
    __block NSString *hash = nil;
    __block NSString *hashAlg = nil;

	XMPPCapaResourceStorageObject *resource = [self resourceForJID:jid];
	if (resource)
	{
		hash = resource.hashStr;
		hashAlg = resource.hashAlgorithm;
		result = (hash.length>0 && hashAlg.length>0);
	}

    if (hashPtr)
        *hashPtr = hash;

    if (hashAlgPtr)
        *hashAlgPtr = hashAlg;

    return result;
}

- (void)clearCapabilitiesHashAndAlgorithmForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
	
	XMPPCapaResourceStorageObject	*resource = [self resourceForJID:jid];
	if (resource)
	{
		[self removeCapaStorageObjectForHash:resource.hashStr algorithm:resource.hashAlgorithm];
		resource.hashStr = nil;
		resource.hashAlgorithm = nil;
		
		[self removeResourceWithJID:jid];
		[self addResource:resource];
	}
}

- (void)getCapabilitiesKnown:(BOOL *)areCapabilitiesKnownPtr
                      failed:(BOOL *)haveFailedFetchingBeforePtr
                        node:(NSString **)nodePtr
                         ver:(NSString **)verPtr
                         ext:(NSString **)extPtr
                        hash:(NSString **)hashPtr
                   algorithm:(NSString **)hashAlgPtr
                      forJID:(XMPPJID *)jid
                  xmppStream:(XMPPStream *)stream
{
    // By design this method should not be invoked from the storageQueue.
//    NSAssert(!dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");

    XMPPLogTrace();

    __block BOOL areCapabilitiesKnown = NO;
    __block BOOL haveFailedFetchingBefore = NO;
    __block NSString *node    = nil;
    __block NSString *ver     = nil;
    __block NSString *ext     = nil;
    __block NSString *hash    = nil;
    __block NSString *hashAlg = nil;

    

	XMPPCapaResourceStorageObject *resource = [self resourceForJID:jid];

	if (resource == nil)
	{
		// We don't know anything about the given jid

		areCapabilitiesKnown = NO;
		haveFailedFetchingBefore = NO;

		node    = nil;
		ver     = nil;
		ext     = nil;
		hash    = nil;
		hashAlg = nil;
	}
	else
	{
		XMPPCapaStorageObject *caps = [self capsForHash:resource.hashStr algorithm:resource.hashAlgorithm];
		areCapabilitiesKnown = (caps != nil);
		haveFailedFetchingBefore = resource.haveFailed;

		node    = resource.node;
		ver     = resource.ver;
		ext     = resource.ext;
		hash    = resource.hashStr;
		hashAlg = resource.hashAlgorithm;
	}

  

    if (areCapabilitiesKnownPtr)     *areCapabilitiesKnownPtr     = areCapabilitiesKnown;
    if (haveFailedFetchingBeforePtr) *haveFailedFetchingBeforePtr = haveFailedFetchingBefore;

    if (nodePtr)    *nodePtr    = node;
    if (verPtr)     *verPtr     = ver;
    if (extPtr)     *extPtr     = ext;
    if (hashPtr)    *hashPtr    = hash;
    if (hashAlgPtr) *hashAlgPtr = hashAlg;
}

- (void)setCapabilities:(NSXMLElement *)capabilities forHash:(NSString *)hash algorithm:(NSString *)hashAlg
{
    XMPPLogTrace();

    if (hash == nil) return;
    if (hashAlg == nil) return;

	[self removeCapaStorageObjectForHash:hash algorithm:hashAlg];
	[self addCapaStoreageObjectForHash:hash algorithm:hashAlg capabilitystr:[capabilities compactXMLString]];
}

- (void)setCapabilities:(NSXMLElement *)capabilities forJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    // By design this method should not be invoked from the storageQueue.
//    NSAssert(!dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");

    XMPPLogTrace();

    if (jid == nil) return;

	XMPPCapaResourceStorageObject *resource = [self resourceForJID:jid];
	[self removeCapaStorageObjectForHash:resource.hashStr algorithm:resource.hashAlgorithm];
	[self addCapaStoreageObjectForHash:resource.hashStr algorithm:resource.hashAlgorithm capabilitystr:[capabilities compactXMLString]];
    }

- (void)setCapabilitiesFetchFailedForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();

	XMPPCapaResourceStorageObject *resource = [self resourceForJID:jid];
	resource.haveFailed = YES;
	[self removeResourceWithJID:jid];
	[self addResource:resource];
   
}

- (void)clearAllNonPersistentCapabilitiesForXMPPStream:(XMPPStream *)stream
{
    // This method is called for the protocol,
    // but is also called when we first load the database file from disk.

    XMPPLogTrace();
	[self _clearAllNonPersistentCapabilitiesForXMPPStream:stream];
}

- (void)clearNonPersistentCapabilitiesForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();

	XMPPCapaResourceStorageObject *resource = [self resourceForJID:jid];
	if (resource != nil)
	{
		if (resource.hashStr.length > 0 && resource.hashAlgorithm.length > 0)
		{
				
		}
		else
		{
			[self removeCapaStorageObjectForHash:resource.hashStr algorithm:resource.hashAlgorithm];
		}
		[self removeResourceWithJID:jid];
	}
	
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
