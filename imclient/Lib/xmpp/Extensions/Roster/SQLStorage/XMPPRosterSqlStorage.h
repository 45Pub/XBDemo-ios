// XMPPRosterSqlStorage.h
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
#import "XMPPRoster.h"
#import "XMPPUserObject.h"
#import "XMPPResourceObject.h"
#import "XMPPGroupObject.h"

@interface XMPPRosterSqlStorage : XMPPSqlStorage <XMPPRosterStorage>
{
#if __has_feature(objc_arc_weak)
	__weak XMPPRoster *parent;
#else
	__unsafe_unretained XMPPRoster *parent;
#endif
	dispatch_queue_t parentQueue;
	void *parentQueueTag;
	NSMutableSet *rosterPopulationSet;
}




- (XMPPUserObject *)userForJidStr:(NSString *)bareJid;

- (NSArray *)allUsers;
- (NSArray *)searchUsersWithKey:(NSString *)key;
@end




@protocol XMPPRosterSqlStorageDelegate
@optional

/**
 * The XMPPRosterStorage classes use the same delegate as their parent XMPPRoster.
 **/

/**
 * Catch-all change notification.
 *
 * When the roster changes, for any of the reasons listed below, this delegate method fires.
 * This method always fires after the more precise delegate methods listed below.
 **/
- (void)xmppRosterDidChange:(XMPPRosterSqlStorage *)sender;

/**
 * Notification that the roster has received the roster from the server.
 *
 * If parent.autoFetchRoster is YES, the roster will automatically be fetched once the user authenticates.
 **/
- (void)xmppRosterDidPopulate:(XMPPRosterSqlStorage *)sender;

/**
 * Notifications that the roster has changed.
 *
 * This includes times when users are added or removed from our roster, or when a nickname is changed,
 * including when other resources logged in under the same user account as us make changes to our roster.
 *
 * This does not include when resources simply go online / offline.
 **/
- (void)xmppRoster:(XMPPRosterSqlStorage *)sender didAddUser:(NSString *)userJid;
- (void)xmppRoster:(XMPPRosterSqlStorage *)sender didUpdateUser:(NSString *)userJid;
- (void)xmppRoster:(XMPPRosterSqlStorage *)sender didRemoveUser:(NSString *)userJid;

/**
 * Notifications when resources go online / offline.
 **/
- (void)xmppRoster:(XMPPRosterSqlStorage *)sender
    didAddResource:(XMPPResourceObject *)resource
          withUser:(NSString *)userJid;

- (void)xmppRoster:(XMPPRosterSqlStorage *)sender
 didUpdateResource:(XMPPResourceObject *)resource
          withUser:(NSString *)userJid;

- (void)xmppRoster:(XMPPRosterSqlStorage *)sender
 didRemoveResource:(XMPPResourceObject *)resource
		  withUser:(NSString *)userJid;
@end