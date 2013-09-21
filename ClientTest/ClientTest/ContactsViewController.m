//
//  ContactsViewController.m
//  IMLite
//
//  Created by Ethan on 13-8-21.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactsListViewController.h"
#import "UserInfoViewController.h"
#import "ContactUserCell.h"
#import "GOSearchBar.h"
#import <ASIHttpRequest.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <JSONKit.h>
#import "Public.h"
#import <IMContext.h>
#import "SVPullToRefresh.h"


@interface ContactsViewController () {
    
    StackedLevelViewController *_stackLevelViewController;
    
    ContactsListViewController *_rootListViewController;
    
//    BOOL _hasLoad;
    
    BOOL _isLoading;
    
}

@property (nonatomic, retain) ASIHTTPRequest *lastRequest;

@end

@implementation ContactsViewController

- (void)dealloc {
    [_stackLevelViewController release];
    _stackLevelViewController = nil;
    
    [_rootListViewController release];
    _rootListViewController = nil;
    
    self.searchController = nil;
    
    self.selectedBar = nil;
    
    self.selectedUsers = nil;
    
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
    }
    self.lastRequest = nil;
    
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
    self.title = @"组织";
    
    if (del.userInOutFlag == UserInOutFlagOut) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.labelText = @"该功能暂不提供给外部人员使用";
//        hud.mode = MBProgressHUDModeText;
//        [hud hide:YES afterDelay:2.0f];
        return;
    }
    
    _rootListViewController = [[ContactsListViewController alloc] init];
    _rootListViewController.departmentId = @"0";
    _rootListViewController.superViewController = self;
    _rootListViewController.isMultiSelecting = self.isMultiSelecting;
    if (self.isMultiSelecting) {
        _stackLevelViewController = [[StackedLevelViewController alloc] initWithRootViewController:_rootListViewController withFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - 44 - 20 - 44.0 - 49)];
    }
    else {
        // minus tabBar height
        _stackLevelViewController = [[StackedLevelViewController alloc] initWithRootViewController:_rootListViewController withFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - 44 - 20 - 44 - 49)];
    }
        
    _stackLevelViewController.delegate = self;

    [self addChildViewController:_stackLevelViewController];
    [self.view addSubview:_stackLevelViewController.view];
    
    
    [_rootListViewController.tableView addPullToRefreshWithActionHandler:^{
        [_rootListViewController getContentInfoWithDepartmentID:_rootListViewController.departmentId];
    }];
    
    [_rootListViewController.tableView.pullToRefreshView setTitle:@"      下拉刷新" forState:SVPullToRefreshStateAll];
    [_rootListViewController.tableView.pullToRefreshView setTitle:@"      释放刷新" forState:SVPullToRefreshStateTriggered];
    [_rootListViewController.tableView.pullToRefreshView setTitle:@"        刷新中" forState:SVPullToRefreshStateLoading];
    
    [self addSearchBar];

    
}

- (void) addSearchBar {
    GOSearchBar *searchBar = [[GOSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    searchBar.delegate = self;
    self.searchController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
    self.searchController.delegate = self;
    searchBar.placeholder = @"输入名字或拼音";
    [self.view addSubview:searchBar];
    
    
    [searchBar release];
}

- (void)addPullToRefreshToRootListView {
    [_rootListViewController.tableView setShowsPullToRefresh:YES];
}

- (void)removePullToRefreshFromRootListView {
    [_rootListViewController.tableView setShowsPullToRefresh:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (del.userInOutFlag == UserInOutFlagOut) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"该功能暂不提供给外部人员使用";
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0f];
        return;
    }
    
//    else if (_hasLoad && _rootListViewController == _stackLevelViewController.rightViewController && !_rootListViewController.isLoading && !_rootListViewController.isSearching) {
////        [_stackLevelViewController popToRootViewController];
////        _rootListViewController.isLeft = NO;
////        _rootListViewController.shouldStack = YES;
////        _rootListViewController.isSearching = NO;
////        [_rootListViewController.tableView reloadData];
//        [_rootListViewController getContentInfoWithDepartmentID:_rootListViewController.departmentId];
//    }
//    _hasLoad = YES;
}


- (void)setIsMultiSelecting:(BOOL)isMultiSelecting {
    _isMultiSelecting = isMultiSelecting;
    
    _rootListViewController.isMultiSelecting = _isMultiSelecting;
    
    if (_isMultiSelecting && self.selectedBar == nil) {
        
        self.selectedUsers = [NSMutableArray array];
        
        self.selectedBar = [[[GOSelectedBar alloc] initWithFrame:CGRectMake(0.0, self.view.height - 49.0, self.view.width, 49.0)] autorelease];
		self.selectedBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.selectedBar setDoneTarget:self action:@selector(selectionDone:)];
        [self.view addSubview:self.selectedBar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectNotificationReceived:) name:GOSelectedBarItemDidDeselectNotification object:nil];
        
    } else if (!_isMultiSelecting && self.selectedBar != nil) {
        
        [self.selectedBar removeFromSuperview];
        self.selectedBar = nil;
        self.selectedUsers = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GOSelectedBarItemDidDeselectNotification object:nil];
        
    }

}

- (void)deselectNotificationReceived:(NSNotification *)notification
{
    NSString *deletedID = notification.userInfo[@"delete"];
    
    for (int i = 0; i < self.selectedUsers.count; ++i) {
        IMUser *user = self.selectedUsers[i];
        if ([user.userID isEqualToString:deletedID]) {
            [self.selectedUsers removeObject:user];
            return;
        }
    }

}

- (void)selectionDone:(id)sender
{
    
    for (IMUser *user in self.selectedUsers) {
        if ([user.userID isEqualToString:[IMContext sharedContext].loginUser.userID]) {
            [self.selectedUsers removeObject:user];
            break;
        }
    }
    
    if (self.selectedUsers.count == 0) {
        return;
    }
    
	[self.searchController setActive:NO];
    if ([self.delegate respondsToSelector:@selector(ContactsViewController:didFinishSelectionWithUsers:)]) {
        
        NSArray *array = [self.selectedUsers copy];
        [self.delegate ContactsViewController:self didFinishSelectionWithUsers:array];
        
    }
}

- (void)popViewController {
    [_stackLevelViewController popViewControllerAnimated:YES];
}

- (void)pushViewController:(UIViewController*)viewController {
    
    [_stackLevelViewController pushStackViewController:viewController animated:YES];
    
}

- (void)reloadRightViewControllerWithDepartmentId:(NSString*)departmentId {
    ContactsListViewController *listViewController = (ContactsListViewController*)_stackLevelViewController.rightViewController;
    NSMutableArray *contentArray;
    NSMutableArray *departmentIDArray;
    if (listViewController.isSearching) {
        contentArray = listViewController.searchArray;
        departmentIDArray = listViewController.searchDepartmentArray;
    } else {
        contentArray = listViewController.contentArray;
        departmentIDArray = listViewController.departmentIDArray;
    }
    
    if (contentArray.count > 0 || departmentIDArray.count > 0) {
        [contentArray removeAllObjects];
        [departmentIDArray removeAllObjects];
        [listViewController.tableView reloadData];
    }
    
    [listViewController getContentInfoWithDepartmentID:departmentId];
    
}

#pragma mark - StackedLevelViewControllerDelegate

- (void)stackedLevelViewControllerBeginPush:(StackedLevelViewController *)stackedLevelViewController {
    if (!self.navigationItem.leftBarButtonItem || self.isMultiSelecting) {
        
        self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"上级目录" target:self action:@selector(popViewController)];
        //        ContactsListViewController *listViewController = (ContactsListViewController*)_stackLevelViewController.leftViewController;
        //        [listViewController selectTheSelectedCell];
    }
    
    ContactsListViewController *listViewController = (ContactsListViewController*)_stackLevelViewController.rightViewController;
    if (listViewController == _rootListViewController && !_rootListViewController.isSearching) {
        [self removePullToRefreshFromRootListView];
    }
}

- (void)stackedLevelViewControllerBeginPop:(StackedLevelViewController *)stackedLevelViewController {
    
    ContactsListViewController *listViewController = (ContactsListViewController*)_stackLevelViewController.leftViewController;
    [listViewController deselectTheSelectedCell];
    listViewController.shouldStack = YES;
    listViewController.isLeft = NO;
    [listViewController.tableView reloadData];
    
    ContactsListViewController *rlistViewController = (ContactsListViewController*)_stackLevelViewController.rightViewController;
    if (rlistViewController.lastRequest && !rlistViewController.lastRequest.isFinished) {
        [rlistViewController.lastRequest clearDelegatesAndCancel];
        rlistViewController.lastRequest = nil;
        
        [MBProgressHUD hideAllHUDsForView:rlistViewController.view animated:NO];
    }

}

- (void)stackedLevelViewControllerFinishedPop:(StackedLevelViewController *)stackedLevelViewController {
    
    if (_stackLevelViewController.leftViewController == nil) {
        if (self.isMultiSelecting) {
            self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:self action:@selector(navigationBack:)];
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
        if (!_rootListViewController.isSearching) {
            [self addPullToRefreshToRootListView];
        }
    } 
}

//- (void)stackedLevelViewControllerFinishedPush:(StackedLevelViewController *)stackedLevelViewController {
//    
//    if (_stackLevelViewController.leftViewController && !self.navigationItem.leftBarButtonItem) {
//        
//         self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回上一级" target:self action:@selector(popViewController)];
////        ContactsListViewController *listViewController = (ContactsListViewController*)_stackLevelViewController.leftViewController;
////        [listViewController selectTheSelectedCell];
//    }
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 51.0f;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.searchResultArray.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellID = @"cellID";
//    
//     ContactUserCell *cell = (ContactUserCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
//    
//    if (cell == nil) {
//        cell = [[[ContactUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID] autorelease];
//    }
//    
//    IMUser *user = self.searchResultArray[indexPath.row];
//
//    cell.user = user;
//    
//    return cell;
//}

//#pragma mark - UITableView Delegate Methods
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    IMUser *user = (IMUser *)self.searchResultArray[indexPath.row];
//    UserInfoViewController *infoVC = [[[UserInfoViewController alloc] initWithUser:user] autorelease];
//    infoVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
//    infoVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:infoVC animated:YES];
//    
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleNone;
//}

- (void)popToRootViewController {
    [_stackLevelViewController popToRootViewController];
    [_rootListViewController deselectTheSelectedCell];
    _rootListViewController.isLeft = NO;
    _rootListViewController.shouldStack = YES;
    [_rootListViewController.tableView scrollToFirstRow:NO];
}

#pragma mark - UISearchDisplayDelegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // can be overiden
//	UIView *v = [controller valueForKeyPath:@"_dimmingView"];
//	v.hidden = NO;
//    return NO;
//    [self searchDidCommitWithString:searchString duringChange:YES];
//    return YES;
    _rootListViewController.isSearching = YES;
    [_rootListViewController.tableView reloadData];
    return NO;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {

    [self popToRootViewController];
    _rootListViewController.isSearching = NO;
    [_rootListViewController.tableView reloadData];
    [self addPullToRefreshToRootListView];
    
    if (self.isMultiSelecting) {
        self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:self action:@selector(navigationBack:)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    if ([controller.searchBar isMemberOfClass:[GOSearchBar class]]) {
        [(GOSearchBar*)controller.searchBar setCancelButton];
    }
    [self removePullToRefreshFromRootListView];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{

//    [_stackLevelViewController popToRootViewController];
//    _rootListViewController.shouldStack = YES;
//    _rootListViewController.isLeft = NO;
////    _hasLoad = NO;
//    [_rootListViewController deselectTheSelectedCell];
    [self popToRootViewController];
    self.searchController.searchResultsTableView.hidden = YES;

    if(self.isMultiSelecting) {
        CGRect frame =  self.searchController.searchResultsTableView.frame;
        self.searchController.searchResultsTableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - 49.0);
    }
    _stackLevelViewController.view.frame = self.searchController.searchResultsTableView.frame;
    _rootListViewController.view.frame = CGRectMake(0, 0, _stackLevelViewController.view.frame.size.width, _stackLevelViewController.view.frame.size.height);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{

    if ([_rootListViewController isLoading] && _rootListViewController.lastRequest && !_rootListViewController.lastRequest.isFinished) {
        [_rootListViewController.lastRequest clearDelegatesAndCancel];
        _rootListViewController.lastRequest = nil;
        
        if (_rootListViewController.tableView.pullToRefreshView && _rootListViewController.tableView.showsPullToRefresh) {
            [_rootListViewController.tableView.pullToRefreshView stopAnimating];
        }
        
        [MBProgressHUD hideAllHUDsForView:_rootListViewController.view animated:NO];
    }
    
    [self searchDidCommitWithString:searchBar.text duringChange:NO];

}


- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    
    CGRect frame = CGRectMake(0.0, 44, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - 44 - 20 - 44- 49);
    _stackLevelViewController.view.frame = frame;
    _rootListViewController.view.frame = CGRectMake(0, 0, _stackLevelViewController.view.frame.size.width, _stackLevelViewController.view.frame.size.height);
    _rootListViewController.isSearching = NO;
    [_rootListViewController.tableView reloadData];
    
    
}

- (void)searchDidCommitWithString:(NSString *)searchStr duringChange:(BOOL)isChanging
{
    
//    if (_isLoading) {
//        return;
//    }

    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *api = [[NSString stringWithFormat:@"%@%@%@", SEARCH_INFO_API, searchStr, [del apiString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api]];
    request.delegate = self;
    [request setDidFailSelector:@selector(searchInfoFailed:)];
    [request setDidFinishSelector:@selector(searchInfoFinished:)];
    [request setTimeOutSeconds:10.0f];
//    [request setNumberOfTimesToRetryOnTimeout:3];
    [request startAsynchronous];
    self.lastRequest = request;
    _isLoading = YES;
}

- (void)searchInfoFinished:(ASIHTTPRequest*)request {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    _isLoading = NO;
    self.lastRequest = nil;

    NSDictionary *dic = [[request responseString] objectFromJSONString];
    
    if (dic && [dic[@"ok"] boolValue]) {
        
        [_rootListViewController.searchArray removeAllObjects];
        [_rootListViewController.searchDepartmentArray removeAllObjects];
        
        NSArray *departments = dic[@"departments"];
        NSArray *peoples = dic[@"peoples"];
        
        for (int i = 0; i < departments.count; ++i) {
            NSDictionary *department = departments[i];
            IMUser *user = [[IMUser alloc] init];
            user.nickname = [Public formatStringifNull:department[@"name"]];
            [_rootListViewController.searchArray addObject:user];
            [user release];
            NSString *departmentID = [Public formatStringifNull:department[@"id"]];
            [_rootListViewController.searchDepartmentArray addObject:departmentID];
        }
        
        for (int i = 0; i < peoples.count; ++i) {
            NSDictionary *people = peoples[i];
            IMUser *user = [[IMUser alloc] init];
            user.userID = [[[Public formatStringifNull:people[@"user"]] sha1Hash] stringByAppendingString:SERVER_DOMAIN];
            user.nickname = [Public formatStringifNull:people[@"name"]];
            NSString *avatarPath = [Public formatStringifNull:people[@"avatar"]];;
            user.userType = IMUserTypeP2P;
            user.avatarPath = avatarPath;// [Public urlImagePathToLocalImagePathAndSave:avatarPath user:user overWrite:NO];
            [_rootListViewController.searchArray addObject:user];
            [user release];
            NSString *departmentID = NOT_DEPARTMENT;
            [_rootListViewController.searchDepartmentArray addObject:departmentID];
        }
        
        [_rootListViewController.tableView reloadData];
        [_rootListViewController.tableView scrollToFirstRow:NO];
        
    } else {
        
        NSString *errorString = nil;
        if (dic && dic[@"error"]) {
            errorString = dic[@"error"];
        } else {
            errorString = @"请检查网络配置是否正确";
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"搜索失败";
        hud.detailsLabelText = errorString;
        [hud hide:YES afterDelay:2.0f];
    }   

}

- (void)searchInfoFailed:(ASIHTTPRequest*)request {
    
    _isLoading = NO;
    
    self.lastRequest = nil;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"搜索失败";
    hud.detailsLabelText = @"请检查网络配置是否正确";
    [hud hide:YES afterDelay:2.0f];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
