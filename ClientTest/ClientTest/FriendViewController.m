//
//  ContactsViewController.m
//  GoComIM
//
//  Created by 王鹏 on 13-4-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "FriendViewController.h"
#import "GOContactCell.h"
#import "PPCore.h"
#import "UIView+PPCategory.h"
#import "AppDelegate.h"
#import "NSArray+PPCategory.h"
#import <IMUser.h>
#import "IMLiteUtil.h"
#import "UserInfoViewController.h"
#import <IMContext.h>

@interface FriendViewController () 

@property (nonatomic, retain) NSMutableArray *indexTitlesArray;
@property (nonatomic, retain) NSDictionary *indexForUserArray;
@property (nonatomic, retain) NSArray *filteredUsers;
@property (nonatomic, copy) NSString *currentSearchingString;
@property (nonatomic, retain) NSMutableArray *selecetedUsers;
@property (nonatomic, assign) NSInteger totalUserCount;

@end

@implementation FriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		
	}
	return self;
}
- (void)dealloc
{
	[del.client.xmppRoster removeDelegate:self];
    PP_RELEASE(_indexTitlesArray);
    PP_RELEASE(_filteredUsers);
    PP_RELEASE(_currentSearchingString);
	PP_RELEASE(_indexForUserArray);
    PP_RELEASE(_selecetedUsers);
    [super dealloc];
}

#pragma mark - Roster

- (void)xmppRosterDidChange:(XMPPRosterSqlStorage *)sender
{
	NSArray *array = [del.client allFirstLetterAndUserInRoster];
	
	self.indexTitlesArray = [array objectOrNilAtIndex:0];
	self.indexForUserArray = [array objectOrNilAtIndex:1];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
	});
}


#pragma mark -

- (void)loadView
{
    [super loadView];
    
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [del.client.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _selecetedUsers = [[NSMutableArray alloc] init];
    
    self.deletable = YES;
    self.searchable = YES;
    self.title = @"通讯录";
//    [self.tableView setContentOffset:CGPointMake(0.0, self.searchController.searchBar.height)];
	if (self.showAdd)
	{
		self.navigationItem.rightBarButtonItem = [UIHelper navBarButtonWithTitle:@"添加" target:self action:@selector(addFromOrg)];
	}
	
	NSArray *array = [del.client allFirstLetterAndUserInRoster];
	
	self.indexTitlesArray = [array objectOrNilAtIndex:0];
	self.indexForUserArray = [array objectOrNilAtIndex:1];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
	});
    
    self.searchController.searchBar.placeholder = @"输入名字或拼音";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)contentArrayInSection:(NSUInteger)section
{
	NSString *key = [self.indexTitlesArray objectOrNilAtIndex:section];
	if (key) {
		return [self.indexForUserArray objectForKey:key];
	}
	return nil;
}

//- (void)deselectNotificationReceived:(NSNotification *)notification
//{
//    NSString *deletedID = notification.userInfo[@"delete"];
//    
////    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
////    
////    [visibleIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop){
////        NSMutableArray *correspondingArray = [self contentArrayInSection:indexPath.section];
////        IMUser *user = correspondingArray[indexPath.row];
////        if ([user.userID isEqualToString:deletedID]) {
////            GOContactCell *cell = (GOContactCell *)[self.tableView cellForRowAtIndexPath:indexPath];
////            cell.multiSelected = NO; // won't execute completionBlock
////        }
////    }];
//}

- (void)selectionDone:(id)sender
{
//	[self.searchController setActive:NO];
//    if ([self.delegate respondsToSelector:@selector(friendViewController:didFinishSelectionWithUsers:)]) {
//        NSMutableArray *mutableUsers = [NSMutableArray array];
//        NSArray *selectedIndexPaths = [self multiSelectedIndexPaths];
//        
//        [selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop){
//            NSArray *contentArrayInSection = [self contentArrayInSection:indexPath.section];
//            IMUser *user = contentArrayInSection[indexPath.row];
//            [mutableUsers addObject:user];
//        }];
//        
//        [self.delegate friendViewController:self didFinishSelectionWithUsers:mutableUsers];
//    }
}

- (void)pushToUserInfoViewControllerForUserAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *contentArrayInSection = [self contentArrayInSection:indexPath.section];
    UserInfoViewController *infoVC = [[UserInfoViewController alloc] initWithUser:contentArrayInSection[indexPath.row]];
    infoVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
	infoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoVC animated:YES];
    [infoVC release];
}

#pragma mark - Inherited Methods

- (void)setMultiSelect:(BOOL)multiSelect
{
    [super setMultiSelect:multiSelect];
    
//    if (multiSelect == YES && _selectedBar == nil) {
//        _selectedBar = [[GOSelectedBar alloc] initWithFrame:CGRectMake(0.0, self.view.height - 49.0, self.view.width, 49.0)];
//		_selectedBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//        [self.view addSubview:_selectedBar];
//		self.tableView.height -= 49;
////		self.selectedBar.top = self.view.height - 44 - 49;
//        [self.selectedBar setDoneTarget:self action:@selector(selectionDone:)];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectNotificationReceived:) name:GOSelectedBarItemDidDeselectNotification object:self.selectedBar];
//    }
    
    if(multiSelect)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 50.0, 44.0);
        [btn setBackgroundImage:[UIImage imageNamed:@"nav_btn_confirm"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(conFirm:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        _selectedBar = [[SelectedBar alloc] initWithFrame:CGRectMake(0, self.view.height - 44.0, self.view.width, 44.0)];
        self.selectedBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.selectedBar.checkBox.left = 267.0;
        [self.selectedBar setNameLabelText:@"选择全部好友"];
        [self.view addSubview:self.selectedBar];
        self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 44.0);
        
        self.totalUserCount = 0;
        for (NSString *key in self.indexTitlesArray) {
            for (IMUser *user in [self.indexForUserArray objectForKey:key])
            {
                if (user.userType == IMUserTypeP2P) {
                    self.totalUserCount++;
                }
            }
        }
        
        __block typeof(self) weakSelf = self;
        self.selectedBar.allSelectedBlock = ^(BOOL isSelected)
        {
            if(isSelected)
            {
                [weakSelf.selecetedUsers removeAllObjects];
                for (NSString *key in weakSelf.indexTitlesArray) {
                    for (IMUser *user in [weakSelf.indexForUserArray objectForKey:key])
                    {
                        if (user.userType == IMUserTypeP2P) {
                            [weakSelf.selecetedUsers addObject:user];
                        }
                    }
                }
            }
            else
            {
                [weakSelf.selecetedUsers removeAllObjects];
            }
            
            [weakSelf setConfirmButtonEnable];
            [weakSelf.tableView reloadData];
        };
    }
}

- (void)setAllSelected
{
    if(self.totalUserCount == self.selecetedUsers.count)
    {
        self.selectedBar.isSelected = YES;
    }
    else if((self.totalUserCount - 1) == self.selecetedUsers.count)
    {
        self.selectedBar.isSelected = NO;
    }
}

- (void)conFirm:(id)sender
{
    [self.searchController setActive:NO];
    if ([self.delegate respondsToSelector:@selector(friendViewController:didFinishSelectionWithUsers:)])
    {
        [self.delegate friendViewController:self didFinishSelectionWithUsers:self.selecetedUsers];
    }
}

- (void)setConfirmButtonEnable
{
    self.navigationItem.rightBarButtonItem.enabled = self.selecetedUsers.count > 0;
}


- (void)cellDidBeDeletedForIndexPath:(NSIndexPath *)indexPath
{
//    NSMutableArray *correspondingArray = [self contentArrayInSection:indexPath.section];
//    IMUser *user = correspondingArray[indexPath.row];
//    
//	
//    [correspondingArray removeObjectAtIndex:indexPath.row];
//    [[GOContactsCache sharedContactsCache] deleteUserInSortedCache:user];
//    
//    // if correspondingArray is empty, remove the index.
//    if (correspondingArray.count == 0) {
//        [self.contentArray removeObjectAtIndex:indexPath.section];
//        [self.indexTitlesArray removeObjectAtIndex:indexPath.section];
//        // wait until the delete animation finished
//        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
//        // TODO: remove this contact send to server
//		
//    }
	
}
/////




- (void)searchDidCommitWithString:(NSString *)string duringTextChanging:(BOOL)isChanging
{
    self.currentSearchingString = string;
	self.filteredUsers = [del.client searchFriendsWithKey:string];
	if (self.searchController.isActive && isChanging == NO) {
		[self.searchController.searchResultsTableView reloadData];
	}
 }

#pragma mark - UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (tableView == self.searchController.searchResultsTableView)? 1 : self.indexTitlesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView) {
        return [self.filteredUsers count];
    }
    else {
        return [self contentArrayInSection:section].count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	return 51;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return (tableView == self.searchController.searchResultsTableView) ? nil : self.indexTitlesArray;
}

- (NSInteger)tableView:tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return (tableView == self.searchController.searchResultsTableView) ? 0 : index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section >= self.indexTitlesArray.count) {
		return @"";
	}
	NSString *str = self.indexTitlesArray[section];
	if ([str isEqualToString:@"$"]) {
		str = @"群";
	}
    return (tableView == self.searchController.searchResultsTableView) ? nil : str;
}

- (UITableViewCell *)tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactCellID";
    
    GOContactCell *cell = (GOContactCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[GOContactCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
        cell.canMultiSelectThroughSelect = YES;
    }
    
    __block typeof(self) weakSelf = self;
    NSArray *contentArrayInSection = [self contentArrayInSection:indexPath.section];
    IMUser *user = nil;
    
    if (tableView == self.searchController.searchResultsTableView)
        user = self.filteredUsers[indexPath.row];
    else
        user = contentArrayInSection[indexPath.row];
    
//    UIImage *thumbnail = nil;
//	if (user.userType & IMUserTypeDiscuss) {
//		thumbnail = [UIImage imageNamed:@"avatar_discussion"];
//	} else {
//		if (user.avatarPath.length <= 0)
//			thumbnail = [UIImage imageNamed:@"avatar_user"];
//	}
//    [self configureForMultiSelectCell:cell forIndexPath:indexPath additionalBlock:^(BOOL mSelected){
//        if (mSelected)
//		{
//			if (thumbnail) {
//				[weakSelf.selectedBar appendItemWithImage:thumbnail withID:user.userID];
//			} else {
//				[weakSelf.selectedBar appendItemWithURL:[NSURL URLWithString:user.avatarPath] withID:user.userID];
//			}
//		}
//        else
//            [weakSelf.selectedBar deleteItemWithID:user.userID];
//    }];
    
//    [cell setThumbnail:thumbnail name:user.nickName];
    if (user.userType == IMUserTypeDiscuss) {
        cell.multiSelected = NO;
    } else {
        cell.multiSelected = [self.selecetedUsers indexOfObject:user] != NSNotFound;
    }
    cell.multiSelectedBlock = ^(BOOL isSelected)
    {
        if(isSelected)
        {
            [weakSelf.selecetedUsers addObject:user];
        }
        else if(!isSelected)
        {
            [weakSelf.selecetedUsers removeObject:user];
        }
        
        [self setConfirmButtonEnable];
        [self setAllSelected];
    };
    
	cell.showDepart = YES;
	cell.imUser = user;
    
    cell.accessoryActionBlock = ^(GOContactCell *cCell){
        [weakSelf pushToUserInfoViewControllerForUserAtIndexPath:indexPath];
    };
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMultiSelecting) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
	else if(self.isSearchLoading)
	{
		UserInfoViewController *infoVC = [[UserInfoViewController alloc] initWithUser:[self.filteredUsers objectOrNilAtIndex:indexPath.row]];
		infoVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
		infoVC.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:infoVC animated:YES];
		[infoVC release];
	}
    else
	{
//		NSArray *contentArrayInSection = [self contentArrayInSection:indexPath.section];
//		IMUser *user = [contentArrayInSection objectAtIndex:indexPath.row];
//	[[NSNotificationCenter defaultCenter] postNotificationName:kGoChatViewContrllerNote object:user];
//		return;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // push to detail VC
        [self pushToUserInfoViewControllerForUserAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
			
			NSMutableArray *correspondingArray = [self contentArrayInSection:indexPath.section];
			IMUser *user = correspondingArray[indexPath.row];
			if (user.userType & IMUserTypeDiscuss) {
                BOOL isAdim = [del.client.xbRosterStorage memberIsAdmin:[IMContext sharedContext].loginUser.userID withDgid:user.userID];
                if (isAdim)
                    [del.client.xbRoster deleteDiscussGroup:user.userID];
                else
                    [del.client.xbRoster qiutDiscussGroup:user.userID];
			} else
				[del.client.xbRoster removeUser:[XMPPJID jidWithString:user.userID]];
		}
    }
}
#pragma mark - UISearch Delegate Methods

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    self.filteredUsers = nil;
    
    // if we are multiSelecting, the check status may be changed on self.tableView
    if (self.isMultiSelecting) {
        [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    controller.searchResultsTableView.editing = self.isMultiSelecting;
    
    if(self.isMultiSelecting)
        controller.searchResultsTableView.height -= 44.0;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[super searchBarSearchButtonClicked:searchBar];
	//[self.view bringSubviewToFront:self.selectedBar];
}

#pragma mark
- (void)addFromOrg
{
//	OrgViewController *orgvc = [[OrgViewController alloc]initWithNibName:nil bundle:nil];
//    orgvc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:orgvc action:@selector(navigationBack:)];
//    orgvc.title = @"添加联系人";
//    orgvc.navigationItem.rightBarButtonItem = [UIHelper navBarButtonWithTitle:@"取消" target:self action:@selector(cancelAdd)];
//	orgvc.multiSelect = YES;
//    orgvc.isFromContacts = YES;
//	orgvc.delegate = self;
//	orgvc.hidesBottomBarWhenPushed = YES;
//    orgvc.selectedBar.isCountGRP = YES;
//	
//	[self.navigationController pushViewController:orgvc animated:YES];
//	[orgvc release];
}

- (void)cancelAdd
{
//    [[GOOrgCache sharedOrgCache] uncheckAllUser];
//    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark - Delegate
//- (void)orgViewController:(OrgViewController *)orgVC didFinishSelectionWithUsers:(NSArray *)users
//{
//	if (!_userOperation)
//	{
//		_userOperation = [[GoUserOperation alloc]init];
//	}
//	NSMutableArray *resArray = [NSMutableArray array];
//	for (IMUser *user in users)
//	{
//		//
//		if ([[GOContactsCache sharedContactsCache] isUserInContacts:user])
//		{
//			continue;
//		}
//		[resArray addObject:user];
//	}
//	
//	if (resArray.count > 0)
//	{
//		__block typeof(self) weakSelf = self;
//		[_userOperation modifyAdb:resArray del:nil showView:self.view finishBlock:^(BOOL success, NSError *error, NSDictionary *info) {
//			
//			for (IMUser *user in resArray)
//			{
//				[[GOContactsCache sharedContactsCache] insertUserToSortedCache:user];
//				[weakSelf fetchContactsData];
//			}
//		}];
//	}
//	
//	[orgVC.navigationController popViewControllerAnimated:NO];
//}
@end
