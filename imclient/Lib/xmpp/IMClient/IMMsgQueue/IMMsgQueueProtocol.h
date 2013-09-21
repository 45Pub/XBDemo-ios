//
//  IMMsgQueueProtocol.h
//  IMClient
//
//  Created by pengjay on 13-7-13.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMMsg;
@protocol IMMsgQueueProtocol <NSObject>
@optional
- (void)selectMsg:(IMMsg *)msg;
@end
