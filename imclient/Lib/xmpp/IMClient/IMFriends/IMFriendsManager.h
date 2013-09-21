//
//  IMFriendsManager.h
//  IMClient
//
//  Created by pengjay on 13-7-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDMulticastDelegate.h"
#import "XMPPRoster.h"
#import "XMPPRosterSqlStorage.h"
@protocol IMFriendsManagerDelegate;

@interface IMFriendsManager : NSObject
{
	GCDMulticastDelegate <IMFriendsManagerDelegate> *_delegates;
	dispatch_queue_t _queue;
	void	 *_queueTag;
	
	XMPPRoster *_roster;
	XMPPRosterSqlStorage *_rosterStorage;
	
	NSMutableArray *_friends;
}



@end




///////////////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol IMFriendsManagerDelegate <NSObject>

@optional
- (void)imFriendsManager:(IMFriendsManager *)mgr didChanged:(NSArray *)friendsList;
@end