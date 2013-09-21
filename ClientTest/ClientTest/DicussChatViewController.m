//
//  DicussChatViewController.m
//  IMLite
//
//  Created by pengjay on 13-7-19.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "DicussChatViewController.h"
#import "GoDiscChatSetViewController.h"
#import "AppDelegate.h"
#import <XMPPXBRoster.h>
#import <XMPPXBRosterSqlStorage.h>
#import <IMContext.h>
@interface DicussChatViewController ()

@end

@implementation DicussChatViewController

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
	
	if ([del.client.xbRosterStorage memberExsit:[IMContext sharedContext].loginUser.userID
		withDgid:self.fromUser.userID]) {
			self.navigationItem.rightBarButtonItem = [UIHelper navBarButtonWithImage:[UIImage imageNamed:@"nav_btn_info"]
																	  target:self
																			  action:@selector(rightBarButtonItemClick:)];
	}

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarButtonItemClick:(id)sender
{
	GoDiscChatSetViewController * dvc = [[GoDiscChatSetViewController alloc]initWithNibName:nil bundle:nil];
	dvc.hidesBottomBarWhenPushed = YES;
    dvc.title = @"讨论组";
    dvc.pVC = self;
	dvc.fromUser = self.fromUser;
	[self.navigationController pushViewController:dvc animated:YES];
	[dvc release];
}

@end
