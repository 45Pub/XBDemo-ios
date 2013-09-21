// XMPPSqlStorage.m
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

#import "XMPPSqlStorage.h"
#import "XMPPStream.h"
#import "XMPPInternal.h"
#import "XMPPJID.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPSqlStorage

- (instancetype)initWithdbQueue:(FMDatabaseQueue *)dbQueue
{
	self = [super init];
	if (self)
	{
		_dbQueue = dbQueue;
	}
	return self;
}
@end
