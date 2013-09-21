//
//  ContactsListViewController.m
//  IMLite
//
//  Created by Ethan on 13-8-21.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ContactsListViewController.h"
#import "UserInfoViewController.h"
#import "ContactUserCell.h"
#import <QuartzCore/QuartzCore.h>
#import <ASIHttpRequest.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <JSONKit.h>
#import "Public.h"
#import "ContactLeftCell.h"
#import "ContactUserCell.h"
#import "ContactDiscussCell.h"
#import "ContactDeptCell.h"
#import "ContactNormalCell.h"
#import "SVPullToRefresh.h"
#import <ASIHTTPRequest.h>
#import <XMPPvCardTemp.h>


@interface ContactsListViewController () {
    BOOL _isLoading;
    BOOL _isFailedOfCancel;
}

@property (nonatomic, retain) NSIndexPath *selecetdIndexPath;

@property (nonatomic, retain) NSMutableArray *departmentIDArray;

@end

@implementation ContactsListViewController


- (void)dealloc {
    
    self.contentArray = nil;
    
    self.superViewController = nil;
    
    self.selecetdIndexPath = nil;
    
    self.departmentIDArray = nil;
    
    self.searchArray = nil;
    
    self.searchDepartmentArray = nil;
    
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
    }
    self.lastRequest = nil;
    self.departmentId = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GOSelectedBarItemDidDeselectNotification object:nil];
    
    [super dealloc];
}

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
	// Do any additional setup after loading the view.
        
    self.shouldStack = YES;
    self.isLeft = NO;
    self.contentArray = [NSMutableArray array];
    self.departmentIDArray = [NSMutableArray array];
    self.avatarShouldBeOverWrite = YES;
    
    if (self.departmentId) {
        [self getContentInfoWithDepartmentID:self.departmentId];
    }
    self.tableView.allowsSelectionDuringEditing = YES;
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    [view release];  
}

- (BOOL)isLoading {
    return _isLoading;
}

- (void)setIsSearching:(BOOL)isSearching {
    _isSearching = isSearching;
    if (_isSearching) {
        if (self.searchArray) {
            [self.searchArray removeAllObjects];
        } else {
            self.searchArray = [NSMutableArray array];
        }
        if (self.searchDepartmentArray) {
            [self.searchDepartmentArray removeAllObjects];
        } else {
            self.searchDepartmentArray = [NSMutableArray array];
        }
    } else {
        self.searchArray = nil;
        self.searchDepartmentArray = nil;
    }
}

- (void) getContentInfoWithDepartmentID:(NSString*)departmentID {
    
    self.avatarShouldBeOverWrite = YES;
    
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
        _isFailedOfCancel = YES;
        
        if (self.tableView.pullToRefreshView && self.tableView.showsPullToRefresh) {
            [self.tableView.pullToRefreshView stopAnimating];
        }
        
    }

    NSString *api = [[NSString stringWithFormat:@"%@%@%@", DEPARTMENT_INFO_API, departmentID, [del apiString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api]];
    request.delegate = self;
    [request setDidFailSelector:@selector(contactInfoFailed:)];
    [request setDidFinishSelector:@selector(contactInfoFinished:)];
    [request setTimeOutSeconds:10.0f];
//    [request setNumberOfTimesToRetryOnTimeout:3];
    [request startAsynchronous];
    self.lastRequest = request;
    _isLoading = YES;
//    _isFromCancel = NO;
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    if (!self.tableView.pullToRefreshView || !self.tableView.showsPullToRefresh) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

- (void)contactInfoFinished:(ASIHTTPRequest*)request {
    
    _isLoading = NO;
    
    self.lastRequest = nil;
    
    if (self.tableView.pullToRefreshView && self.tableView.showsPullToRefresh) {
        [self.tableView.pullToRefreshView stopAnimating];
    }
    
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    NSString *jsonString = [request responseString];
    NSDictionary *dic = [jsonString objectFromJSONString];
    if (dic && [dic[@"ok"] boolValue]) {
        
        NSMutableArray *contentArray;
        NSMutableArray *departmentIDArray;
        if (self.isSearching) {
            contentArray = self.searchArray;
            departmentIDArray = self.searchDepartmentArray;
        } else {
            contentArray = self.contentArray;
            departmentIDArray = self.departmentIDArray;
        }
        
        [contentArray removeAllObjects];
        [departmentIDArray removeAllObjects];
        
        NSArray *departments = dic[@"departments"];
        NSArray *peoples = dic[@"peoples"];
        
        for (int i = 0; i < departments.count; ++i) {
            NSDictionary *department = departments[i];
            IMUser *user = [[IMUser alloc] init];
            user.nickname = [Public formatStringifNull:department[@"name"]];
            [contentArray addObject:user];
            [user release];
            NSString *departmentID = [Public formatStringifNull:department[@"id"]];
            [departmentIDArray addObject:departmentID];
        }
        
        for (int i = 0; i < peoples.count; ++i) {
            NSDictionary *people = peoples[i];
            IMUser *user = [[IMUser alloc] init];
            user.userID = [NSString stringWithFormat:@"%@%@", [[Public formatStringifNull:people[@"user"]] sha1Hash], SERVER_DOMAIN];
            user.nickname = [Public formatStringifNull:people[@"name"]];
            NSString *avatarPath = [Public formatStringifNull:people[@"avatar"]];
            user.userType = IMUserTypeP2P;
            user.avatarPath = avatarPath;// [Public urlImagePathToLocalImagePathAndSave:avatarPath user:user overWrite:YES];
            XMPPvCardTemp *vCard = [del.client.xmppvCardTempModule vCardTempForJID:[XMPPJID jidWithString:user.userID] shouldFetch:YES];
            vCard.description = avatarPath;
            vCard.nickname = user.nickname;
            [del.client.xmppvCardTempModule _updatevCardTemp:vCard forJID:[XMPPJID jidWithString:user.userID]];
            
            [contentArray addObject:user];
            [user release];
            NSString *departmentID = NOT_DEPARTMENT;
            [departmentIDArray addObject:departmentID];
        }
        
        [self.tableView reloadData];
        [self.tableView scrollToFirstRow:NO];
        
        self.avatarShouldBeOverWrite = NO;
        
    } else {
        
        NSString *errorString = nil;
        if (dic && dic[@"error"]) {
            errorString = dic[@"error"];
        } else {
            errorString = @"请检查网络配置是否正确";
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"获取信息失败";
        hud.detailsLabelText = errorString;
        [hud hide:YES afterDelay:2.0f];
        
        self.avatarShouldBeOverWrite = YES;
    }
}

- (void)contactInfoFailed:(ASIHTTPRequest*)request {
    
    _isLoading = NO;
    
    self.avatarShouldBeOverWrite = YES;
    
    self.lastRequest = nil;
    
    if (self.tableView.pullToRefreshView && self.tableView.showsPullToRefresh) {
        [self.tableView.pullToRefreshView stopAnimating];
    }
    
    if (_isFailedOfCancel) {
        _isFailedOfCancel = NO;
        return;
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"获取信息失败";
    hud.detailsLabelText = @"请检查网络配置是否正确";
    [hud hide:YES afterDelay:2.0f];
}

- (void)setIsMultiSelecting:(BOOL)isMultiSelecting {
    _isMultiSelecting = isMultiSelecting;
    if (_isMultiSelecting) {
        self.tableView.editing = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectNotificationReceived:) name:GOSelectedBarItemDidDeselectNotification object:nil];
    } else {
        self.tableView.editing = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GOSelectedBarItemDidDeselectNotification object:nil];
    }
}

- (void)deselectNotificationReceived:(NSNotification *)notification
{
    NSString *deletedID = notification.userInfo[@"delete"];
    
    NSMutableArray *contentArray;
    NSMutableArray *departmentIDArray;
    if (self.isSearching) {
        contentArray = self.searchArray;
        departmentIDArray = self.searchDepartmentArray;
    } else {
        contentArray = self.contentArray;
        departmentIDArray = self.departmentIDArray;
    }
    
    for (int i = 0; i < contentArray.count; ++i) {
        IMUser *user = contentArray[i];
        if ([user.userID isEqualToString:deletedID]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([cell isMemberOfClass:[ContactUserCell class]]) {
                ContactUserCell *ucell = (ContactUserCell*)cell;
                ucell.isChecked = NO;
            }
        }
    }
    
}

//- (void)reloadTableViewWithDepartmentId:(NSString*)departmentId {
//    
//    [self.contentArray removeAllObjects];
//    for (int i = 0; i < 20; i++) {
//        IMUser *user = [[IMUser alloc] init];
//        user.nickname = [NSString stringWithFormat:@"nickname-new-%d", i];
//        user.userType = IMUserTypeP2P;
//        [self.contentArray addObject:user];
//        [user release];
//    }
//    
//    [self.tableView reloadData];
//    [self.tableView scrollToFirstRow:NO];
//}

- (void)deselectTheSelectedCell {
    if (self.selecetdIndexPath) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.selecetdIndexPath];
        if ([cell isMemberOfClass:[ContactLeftCell class]]) {
            ContactLeftCell *c = (ContactLeftCell*)cell;
            c.isSelected = NO;
        }
        self.selecetdIndexPath = nil;
    }
}

- (void)selectTheSelectedCell {
    
    if (self.selecetdIndexPath == nil) {
        return;
    }
    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.selecetdIndexPath];
    if ([cell isMemberOfClass:[ContactLeftCell class]]) {
        ContactLeftCell *c = (ContactLeftCell*)cell;
        c.isSelected = YES;
    }
}

- (void)pushToUserInfoViewControllerForUser:(IMUser *)user
{
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithUser:user];
    userInfoVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.superViewController.title target:self action:@selector(navigationBack:)];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:userInfoVC animated:YES];
    [userInfoVC release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (void)navigationBack:(id)sender
{
	[self.superViewController.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching) {
        return self.searchArray.count;
    }
    return self.contentArray.count;
}

- (UITableViewCell *)cellForRowsAtIndexpath:(NSIndexPath *)indexPath
{
    NSMutableArray *contentArray;
    NSMutableArray *departmentIDArray;
    if (self.isSearching) {
        contentArray = self.searchArray;
        departmentIDArray = self.searchDepartmentArray;
    } else {
        contentArray = self.contentArray;
        departmentIDArray = self.departmentIDArray;
    }
    NSString *departmentId = [departmentIDArray objectAtIndex:indexPath.row];
    
    if ([departmentId isEqualToString:NOT_DEPARTMENT]) {
        
        NSString *identifier;
        if ([self.selecetdIndexPath isEqual:indexPath]) {
            identifier = @"ContactUserCellSelected";
        } else {
            identifier = @"ContactUserCell";
        }
        
        ContactUserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        
        if(!cell)
        {
            cell = [[[ContactUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        }
        
        cell.overWrite = (!self.isSearching) && self.avatarShouldBeOverWrite;
        
        IMUser *user = contentArray[indexPath.row];
        cell.user = user;
        
        if (self.isMultiSelecting) {
        
            if ([self.superViewController.selectedUsers containsObject:user]) {
                cell.isChecked = YES;
            } else {
                cell.isChecked = NO;
            }
        
            __block typeof(self) weakSelf = self;
            cell.accessoryActionBlock = ^(BOOL isSelected){
                [weakSelf refreshTheSelectedUser:user isSelected:isSelected];
            };
        }
        return cell;
    } else if (self.isLeft) {
        ContactLeftCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactLeftCell"];
        
        if (!cell) {
            cell = [[[ContactLeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactLeftCell"] autorelease];
        }
        
        IMUser *user = contentArray[indexPath.row];
        cell.user = user;
        return cell;
    } else {
        ContactCell *cell;
        IMUser *user = contentArray[indexPath.row];
        if (user.userType == IMUserTypeDiscuss) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactDiscussCell"];
            if (!cell) {
                cell = [[ContactDiscussCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactDiscussCell"];
            }
        } else {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactDeptCell"];
            if (!cell) {
                cell = [[ContactDeptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactDeptCell"];
            }
        }
        NSLog(@"%@", cell.editingAccessoryView);
//        cell.editingAccessoryView = nil;
        
        cell.user = user;
        return cell;
    }
       
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellForRowsAtIndexpath:indexPath];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.tableView) {
        
        NSMutableArray *contentArray;
        NSMutableArray *departmentIDArray;
        if (self.isSearching) {
            contentArray = self.searchArray;
            departmentIDArray = self.searchDepartmentArray;
        } else {
            contentArray = self.contentArray;
            departmentIDArray = self.departmentIDArray;
        }
        
        IMUser *user = [contentArray objectAtIndex:indexPath.row];
        NSString *departmentId = [departmentIDArray objectAtIndex:indexPath.row];
        if (![departmentId isEqualToString:NOT_DEPARTMENT]) {
            
            self.isLeft = YES;
            
            if (self.lastRequest && !self.lastRequest.isFinished) {
                [self.lastRequest clearDelegatesAndCancel];
                self.lastRequest = nil;
                
                if (self.tableView.pullToRefreshView && self.tableView.showsPullToRefresh) {
                    [self.tableView.pullToRefreshView stopAnimating];
                }
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
            
            UITableViewCell * sCell = [self.tableView cellForRowAtIndexPath:self.selecetdIndexPath];
            if ([sCell isMemberOfClass:[ContactLeftCell class]]) {
                ContactLeftCell *c = (ContactLeftCell*)sCell;
                c.isSelected = NO;
            }
            self.selecetdIndexPath = indexPath;
            
            if (self.shouldStack) {
                ContactsListViewController *contactsListViewController = [[ContactsListViewController alloc] init];
                contactsListViewController.departmentId = departmentId;
                contactsListViewController.superViewController = self.superViewController;
                contactsListViewController.isMultiSelecting = self.isMultiSelecting;
                [self.superViewController pushViewController:contactsListViewController];
                [contactsListViewController release];
                self.shouldStack = NO;
            } else {
                [self.superViewController reloadRightViewControllerWithDepartmentId:departmentId];
            }
            
            [self.tableView reloadData];
            [self selectTheSelectedCell];
            
            
        } else {
                        
            [self pushToUserInfoViewControllerForUser:user];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
    }
}

- (void)refreshTheSelectedUser:(IMUser*)user isSelected:(BOOL)isSelected {
    if (isSelected) {
        if ([self.superViewController.selectedUsers containsObject:user]) {
            return;
        } else {
            [self.superViewController.selectedUsers addObject:user];
            UIImage *image = [Public imageOfUser:user];
            [self.superViewController.selectedBar appendItemWithImage:image withID:user.userID];
        }
    } else {
        if ([self.superViewController.selectedUsers containsObject:user]) {
            [self.superViewController.selectedUsers removeObject:user];
            [self.superViewController.selectedBar deleteItemWithID:user.userID];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
