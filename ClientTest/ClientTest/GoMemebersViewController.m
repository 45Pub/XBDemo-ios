//
//  GoMemebersViewController.m
//  GoComIM
//
//  Created by 王鹏 on 13-5-15.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GoMemebersViewController.h"
#import <IMUser.h>
#import "GOContactCell.h"
#import "GOUtils.h"
#import "UserInfoViewController.h"
#import "UIHelper.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <IMContext.h>
#import <XMPPXBRoster.h>
#import <XMPPXBRosterSqlStorage.h>

@interface GoMemebersViewController ()
@property (nonatomic, retain) IMUser *fromUser;
@property (nonatomic, retain) NSIndexPath *delIndexPath;
@end

@implementation GoMemebersViewController

- (id)initWithIMUser:(IMUser *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:NSLocalizedString(@"返回", nil) target:self action:@selector(navigationBack:)];
		self.fromUser = user;
		
		[del.client.xbRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
	
    return self;
}

- (void)dealloc
{
	[del.client.xbRoster removeDelegate:self];
	[_fromUser release];
	[_delIndexPath release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

#pragma makr -
- (void)xmppRoster:(XMPPXBRosterSqlStorage *)sender didChangedDiscussGroup:(NSString *)dgid dgName:(NSString *)dgName
		   sponsor:(NSString *)sponsor sponsorName:(NSString *)sponsorName
{
	if ([dgid isEqualToString:self.fromUser.userID]) {
		self.contentArray = [NSMutableArray arrayWithArray:[del.client membersForDiscussGroup:self.fromUser.userID]];
		
		[self configureTitle];
		[self.tableView reloadData];
	}
}

////


- (void)configureTitle
{
	self.title = [NSString stringWithFormat:@"群成员(%d人)", self.contentArray.count];
//	if ([self.fromUser.createUser isEqual:[IMSession globalIMSession].loginUser] && self.fromUser.userType == IMUserTypeGRP)
	BOOL isAdim = [del.client.xbRosterStorage memberIsAdmin:[IMContext sharedContext].loginUser.userID withDgid:self.fromUser.userID];
	if (isAdim)
	{
//		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"删除成员" style:UIBarButtonItemStylePlain target:self action:@selector(delOpt)] autorelease];
		NSString *title = @"删除成员";
		if (self.tableView.editing)
		{
			title = @"取消";
		}
		self.navigationItem.rightBarButtonItem = [UIHelper navBarButtonWithTitle:title target:self action:@selector(delOpt)];
	}
}


#pragma mark -
/////

- (void)delOpt
{
	self.tableView.editing = !self.tableView.editing;
	NSString *title = @"删除成员";
	if (self.tableView.editing)
	{
		title = @"取消";
	}
	
	UIButton *btn = (UIButton *)[self.navigationItem.rightBarButtonItem customView];
	[btn setTitle:title forState:UIControlStateNormal];
}
///
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.contentArray = [NSMutableArray arrayWithArray:[del.client membersForDiscussGroup:self.fromUser.userID]];
	
	[self configureTitle];
	[self.tableView reloadData];
		// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)push2UserInfoVC:(IMUser *)user
{
	UserInfoViewController *userInfoVc = [[UserInfoViewController alloc]initWithUser:user];
	userInfoVc.title = NSLocalizedString(@"详细资料", nil);
	userInfoVc.hidesBottomBarWhenPushed = YES;
	userInfoVc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:userInfoVc action:@selector(navigationBack:)];
	[self.navigationController pushViewController:userInfoVc animated:YES];
	[userInfoVc release];
}

#pragma mark - UITableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ContactCellID";
    
    GOContactCell *cell = (GOContactCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[GOContactCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
        cell.canMultiSelectThroughSelect = YES;
    }
    
    IMUser *user = [self.contentArray objectOrNilAtIndex:indexPath.row];
	cell.imUser = user;
    
//    if ([cell.imUser.userID isEqualToString:[IMContext sharedContext].loginUser.userID]) {
//        cell.editing = NO;
//        BOOL s = cell.editing;
//    } else {
//        cell.editing = self.tableView.editing;
//        BOOL s = cell.editing;
//        s = self.tableView.editing;
//    }
    cell.canMultiSelected = NO;
    [cell disableEditingAccessoryView];
    
    if (cell.isEditing) {
        cell.imageView.frame = CGRectMake(40, 8, 35, 35);
    } else {
        cell.imageView.frame = CGRectMake(8, 8, 35, 35);
    }
    
	cell.textLabel.left = cell.imageView.right + 8;
    
	__block GoMemebersViewController *weakSelf = self;
    cell.accessoryActionBlock = ^(GOContactCell *cCell){
        // push to detail VC
		[weakSelf push2UserInfoVC:user];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 51.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	IMUser *user = [self.contentArray objectOrNilAtIndex:indexPath.row];
	[self push2UserInfoVC:user];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	IMUser *user = [self.contentArray objectOrNilAtIndex:indexPath.row];
	if ([user.userID isEqual:[IMContext sharedContext].loginUser.userID])
	{
		return;
	}
	self.delIndexPath = indexPath;
	
	[del.client.xbRoster removeDiscussGroup:self.fromUser.userID withMembers:@[@{@"jid": user.userID, @"name":user.nickname}]];
//	__block GoMemebersViewController *weakSelf = self;
//	[self.userOperation removeGourpfromUser:self.fromUser showView:self.view users:[NSArray arrayWithObject:user] finishBlock:^(BOOL success, NSError *error, NSDictionary *info) {
//		if (success) {
//			[weakSelf.contentArray removeObjectAtIndex:weakSelf.delIndexPath.row];
//			[weakSelf.tableView deleteRowsAtIndexPaths:@[weakSelf.delIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//			weakSelf.title = [NSString stringWithFormat:@"%@成员(%d人)",[GOUtils userTypeString:self.fromUser], [weakSelf p2pCount]];
//			[weakSelf.fromUser updateGroupUsers];
//			
//		}
//	}];
	
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
//	if (self.fromUser.groupUsers.count > 0 && ![self.fromUser containsUser:[IMSession globalIMSession].loginUser])
//	{
//		return NO;
//	}
//	if ([self.fromUser.createUser isEqual:[IMSession globalIMSession].loginUser])
    IMUser *user = [self.contentArray objectOrNilAtIndex:indexPath.row];
    if ([user.userID isEqualToString:[IMContext sharedContext].loginUser.userID]) {
            return NO;
    } else {
        BOOL isAdim = [del.client.xbRosterStorage memberIsAdmin:[IMContext sharedContext].loginUser.userID withDgid:self.fromUser.userID];
        return isAdim;
    }
//	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IMUser *user = [self.contentArray objectOrNilAtIndex:indexPath.row];
    if ([user.userID isEqualToString:[IMContext sharedContext].loginUser.userID]) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}


@end
