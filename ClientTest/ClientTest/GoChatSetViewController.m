//
//  GoChatSetViewController.m
//  GoComIM
//
//  Created by 王鹏 on 13-5-13.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GoChatSetViewController.h"
#import "NSArray+PPCategory.h"
#import "NSMutableArray+PPCategory.h"
#import "UIHelper.h"
#import "UserInfoViewController.h"
#import "GOUtils.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "NSArray+PPCategory.h"
#import "FriendViewController.h"
#import <XMPPXBRosterSqlStorage.h>
#import <XMPPXBRoster.h>
#import <IMUser.h>
#import <IMContext.h>
#import <IMUserManager.h>
#import <IMChatSessionManager.h>
#import "ContactsViewController.h"

@interface GoChatSetViewController ()<UIActionSheetDelegate, FriendViewControllerDelegate,ContactsViewControllerDelegate>
@property (nonatomic, retain) NSMutableString *msgBody;
@property (nonatomic, copy) NSString *reqID;
@end

@implementation GoChatSetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:NSLocalizedString(@"返回", nil) target:self action:@selector(navBack)];
		[del.client.xbRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)navBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)initContentArray
{
	
	self.contentArray = [NSMutableArray array];
	[self.contentArray addObject:@[@{@"title": @"从组织里添加成员", @"image":[UIImage imageNamed:@"tableview_icon_add.png"]},
							   @{@"title": @"从通讯录里添加成员", @"image":[UIImage imageNamed:@"tableview_icon_add.png"]}]];

}

- (void)viewDidLoad
{
	[self initContentArray];
    [super viewDidLoad];
//	self.title = NSLocalizedString(@"聊天信息", nil);
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[del.client.xbRoster removeDelegate:self];
	[_reqID release];
	[_msgBody release];
	[_fromUser release];
	_fromUser = nil;
	[super dealloc];
}
#pragma mark UItableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *array = [self.contentArray objectAtIndex:section];
	return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	
	NSArray *array = [self.contentArray objectOrNilAtIndex:indexPath.section];
	
	NSDictionary *dic = [array objectOrNilAtIndex:indexPath.row];
	
	cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
	cell.textLabel.text = [dic objectForKey:@"title"];
	cell.imageView.image = [dic objectForKey:@"image"];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return @"创建讨论组";
	}
	return @"";
}

- (void)push2UserInfoVC
{
	UserInfoViewController *userInfoVc = [[UserInfoViewController alloc]initWithUser:self.fromUser];
	userInfoVc.title = NSLocalizedString(@"详细资料", nil);
	userInfoVc.hidesBottomBarWhenPushed = YES;
	userInfoVc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:userInfoVc action:@selector(navigationBack:)];
	[self.navigationController pushViewController:userInfoVc animated:YES];
	[userInfoVc release];
}

- (void)push2ChatHistroy
{
//	GoChatHistroyViewController *hivc = [[GoChatHistroyViewController alloc]initWithNibName:nil bundle:nil];
//	hivc.fromUser = self.fromUser;
//	hivc.hidesBottomBarWhenPushed = YES;
//	
//	[self.navigationController pushViewController:hivc animated:YES];
//	[hivc release];
//	NSURL *url = [del.imAgent.goComCore historyMessageUrl:self.fromUser.userID type:nil];
//	WebViewController *webVc = [[WebViewController alloc]initWithNibName:nil bundle:nil];
//	webVc.title = @"历史记录";
//	webVc.hidesBottomBarWhenPushed = YES;
//	webVc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:webVc action:@selector(navigationBack:)];
//	webVc.URL = url;
//	[self.navigationController pushViewController:webVc animated:YES];
//	[webVc release];
}

- (void)push2Contacts
{
//	ContactsViewController *cvc = [[ContactsViewController alloc]initWithNibName:nil bundle:nil];
//	cvc.multiSelect = YES;
//	cvc.delegate = self;
//	cvc.hidesBottomBarWhenPushed = YES;
//	cvc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:cvc action:@selector(navigationBack:)];
//	cvc.title = @"添加讨论组成员";
//    cvc.selectedBar.isCountGRP = YES;
//	[self.navigationController pushViewController:cvc animated:YES];
//	[cvc release];
    
    ContactsViewController *cvc = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    cvc.isMultiSelecting = YES;
    cvc.hidesBottomBarWhenPushed = YES;
    cvc.delegate = self;
    cvc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:cvc action:@selector(navigationBack:)];
    cvc.title = @"添加讨论组成员";
    
    [self.navigationController pushViewController:cvc animated:YES];
    [cvc release];
}

- (void)push2orgVc
{
//	OrgViewController *orgvc = [[OrgViewController alloc]initWithNibName:nil bundle:nil];
//    orgvc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:orgvc action:@selector(navigationBack:)];
//	orgvc.multiSelect = YES;
//	orgvc.delegate = self;
//	orgvc.hidesBottomBarWhenPushed = YES;
//	orgvc.title = @"添加讨论组成员";
//    orgvc.navigationItem.rightBarButtonItem = [UIHelper navBarButtonWithTitle:@"取消" target:self action:@selector(cancelAdd)];
//    
//	[self.navigationController pushViewController:orgvc animated:YES];
//	[orgvc release];
	FriendViewController *fvc = [[FriendViewController alloc]initWithNibName:nil bundle:nil];
	fvc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"取消" target:fvc action:@selector(navigationBack:)];
	fvc.multiSelect = YES;
	fvc.delegate = self;
	fvc.hidesBottomBarWhenPushed = YES;
	fvc.title = @"添加讨论组成员";
	[self.navigationController pushViewController:fvc animated:YES];
	[fvc release];
}

- (void)cancelAdd
{
//    [[GOOrgCache sharedOrgCache] uncheckAllUser];
//    [self.navigationController popViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0)
	{
		if (indexPath.row == 0)
		{
			[self push2Contacts];
		}
		else
			[self push2orgVc];
	}
	
}

#pragma mark - add Member Methods-
- (void)addMembers:(NSArray *)userArray
{
    
    if (userArray.count == 0) {
        return;
    }
    
	NSMutableArray *array = [NSMutableArray array];
	NSMutableArray *userArray1 = [NSMutableArray arrayWithArray:userArray];
	if (![userArray1 containsObject:self.fromUser] && self.fromUser.userType != IMUserTypeDiscuss)
		[userArray1 addObject:self.fromUser];
	NSMutableArray *nameArray = [NSMutableArray array];
	for (IMUser *user in userArray1) {
		static int i = 0;
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		if (user.userID)
			[dic setObject:user.userID forKey:@"jid"];
		
		if (user.nickname) {
			[dic setObject:user.nickname forKey:@"name"];
			[nameArray addObject:user.nickname];
			i++;
		}
			
		[array addObject:dic];
	}
	
	if (self.fromUser.userType & IMUserTypeP2P) {
        [nameArray insertObject:[IMContext sharedContext].loginUser.nickname atIndex:0];
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];
		self.reqID = [del.client.xbRoster createDiscussGroup:[nameArray componentsJoinedByString:@","] withMembers:array];
	} else if (self.fromUser.userType & IMUserTypeDiscuss) {
        [nameArray insertObject:self.fromUser.nickname atIndex:0];
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [del.client.xbRoster changeDiscussGroup:self.fromUser.userID withNewName:[nameArray componentsJoinedByString:@","]];
		self.reqID = [del.client.xbRoster addDiscussGroup:self.fromUser.userID withMembers:array];
	}
}

- (void)exitGroup
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	BOOL isAdim = [del.client.xbRosterStorage memberIsAdmin:[IMContext sharedContext].loginUser.userID withDgid:self.fromUser.userID];
	if (isAdim)
		self.reqID = [del.client.xbRoster deleteDiscussGroup:self.fromUser.userID];
	else
		self.reqID = [del.client.xbRoster qiutDiscussGroup:self.fromUser.userID];
}

#pragma mark -
- (void)friendViewController:(FriendViewController *)contacsVC didFinishSelectionWithUsers:(NSArray *)users
{
    NSArray *areadyArray = [del.client membersForDiscussGroup:self.fromUser.userID];
	NSMutableArray *shoudProArray = [NSMutableArray array];
	
	for (IMUser *user in users) {
		if (user.userType & IMUserTypeP2P) {
			if (![areadyArray containsObject:user] && ![shoudProArray containsObject:user]) {
				[shoudProArray addObject:user];
			}
		} else if (user.userType & IMUserTypeDiscuss) {
			NSArray *tmpMema = [del.client membersForDiscussGroup:user.userID];
			for (IMUser *tmpUser in tmpMema) {
				if (![areadyArray containsObject:tmpUser] && ![shoudProArray containsObject:tmpUser]) {
					[shoudProArray addObject:tmpUser];
				}
			}
		}
	}
	NSLog(@"%@", shoudProArray);
	[self addMembers:shoudProArray];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (void)ContactsViewController:(ContactsViewController *)contacsVC didFinishSelectionWithUsers:(NSArray *)users
{
    NSArray *areadyArray = [del.client membersForDiscussGroup:self.fromUser.userID];
	NSMutableArray *shoudProArray = [NSMutableArray array];
	
	for (IMUser *user in users) {
		if (user.userType & IMUserTypeP2P) {
			if (![areadyArray containsObject:user] && ![shoudProArray containsObject:user]) {
				[shoudProArray addObject:user];
			}
		} else if (user.userType & IMUserTypeDiscuss) {
			NSArray *tmpMema = [del.client membersForDiscussGroup:user.userID];
			for (IMUser *tmpUser in tmpMema) {
				if (![areadyArray containsObject:tmpUser] && ![shoudProArray containsObject:tmpUser]) {
					[shoudProArray addObject:tmpUser];
				}
			}
		}
	}
	NSLog(@"%@", shoudProArray);
	[self addMembers:shoudProArray];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

#pragma mark - Roster Delegate
- (void)xmppRoster:(XMPPRoster *)sender didTrackedID:(NSString *)eleid iq:(XMPPIQ *)iq
{
	NSLog(@"%@", _reqID);
	if ([eleid isEqualToString:_reqID]) {
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([iq isResultIQ]) {
			NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:roster"];
			NSString *type = [query attributeStringValueForName:@"type"];
			NSString *groupid = [query attributeStringValueForName:@"groupid"];
				NSString *groupName = [query attributeStringValueForName:@"groupname"];
			IMUser *user = [del.client.userMgr createCacheUserWithID:groupid usertype:IMUserTypeDiscuss nikename:groupName];
			if ([type isEqualToString:@"creategroup"]) {
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kGoChatViewContrllerNote
																	object:user];
			} else if ([type isEqualToString:@"removegroup"] ||
					   [type isEqualToString:@"quitgroup"]) {
				[del.client.sessionMgr deleteChatSessionWithUser:user];
				[self.navigationController popToRootViewControllerAnimated:YES];
			}
		}
	}
}

@end
