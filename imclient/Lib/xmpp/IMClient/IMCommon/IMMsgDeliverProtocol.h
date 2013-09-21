//
//  IMMsgDeliverProtocol.h
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMMsg;
@protocol IMMsgDeliverProtocol <NSObject>
@required
- (void)deliverMsg:(IMMsg *)msg;

@optional

@end
