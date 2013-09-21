//
//  IMMsgBaseHandler.h
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMsg.h"
@class IMMsgObserveHandler;
typedef void (^IMMsgObserveCompeletedBlock) (IMMsgObserveHandler *handler, IMMsg *msg, NSNumber *nValue, NSNumber *oValue);
@interface IMMsgObserveHandler : NSObject
{
	IMMsg *_curMsg;
	IMMsgObserveCompeletedBlock _block;
	BOOL _isObserved;
	NSString *_keyPath;
}
- (id)initWithMsg:(IMMsg *)msg keyPath:(NSString *)keyPath compeletedBolck:(IMMsgObserveCompeletedBlock )block;
- (void)addObserver;
- (void)removeObserver;
@end
