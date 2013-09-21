//
//  SysNotChatViewController.m
//  DoctorChat
//
//  Created by 王鹏 on 13-3-5.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "SysNotChatViewController.h"
#import "UserInfoViewController.h"
#import <IMMsgAll.h>
#import <IMMsgStorage.h>
#import "AppDelegate.h"
@interface SysNotChatViewController ()

@end

@implementation SysNotChatViewController

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
	self.tableView.height+= 44;
	self.inputBar.hidden = YES;
	
//	[self.tableView reloadData];
	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	id obj = [self.msgArray objectAtIndex:indexPath.row];
	if([obj isKindOfClass:[IMFriendCenterMsg class]])
	{
		BOOL flag = NO;
		IMFriendCenterMsg *msg = (IMFriendCenterMsg *)obj;
		if([del.client.msgStorage getFrinedCenterProcStateWithUser:msg.msgUser] == IMMsgProcStateUnproc)
		{
			PPLOG(@"unproc");
			flag = YES;
		}
        
        if (msg.procState == IMMsgProcStateSuc) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        

		UserInfoViewController *infoVC = [[UserInfoViewController alloc] initWithUser:msg.msgUser];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isMemberOfClass:[IMFriendCenterCell class]]) {
            IMFriendCenterCell *fCell = (IMFriendCenterCell*)cell;
            if ([fCell.detailLabel.text isEqualToString:@"未处理"]) {
                infoVC.undisposed = YES;
//                infoVC.friendCenderMsg = fCell.msg;
            }
        }

		infoVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
		infoVC.shouldProcWhenNotFriend = flag;
		infoVC.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:infoVC animated:YES];
		[infoVC release];
	}
}

@end
