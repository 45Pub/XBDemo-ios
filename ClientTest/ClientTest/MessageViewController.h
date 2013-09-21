//
//  MessageViewController.h
//  ClientTest
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IMUser.h>
#import <IMMsgQueueManager.h>
@interface MessageViewController : UITableViewController <IMMsgQueueDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	IMMsgQueue *_msgQueue;
	NSArray *_msgArray;
}
- (id)initWithUser:(IMUser *)user;
@property (nonatomic, readonly, strong) IMUser *fromUser;
@end
