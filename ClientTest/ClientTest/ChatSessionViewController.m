//
//  ChatSessionViewController.m
//  IMLite
//
//  Created by pengjay on 13-7-16.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ChatSessionViewController.h"
#import <IMChatSession.h>
#import <IMUser.h>
#import <IMMsg.h>
#import "GOMessageCell.h"
#import "IMLiteUtil.h"
#import <IMContext.h>
#import "AppDelegate.h"
#import <IMChatSessionManager.h>
#import "PrivatChatViewController.h"
#import "DicussChatViewController.h"
#import "SysNotChatViewController.h"

#ifdef DEBUG
#import "UserInfoViewController.h"
#import <IMUserManager.h>
#import "SettingEditingViewController.h"
#endif

@interface ChatSessionViewController () <IMChatSessionManagerDelegate>
@end

@implementation ChatSessionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"消息", nil);

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goChatViewContrller:) name:kGoChatViewContrllerNote object:nil];
        
        if (del.client == nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDelegate:) name:kChatDelegateNote object:nil];
        } else {
            [self addDelegate:nil];
        }
        
#ifdef DEBUG
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"test" style:UIBarButtonItemStyleBordered target:self action:@selector(test)];
//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"test1" style:UIBarButtonItemStyleBordered target:self action:@selector(test2)];
#endif
    }
    return self;
}

- (void)dealloc
{
	[del.client.sessionMgr removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatDelegateNote object:nil];
	[super dealloc];
}

//#ifdef DEBUG
////////////test///////
//- (void)test
//{
////	[del.client.xbRoster addUserWithJidStr:@"b03486979aecf582db4d04192bc1a8d36580926f@doctor.cn" nickname:@"test" subscribeToPresence:NO];
//	[del.client.xmppXBPrivacy setFriendAuthType:FriendAuthTypeAuth];
//}
//
//- (void)test1
//{
//	
//	
//	
//	SettingEditingViewController *seVC = [[[SettingEditingViewController alloc] initWithTextFieldHeight:100.0 text:nil editingDoneBlock:^(UIViewController *vc, NSString *newText, BOOL changed){
//		// send changed value to server and database
//		if (newText.length <= 0) {
//			newText = @"900e1107850a50f11330d73dfbfd7f09482e9ffc@jianhua.com";
//		}
//		IMUser *user = [del.client.userMgr createCacheUserWithID:newText usertype:IMUserTypeP2P];
//		UserInfoViewController *infoVC = [[UserInfoViewController alloc] initWithUser:user];
//		infoVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
//		infoVC.hidesBottomBarWhenPushed = YES;
//		[self.navigationController pushViewController:infoVC animated:YES];
//		[infoVC release];
//	}] autorelease];
//	seVC.doneButtonStr = @"保存";
//	seVC.limitedEditingLength = 30;
//	seVC.showsCharNumberIndicator = YES;
//	seVC.hidesBottomBarWhenPushed = YES;
//	seVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
//	[self.navigationController pushViewController:seVC animated:YES];
//}
//////
//- (void)test2
//{
//	[del.client.xbRoster setNickname:@"jkdfjk" forUser:[XMPPJID jidWithString:@"pp7@jianhua.com"]];
//	return;
//	SettingEditingViewController *seVC = [[[SettingEditingViewController alloc] initWithTextFieldHeight:100.0 text:nil editingDoneBlock:^(UIViewController *vc, NSString *newText, BOOL changed){
//		// send changed value to server and database
//		if (newText.length <= 0) {
//			newText = @"900e1107850a50f11330d73dfbfd7f09482e9ffc@jianhua.com";
//		}
//		IMUser *user = [del.client.userMgr createCacheUserWithID:newText usertype:IMUserTypeP2P];
//		PrivatChatViewController *prv = [[PrivatChatViewController alloc]initWithFromUser:user];
//		prv.hidesBottomBarWhenPushed = YES;
//		prv.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"消息" target:prv action:@selector(navigationBack:)];
//		[self.navigationController pushViewController:prv animated:YES];
//		[prv release];
//	}] autorelease];
//	seVC.doneButtonStr = @"保存";
//	seVC.limitedEditingLength = 30;
//	seVC.showsCharNumberIndicator = YES;
//	seVC.hidesBottomBarWhenPushed = YES;
//	seVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
//	[self.navigationController pushViewController:seVC animated:YES];
//
//
//}
//#endif

- (void)addDelegate:(NSNotification*)note {
    [del.client.sessionMgr addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [del.client.delegates addDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	[del.client.sessionMgr freshChatSession];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    [view release];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//////////////////
- (void)imClient:(IMBaseClient *)client stateChanged:(IMClientState)state
{
	NSLog(@"=========%d========", state);
	if (state == IMClientStateConnected) {
		self.title = NSLocalizedString(@"消息", nil);
	} else if (state == IMClientStateConnecting) {
		self.title = NSLocalizedString(@"连接中...", nil);
	
	} else
	{
		self.title = NSLocalizedString(@"无连接", nil);
	
	}
		
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IMChatSessionManager
- (void)imChatSessionDidChanged:(IMChatSessionManager *)mgr sessions:(NSArray *)sessions unreadNum:(NSUInteger)unreadNum
{
	if (sessions == nil)
		return;
	
	self.contentArray = [NSMutableArray arrayWithArray:sessions];
	[self.tableView reloadData];
	[del.tabBarController.mTabBar updateBadgeNum:unreadNum atIndex:0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate, DataSource 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Message Cell";
    
    GOMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[GOMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
	
    IMChatSession *se = (IMChatSession *)[self.contentArray objectAtIndex:indexPath.row];
    
	
    [cell setCellInfoWithFromUser:se.fromUser
                      unreadCount:se.unreadNum
                        msgSource:se.fromUser.nickname
                         subtitle:se.sessionBody
                             time:[IMLiteUtil getTimeStrWithDate:se.msg.msgTime]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		IMChatSession *se = [(IMChatSession *)[self.contentArray objectAtIndex:indexPath.row] retain];
//		[self.contentArray removeObjectAtIndex:indexPath.row];
//		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[del.client.sessionMgr deleteChatSessionWithUser:se.fromUser];
		[se release];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	IMChatSession *se = (IMChatSession *)[self.contentArray objectAtIndex:indexPath.row];
	[del.client.sessionMgr readChatSession:se];
	if (se.fromUser.userType & IMUserTypeP2P) {
		PrivatChatViewController *prv = [[PrivatChatViewController alloc]initWithFromUser:se.fromUser];
		prv.hidesBottomBarWhenPushed = YES;
		prv.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"消息" target:prv action:@selector(navigationBack:)];
		[self.navigationController pushViewController:prv animated:YES];
		[prv release];
	} else if (se.fromUser.userType & IMUserTypeDiscuss) {
		DicussChatViewController *dcv = [[DicussChatViewController alloc]initWithFromUser:se.fromUser];
		dcv.hidesBottomBarWhenPushed = YES;
		dcv.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"消息" target:dcv action:@selector(navigationBack:)];
		[self.navigationController pushViewController:dcv animated:YES];
		[dcv release];
	} else {
		SysNotChatViewController *dcv = [[SysNotChatViewController alloc]initWithFromUser:se.fromUser];
		dcv.hidesBottomBarWhenPushed = YES;
		dcv.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"消息" target:dcv action:@selector(navigationBack:)];
		[self.navigationController pushViewController:dcv animated:YES];
		[dcv release];
	}
}


- (void)goChatViewContrller:(NSNotification *)note
{
	IMUser *fromUser = (IMUser *)[note object];
	if (fromUser == nil)
	{
		return;
	}
	NSMutableArray *array = [NSMutableArray arrayWithObject:[self.navigationController.viewControllers objectAtIndex:0]];
	
	if (fromUser.userType & IMUserTypeP2P)
	{
		[del.client.sessionMgr readChatSessionWithUser:fromUser];
		PrivatChatViewController *prv = [[PrivatChatViewController alloc]initWithFromUser:fromUser];
		prv.hidesBottomBarWhenPushed = YES;
		prv.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"消息" target:prv action:@selector(navigationBack:)];
		[array addObject:prv];
		[prv release];

	}
	else
	{
		[del.client.sessionMgr readChatSessionWithUser:fromUser];
		DicussChatViewController *dcv = [[DicussChatViewController alloc]initWithFromUser:fromUser];
		dcv.hidesBottomBarWhenPushed = YES;
		dcv.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"消息" target:dcv action:@selector(navigationBack:)];
		[array addObject:dcv];
		[dcv release];
//		GOGrpChatViewController *gvc = [[GOGrpChatViewController alloc]initWithNibName:nil bundle:nil];
//		gvc.fromUser = fromUser;
//		gvc.hidesBottomBarWhenPushed = YES;
//		gvc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:gvc action:@selector(navigationBack:)];
//		[array addObject:gvc];
//		[gvc release];
	}
	self.tabBarController.selectedIndex = 0;
	[self.navigationController setViewControllers:array animated:YES];
}

@end
