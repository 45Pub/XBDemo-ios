//
//  IMChatSession.h
//  IMClient
//
//  Created by pengjay on 13-7-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMUser;
@class IMMsg;

@interface IMChatSession : NSObject
@property (nonatomic) NSInteger cid;
@property (nonatomic, strong) IMUser *fromUser;
@property (nonatomic, strong) IMMsg *msg;
@property (nonatomic) NSUInteger unreadNum;
- (NSString *)sessionBody;
@end
