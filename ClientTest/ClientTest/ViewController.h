//
//  ViewController.h
//  ClientTest
//
//  Created by pengjay on 13-7-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IMChatSessionHandler.h>
/////////////
@interface ViewController : UIViewController <IMBaseHandlerDelegate>
{
	
	UITableView *_tableView;
}
@property (nonatomic, strong, readonly) IMChatSessionHandler *sessionHandler;
@end
