//
//  IMChatSessionHandler.h
//  IMClient
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseHandlerDelegate.h"
#import "IMChatSessionManager.h"
@interface IMChatSessionHandler : NSObject <UITableViewDelegate, UITableViewDataSource, IMChatSessionManagerDelegate>
{
	NSMutableArray *_sessionArray;
}
@property (nonatomic, weak) id <IMBaseHandlerDelegate> delegate;

@end


