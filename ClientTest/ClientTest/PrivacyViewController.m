//
//  PrivacyViewController.m
//  IMLite
//
//  Created by pengjay on 13-7-25.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PrivacyViewController.h"
#import "AppDelegate.h"
#import <XMPPXBPrivacy.h>
#import "UIHelper.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = @"隐私";
		[del.client.xmppXBPrivacy addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)dealloc
{
	[del.client.xmppXBPrivacy removeDelegate:self];
	[super dealloc];
}


- (void)xmppXBPrivacy:(XMPPXBPrivacy *)sender
  didReceiveBlackList:(NSMutableArray *)list
			 authType:(FriendAuthType)authAtype
{
	[self initContentArray];
	[self.tableView reloadData];
}

- (void)initContentArray
{
	self.contentArray = [NSMutableArray array];
	FriendAuthType type = del.client.xmppXBPrivacy.mAuthType;
	if (type == FriendAuthTypeDeny) {
		NSDictionary *dic = @{@"title": @"允许别人加我为好友", @"value":@(0)};
		[self.contentArray addObject:dic];
	} else if (type == FriendAuthTypeAuth) {
		NSDictionary *dic = @{@"title": @"允许别人加我为好友", @"value":@(1)};
		[self.contentArray addObject:dic];
		dic = @{@"title": @"加我为好友时需要验证", @"value":@(1)};
		[self.contentArray addObject:dic];
	} else {
		NSDictionary *dic = @{@"title": @"允许别人加我为好友", @"value":@(1)};
		[self.contentArray addObject:dic];
		dic = @{@"title": @"加我为好友时需要验证", @"value":@(0)};
		[self.contentArray addObject:dic];
	}

}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self initContentArray];
	[self.tableView reloadData];
	
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:@"switchbtnSetCell"];
	if(cell == nil)
	{
		cell = [UIHelper switchBtnSetCell];
	}
	
	NSDictionary *dic = [self.contentArray objectAtIndex:indexPath.section];
	
	UISwitch * shareButton = [[[UISwitch alloc] initWithFrame:CGRectMake(570.0, 10.0, 94.0, 24.0)] autorelease];
    [shareButton addTarget:self action:@selector(toggleService:) forControlEvents:UIControlEventValueChanged];
	
	cell.textLabel.text = dic[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	shareButton.tag = indexPath.section;
	[shareButton setOn:[dic[@"value"] boolValue]];
    
	cell.accessoryView = shareButton;
	return cell;
}

- (void)toggleService:(UISwitch *)btn
{
	//	[Public setMsgVerification:btn.on];
	
	
	if (btn.tag == 0) {
		if (btn.on) {
			[del.client.xmppXBPrivacy setFriendAuthType:FriendAuthTypeNone];
		} else {
			[del.client.xmppXBPrivacy setFriendAuthType:FriendAuthTypeDeny];
		}
	} else if (btn.tag == 1) {
		if (btn.on) {
			[del.client.xmppXBPrivacy setFriendAuthType:FriendAuthTypeAuth];
		} else {
			[del.client.xmppXBPrivacy setFriendAuthType:FriendAuthTypeNone];
		}
	}
}


@end
