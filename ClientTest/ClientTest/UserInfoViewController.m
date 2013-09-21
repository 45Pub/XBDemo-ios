//
//  UserInfoViewController.m
//  IMLite
//
//  Created by pengjay on 13-7-19.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "UserInfoViewController.h"
#import "AvatarHelper.h"
#import <QuartzCore/QuartzCore.h>
#import <IMUser.h>
#import "AppDelegate.h"
#import "GOUserInfoCell.h"
#import <XMPPXBRoster.h>
#import <XMPPXBRosterSqlStorage.h>
#import <XMPPUserObject.h>
#import "UIHelper.h"
#import "IMLiteUtil.h"
#import "DDAlertPrompt.h"
#import <IMMsgStorage.h>
#import <IMContext.h>
#import <XMPPvCardTemp.h>
#import <ASIHTTPRequest.h>
#import <JSONKit.h>
#import "MBProgressHUD.h"
#import "Public.h"


@interface UserInfoViewController ()
@property (nonatomic, retain, readwrite) IMUser *user;
@property (nonatomic, copy) NSString *reqID;
@property (nonatomic, retain) ASIHTTPRequest *lastRequest;

@property (nonatomic, assign) BOOL isFromConfirm;

@end

@implementation UserInfoViewController


- (instancetype)initWithUser:(IMUser *)user
{
    if (self = [super init]) {
        self.title = @"详细资料";
        self.user = user;
		[del.client.xbRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[del.client.xbRoster removeDelegate:self];
	[_user release];
	[_reqID release];
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
    }
    self.lastRequest = nil;
    //    self.friendCenderMsg = nil;
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lastRequest = nil;
	[self consturctContentArray];
    self.isFromConfirm = NO;
	// Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - Inherited Methods

- (UIView *)getTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 54.0)];
    headerView.backgroundColor = [UIColor clearColor];
    
   
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45.0, 45.0f)];
    avatarView.bounds = CGRectMake(0.0, 0.0, 45.0, 45.0);
    avatarView.center = CGPointMake(avatarView.width * 0.5 + 10.0, headerView.height * 0.5);
    avatarView.layer.cornerRadius = 6.0;
    avatarView.layer.masksToBounds = YES;
	[AvatarHelper addAvatar:self.user toImageView:avatarView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(avatarView.origin.x + avatarView.width + 9.0, 2.0, 160.0, 30.0)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:15.5];
    label.text = self.user.nickname;
    label.backgroundColor = [UIColor clearColor];
    
    [headerView addSubview:avatarView];
    [headerView addSubview:label];
    
    [avatarView release], [label release];
	
    
    return [headerView autorelease];
}

- (UIView *)getTableFooterView
{
	
	if ([self.user isEqual:[IMContext sharedContext].loginUser]) {
		return nil;
	}
	
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 50.0)];
    footerView.backgroundColor = [UIColor clearColor];
   
	NSString *title = @"发送消息";
	UIButton *signOutButton = nil;
	signOutButton = [UIHelper greenBtnWithTitle:title target:self action:@selector(gotoChatVc)];
	if (self.user.userType & IMUserTypeP2P) {
		if (![del.client.xbRosterStorage userObjectIsExsit:self.user.userID] || self.undisposed) {
			if (self.shouldProcWhenNotFriend == YES) {
				title = @"通过验证";
				signOutButton = [UIHelper redBtnWithTitle:title target:self action:@selector(confirmFriend)];
			} else {
				title = @"加为好友";
				signOutButton = [UIHelper redBtnWithTitle:title target:self action:@selector(addFriend)];
			}
		} else {
			UIButton *delBtn = [UIHelper redBtnWithTitle:@"删除好友" target:self action:@selector(delFriend)];
			delBtn.frame = CGRectMake(10, 45, 300, 40);
			[footerView addSubview:delBtn];
			footerView.height = 100;
		}
	} else {
		UIButton *delBtn = [UIHelper redBtnWithTitle:@"退出群组" target:self action:@selector(delGroup)];
		delBtn.frame = CGRectMake(10, 45, 300, 40);
		[footerView addSubview:delBtn];
		footerView.height = 100;
	}

	
    signOutButton.frame = CGRectMake(10.0, 0, 300.0, 40.0);
    
    
    [footerView addSubview:signOutButton];
    
    return [footerView autorelease];
}

- (void)delGroup
{
    self.isFromConfirm = NO;

    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
	BOOL isAdim = [del.client.xbRosterStorage memberIsAdmin:[IMContext sharedContext].loginUser.userID withDgid:self.user.userID];
	if (isAdim)
		self.reqID = [del.client.xbRoster deleteDiscussGroup:self.user.userID];
	else
		self.reqID = [del.client.xbRoster qiutDiscussGroup:self.user.userID];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)delFriend
{
    self.isFromConfirm = NO;

    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
	[del.client.xbRoster removeUser:[XMPPJID jidWithString:self.user.userID]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoChatVc
{
    self.isFromConfirm = NO;

    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
	[self.navigationController popToRootViewControllerAnimated:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:kGoChatViewContrllerNote object:self.user];
}

- (void)confirmFriend
{
    self.isFromConfirm = YES;
	[del.client confireFriendAskto:self.user.userID];
	[del.client.msgStorage updateFriendCenterProcState:IMMsgProcStateSuc withUser:self.user];
	self.shouldProcWhenNotFriend = NO;
    self.undisposed = NO;
//    if (self.friendCenderMsg) {
//        self.friendCenderMsg.procState = IMMsgProcStateSuc;
//    }
//	self.tableView.tableFooterView = [self getTableFooterView];
}

- (void)addFriend
{
    self.isFromConfirm = NO;

//	self.reqID = [del.client.xbRoster addUserWithJidStr:@"b03486979aecf582db4d04192bc1a8d36580926f@doctor.cn"
	self.reqID = [del.client.xbRoster addUserWithJidStr:self.user.userID
											   nickname:self.user.nickname
					   subscribeToPresence:NO];
	
//	XMPPXBRoster *rostor = del.client.xbRoster;
//	if ([del.client.xbRosterStorage userForJidStr:self.user.userID]) {
//		NSLog(@"have Friend");
//		return;
//	}
//
//	[rostor addUser:[XMPPJID jidWithString:self.user.userID] withNickname:self.user.nickname];
}

#pragma mark -
- (void)consturctContentArray
{
    /*
     self.contentArray has {section number} objects.
	 each object is an array of data associated as dictionary:
	 title - @"", info - @"", type - @""
     */
    self.contentArray = [NSMutableArray array];

	self.tableView.tableFooterView = [self getTableFooterView];
	self.tableView.tableHeaderView = [self getTableHeaderView];
    
    
    if (self.user.userType == IMUserTypeDiscuss) {
        return;
    }
    
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
    
    NSMutableArray *userInfo = [[NSMutableArray alloc] init];
    
    [userInfo addObject:@{@"title": @"部门", @"info": @""}];
    [userInfo addObject:@{@"title": @"手机", @"info": @""}];
    [userInfo addObject:@{@"title": @"电话", @"info": @""}];
    [userInfo addObject:@{@"title": @"邮箱", @"info": @""}];
    [self.contentArray addObject:userInfo];
    [userInfo release];
    
    [self.tableView reloadData];
    
    //    if (del.client.isOnline) {
    NSString *userID = [self.user.userID substringToIndex:(self.user.userID.length-SERVER_DOMAIN.length)];
    NSString *api = [[NSString stringWithFormat:@"%@%@%@", USER_INFO_API, userID, [del apiString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api]];
    request.delegate = self;
    [request setDidFinishSelector:@selector(userInforeRuestFinished:)];
    [request setDidFailSelector:@selector(userInfoRequestFailed:)];
    [request setTimeOutSeconds:10.0f];
//    [request setNumberOfTimesToRetryOnTimeout:3];
    [request startAsynchronous];
    
    self.lastRequest = request;
    
    //    }


}

- (void)userInforeRuestFinished:(ASIHTTPRequest*)request {
    
    self.lastRequest = nil;
    
    NSString *jsonString = [request responseString];
    NSDictionary *dic = [jsonString objectFromJSONString];
    if (dic && [dic[@"ok"] boolValue]) {
        NSMutableArray *userInfo = [[NSMutableArray alloc] init];
        NSString *department = [Public formatStringifNull:dic[@"department"]];
        NSString *mobilePhone = [Public formatStringifNull:dic[@"phone"]];
        NSString *emailAddress = [Public formatStringifNull:dic[@"email"]];
        NSString *fixedPhone = [Public formatStringifNull:dic[@"tel"]];
        UserInOutFlag flag = [[Public formatStringifNull:dic[@"role"]] intValue];
        if (flag == UserInOutFlagOut) {
            [userInfo addObject:@{@"title": @"部门", @"info": [NSString stringWithFormat:@"%@-%@", @"外部人员", department]}];
        } else {
            [userInfo addObject:@{@"title": @"部门", @"info": department}];
        }
        [userInfo addObject:@{@"title": @"手机", @"info": mobilePhone}];
        [userInfo addObject:@{@"title": @"电话", @"info": fixedPhone}];
        [userInfo addObject:@{@"title": @"邮箱", @"info": emailAddress}];

        [self.contentArray removeAllObjects];
        [self.contentArray addObject:userInfo];
        [userInfo release];
        [self.tableView reloadData];
    } else {
        
        NSString *errorString = nil;
        if (dic && dic[@"error"]) {
            errorString = dic[@"error"];
        } else {
            errorString = @"请检查网络配置是否正确";
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"获取信息失败";
        hud.detailsLabelText = errorString;
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0f];
    }
    
}

- (void)userInfoRequestFailed:(ASIHTTPRequest*)request {
    
    self.lastRequest = nil;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"获取信息失败";
    hud.detailsLabelText = @"请检查网络配置是否正确";
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:2.0f];
}


#pragma mark - Helper

- (NSDictionary *)cellDataWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.contentArray[indexPath.section];
    
    return arr[indexPath.row];
}

- (void)configureCell:(GOUserInfoCell *)cell withData:(NSDictionary *)data
{
    if ([data[@"type"] isEqualToString:@"phone"]) {
        cell.infoType = GOUserInfoCellAccessoryTypePhone;
    }
    else if ([data[@"type"] isEqualToString:@"mail"]) {
//        cell.infoType = GOUserInfoCellAccessoryTypeMail;
//        cell.accessoryActionBlock = ^(NSString * mailAdress){
//            Class mailClass = NSClassFromString(@"MFMailComposeViewController");
//            if(mailClass != nil)
//            {
//                if([mailClass canSendMail])
//                {
//                    [self displayComposerSheet:mailAdress];
//                }
//            }
//        };
    }
    else if ([data[@"type"] isEqualToString:@"member"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.infoType = GOUserInfoCellAccessoryTypeNone;
    }
    else {
        cell.infoType = GOUserInfoCellAccessoryTypeNone;
    }
    [cell setTitle:data[@"title"] info:data[@"info"] infoType:cell.infoType];
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contentArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *data = [self cellDataWithIndexPath:indexPath];
	GOUserInfoCellAccessoryType infoType;
	if ([data[@"type"] isEqualToString:@"phone"]) {
        infoType = GOUserInfoCellAccessoryTypePhone;
    }
    else if ([data[@"type"] isEqualToString:@"mail"]) {
        infoType = GOUserInfoCellAccessoryTypeMail;
        
    }
    else if ([data[@"type"] isEqualToString:@"member"]) {
        
		infoType = GOUserInfoCellAccessoryTypeNone;
    }
    else {
        infoType = GOUserInfoCellAccessoryTypeNone;
    }
	
	return [GOUserInfoCell heightwithTitle:data[@"title"] InfoString:data[@"info"] infoType:infoType];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InfoCell";
    
    GOUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[GOUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *data = [self cellDataWithIndexPath:indexPath];
    [self configureCell:cell withData:data];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - RosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didTrackedID:(NSString *)eleid iq:(XMPPIQ *)iq
{
	NSLog(@"%@", eleid);
	
	if ([iq errorWithRosterShouldAuth] && [eleid isEqualToString:self.reqID]) {
		DDAlertPrompt *loginPrompt = [[DDAlertPrompt alloc] initWithTitle:@"对方开启好友验证" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"发送"];
		[loginPrompt show];
		[loginPrompt release];
	} else if ([iq errorWithRosterDenyAddFriend] && [eleid isEqualToString:self.reqID]) {
		UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"对方禁止添加好友"
														  delegate:nil cancelButtonTitle:@"确定"
												 otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([iq isResultIQ] && [eleid isEqualToString:self.reqID]) {
//		[del.client.xbRoster subscribePresenceToUser:[XMPPJID jidWithString:self.user.userID]];
	}

}

- (void)xmppRosterDidChange:(XMPPRosterSqlStorage *)sender
{
    if (!self.isFromConfirm) {
        self.tableView.tableFooterView = [self getTableFooterView];
    }
    self.isFromConfirm = NO;
}
#pragma mark - AlertViewDelegate
- (void)didPresentAlertView:(UIAlertView *)alertView {
	if ([alertView isKindOfClass:[DDAlertPrompt class]]) {
		DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
		[loginPrompt.plainTextField becomeFirstResponder];
		[loginPrompt setNeedsLayout];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [alertView cancelButtonIndex]) {
	} else {
		if ([alertView isKindOfClass:[DDAlertPrompt class]]) {
			DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
			NSLog(@"textField: %@", loginPrompt.plainTextField.text);
			NSLog(@"secretTextField: %@", loginPrompt.secretTextField.text);
			[del.client sendAddFriendAsk:loginPrompt.plainTextField.text to:self.user.userID];
		}
	}
}

@end
