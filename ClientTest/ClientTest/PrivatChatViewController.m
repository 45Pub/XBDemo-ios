//
//  PrivatChatViewController.m
//  IMLite
//
//  Created by pengjay on 13-7-18.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PrivatChatViewController.h"
#import "UIHelper.h"
#import "GoChatSetViewController.h"
#import "UserInfoViewController.h"

@interface PrivatChatViewController ()

@end

@implementation PrivatChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [UIHelper navBarButtonWithImage:[UIImage imageNamed:@"nav_btn_info"]
																	  target:self
																	  action:@selector(rightBarButtonItemClick:)];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarButtonItemClick:(id)sender
{
	GoChatSetViewController *chatSetVc = [[GoChatSetViewController alloc]initWithNibName:nil bundle:nil];
	chatSetVc.hidesBottomBarWhenPushed = YES;
    chatSetVc.title = @"创建讨论组";
	chatSetVc.fromUser = self.fromUser;
	[self.navigationController pushViewController:chatSetVc animated:YES];
	[chatSetVc release];
}

- (void)imMsgCellHeadDidSelected:(IMMsgCell *)cell
{
//	if(cell.msg.fromType == IMMsgFromLocalSelf || cell.msg.fromType == IMMsgFromRemoteSelf)
//	{
//		MySetViewController *mvc = [[MySetViewController alloc]initWithNibName:nil bundle:nil];
//		mvc.hidesBottomBarWhenPushed = YES;
//		[self.navigationController pushViewController:mvc animated:YES];
//		[mvc release];
//	}
//	else
	{
		UserInfoViewController *uvc = [[UserInfoViewController alloc]initWithUser:cell.msg.msgUser];
		uvc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:uvc action:@selector(navigationBack:)];
		uvc.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:uvc animated:YES];
		[uvc release];
	}
	
}
@end
