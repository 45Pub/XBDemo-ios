// XMPPvCardStorageObject.h
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

#import <Foundation/Foundation.h>
#import "XMPP.h"

@class XMPPvCardTemp;

@interface XMPPvCardStorageObject : NSObject

/*
 *  User's JID, indexed for lookups
 */
@property (nonatomic, strong) NSString * jidStr;

/*
 *  User's photoHash used by XEP-0153
 */
@property (nonatomic, strong) NSString * photoHash;

/*
 *  The last time the record was modified, also used to determine if we need to fetch again
 */
@property (nonatomic, strong) NSDate * lastUpdated;


/*
 *  Flag indicating whether a get request is already pending, used in conjunction with lastUpdated
 */
@property (nonatomic, assign) BOOL waitingForFetch;


/*
 *  Accessor to retrieve photoData, so we can hide the underlying relationship implementation.
 */
@property (nonatomic, strong) NSData *photoData;


/*
 *  Accessor to retrieve vCardTemp, so we can hide the underlying relationship implementation.
 */
@property (nonatomic, strong) XMPPvCardTemp *vCardTemp;


+ (NSString *)vCardDbPath;

+(NSString *)vCardPhotoSavePath:(NSString *)jidstr;

+ (XMPPvCardTemp *)readvCardTemp:(XMPPJID *)jid;
+ (void)removevCardTempForJid:(XMPPJID *)jid;
+ (void)writevCardTemp:(XMPPvCardTemp *)vCardTemp forJid:(XMPPJID *)jid;
@end
