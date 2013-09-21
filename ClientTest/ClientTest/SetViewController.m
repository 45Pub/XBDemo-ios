//
//  SetViewController.m
//  IMLite
//
//  Created by pengjay on 13-7-16.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "SetViewController.h"
#import "AppDelegate.h"
#import "IMLiteUtil.h"
#import "GOSettingCell.h"
#import "SettingEditingViewController.h"
#import <IMContext.h>
#import <IMUser.h>
#import <XMPPvCardTempModule.h>
#import <XMPPvCardTemp.h>
#import <IMChatSessionManager.h>
#import <IMMsgStorage.h>
#import "UIAlertView+Blocks.h"
#import "PrivacyViewController.h"
#import "MBProgressHUD.h"
#import "IMConfiguration.h"
#import "IMDefaultConfigurator.h"
#import <IMUser.h>
#import "ASIFormDataRequest.h"
#import <JSONKit.h>
#import "Public.h"
#import <IMContext.h>
#import "PwdChangeViewController.h"

#define ACTION_SHEET_SIGNOUT_TAG 1234
#define ACTION_SHEET_PHOTO_TAG 1233

#define INFO_TYPE_NAME @"name"
#define INFO_TYPE_MOBILEPHONE @"phone"
#define INFO_TYPE_FIXPHONE @"tel"
#define INFO_TYPE_EMAIL @"email"
#define INFO_TYPE_AVATAR @"avatar"
#define INFO_TYPE_PSWD @"pwd"
#define INFO_TYPE_AREA @"area"


@interface SetViewController ()
//临时假数据
//@property (nonatomic, retain) NSString *sign;
//
//@property (nonatomic, retain) NSString *mail;
//
//@property (nonatomic, retain) NSString *phone;
//
//@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) NSArray *provineceArray;
@property (nonatomic, copy) NSString *departmentString;
//@property (nonatomic, assign) BOOL hasLoad;
@property (nonatomic, copy) NSString *currentInfoType;
@property (nonatomic, copy) NSString *currentInfoValue;
@property (nonatomic, assign) BOOL loadSuccess;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, retain) ASIHTTPRequest *lastRequest;
@property (nonatomic, retain) NSData *currentAvatarData;
@property (nonatomic, assign) int lastSelectedProvineceIndex;

@end

@implementation SetViewController

- (void)dealloc {
    self.departmentString = nil;
    self.toolBar = nil;
    self.pickerView = nil;
    self.provineceArray = nil;
    
    self.currentInfoValue = nil;
    self.currentInfoType = nil;
    self.currentAvatarData = nil;
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
    }
    self.lastRequest = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = @"设置";
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Provineces.plist" ofType:nil];
        self.provineceArray = [NSArray arrayWithContentsOfFile:path];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentInfoValue = nil;
    self.currentInfoType = nil;
    self.currentAvatarData = nil;
    self.lastRequest = nil;
    _loadSuccess = NO;
    _isLoading = NO;
    self.lastSelectedProvineceIndex = 0;

	[self initContentArray];
	[self.tableView reloadData];
    
    if (del.userInOutFlag == UserInOutFlagOut) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, self.view.frame.size.width, 40)];
        NSMutableArray *myToolBarItems = [NSMutableArray array];
        
        [myToolBarItems addObject:[[[UIBarButtonItem alloc]
                                    initWithTitle:@"取消"
                                    style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(pickercancel)] autorelease]];
        
        UIBarButtonItem *flexibleSpaceItem;
        flexibleSpaceItem =[[[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:self
                             action:NULL]autorelease];
        [myToolBarItems addObject:flexibleSpaceItem];
        
        [myToolBarItems addObject:[[[UIBarButtonItem alloc]
                                    initWithTitle:@"完成"
                                    style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(pickerDone)] autorelease]];
        [_toolBar setItems:myToolBarItems animated:YES];
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height+40, self.view.frame.size.width, 180)];
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.hidden = YES;
        
        [self.view addSubview:_toolBar];
        [self.view addSubview:_pickerView];

    }
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self hidePickerViewAnimates:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_loadSuccess && !_isLoading) {
        [self requestForUserInfo];
    }
}

- (void)pickercancel {
    [self hidePickerViewAnimates:YES];
    self.lastSelectedProvineceIndex = 0;
}

- (void)pickerDone {
    int row1 = [self.pickerView selectedRowInComponent:1];
    NSString *value = [NSString stringWithFormat:@"%@%@", self.provineceArray[self.lastSelectedProvineceIndex][@"P_Name"], self.provineceArray[self.lastSelectedProvineceIndex][@"Citys"][row1][@"C_Name"]];
    [self changeUserInfo:INFO_TYPE_AREA value:value showHudView:self.view];
    [self hidePickerViewAnimates:YES];
    self.lastSelectedProvineceIndex = 0;
}

- (void)showPickerView {
    
    self.lastSelectedProvineceIndex = 0;
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
    [self.pickerView selectRow:0 inComponent:1 animated:NO];
    [self.pickerView reloadComponent:1];
    if (self.pickerView.hidden == NO) {
        return;
    }
    self.pickerView.hidden = NO;
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.pickerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-20-weakSelf.navigationController.navigationBar.height-weakSelf.tabBarController.tabBar.height-180, weakSelf.view.frame.size.width, 180);
        weakSelf.toolBar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-20-weakSelf.navigationController.navigationBar.height-weakSelf.tabBarController.tabBar.height-180-40, weakSelf.view.frame.size.width, 40);
    }];
}

- (void)hidePickerViewAnimates:(BOOL)animates {
    
    self.lastSelectedProvineceIndex = 0;
    
    __block typeof(self) weakSelf = self;
    void (^animationsBlock)(void) = ^{
        weakSelf.pickerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-40, weakSelf.view.frame.size.width, 180);
        weakSelf.toolBar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, weakSelf.view.frame.size.width, 40);
    };
    void (^completeBlock)(BOOL) = ^(BOOL finished){
        weakSelf.pickerView.hidden = YES;
    };
    if (animates) {
        [UIView animateWithDuration:0.2f animations:animationsBlock completion:completeBlock];
    } else {
        animationsBlock();
        completeBlock(YES);
    }
    Block_release(animationsBlock);
    Block_release(completeBlock);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if (component == 0) {
        return self.provineceArray.count;
    } else {
        return [[[self.provineceArray objectAtIndex:[pickerView selectedRowInComponent:0]] objectForKey:@"Citys"] count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
        return [self.provineceArray[row] objectForKey:@"P_Name"];
    } else {
        NSArray *citys = [[self.provineceArray objectAtIndex:self.lastSelectedProvineceIndex] objectForKey:@"Citys"];
        return [[citys  objectAtIndex:row] objectForKey:@"C_Name"];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (component == 0) {
        self.lastSelectedProvineceIndex = row;
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)cellInfoWithTitle:(NSString *)title detail:(id)detail
{
    if (detail)
        return @{@"title" : title, @"detail" : detail};
    else
        return @{@"title": title};
}

- (NSArray *)userInfoArray
{
    
    if (del.userInOutFlag == UserInOutFlagOut) {
        self.departmentString = @"地区";
    } else {
        self.departmentString = @"部门";
    }
    
    IMUser *user = [[IMContext sharedContext] loginUser];
    UIImage *image = [Public imageOfUser:user];
    NSMutableArray *userInfoArray = [NSMutableArray arrayWithArray:@[[self cellInfoWithTitle:@"头像" detail:image],
                               [self cellInfoWithTitle:@"姓名" detail:user.nickname],
                               [self cellInfoWithTitle:self.departmentString detail:@""],
                               [self cellInfoWithTitle:@"手机" detail:@""],
                               [self cellInfoWithTitle:@"电话" detail:@""],
                               [self cellInfoWithTitle:@"邮箱" detail:@""]]];
    
    [self requestForUserInfo];
    
	return userInfoArray;
	
}

- (void)requestForUserInfo {
    
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    IMUser *user = [[IMContext sharedContext] loginUser];
    NSString *userID = [user.userID substringToIndex:(user.userID.length-SERVER_DOMAIN.length)];
    NSString *api = [[NSString stringWithFormat:@"%@%@%@", USER_INFO_API, userID, [del apiString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api]];
    request.delegate = self;
    [request setDidFinishSelector:@selector(userInforeRuestFinished:)];
    [request setDidFailSelector:@selector(userInfoRequestFailed:)];
    [request setTimeOutSeconds:10.0f];
//    [request setNumberOfTimesToRetryOnTimeout:3];
    [request startAsynchronous];
    self.lastRequest = request;
    _isLoading = YES;
}

- (void)userInforeRuestFinished:(ASIHTTPRequest*)request {
    _isLoading = NO;
    
    self.lastRequest = nil;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    NSString *jsonString = [request responseString];
    NSDictionary *dic = [jsonString objectFromJSONString];
    if (dic && [dic[@"ok"] boolValue]) {

        NSString *department = [Public formatStringifNull:dic[@"department"]];
        NSString *mobilePhone = [Public formatStringifNull:dic[@"phone"]];
        NSString *emailAddress = [Public formatStringifNull:dic[@"email"]];
        NSString *fixedPhone = [Public formatStringifNull:dic[@"tel"]];
        NSString *name = [Public formatStringifNull:dic[@"name"]];
//        NSString *avatarUrl = [Public formatStringifNull:dic[@"avatar"]];
        IMUser *user = [[IMContext sharedContext] loginUser];
//        user.avatarPath = avatarUrl;
//        user.nickname = name;
        UIImage *image = [Public imageOfUser:user];
        
        [[self.contentArray firstObject] replaceObjectAtIndex:0 withObject:[self cellInfoWithTitle:@"头像" detail:image]];
        [[self.contentArray firstObject] replaceObjectAtIndex:1 withObject:[self cellInfoWithTitle:@"姓名" detail:name]];
        [[self.contentArray firstObject] replaceObjectAtIndex:2 withObject:[self cellInfoWithTitle:self.departmentString detail:department]];
        [[self.contentArray firstObject] replaceObjectAtIndex:3 withObject:[self cellInfoWithTitle:@"手机" detail:mobilePhone]];
        [[self.contentArray firstObject] replaceObjectAtIndex:4 withObject:[self cellInfoWithTitle:@"电话" detail:fixedPhone]];
        [[self.contentArray firstObject] replaceObjectAtIndex:5 withObject:[self cellInfoWithTitle:@"邮箱" detail:emailAddress]];

        [self.tableView reloadData];
        
        _loadSuccess = YES;
        
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
        
        _loadSuccess = NO;
    }
    
}

- (void)userInfoRequestFailed:(ASIHTTPRequest*)request {
    _isLoading = NO;
    _loadSuccess = NO;
    
    self.lastRequest = nil;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"获取信息失败";
    hud.detailsLabelText = @"请检查网络配置是否正确";
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:2.0f];
}


- (void)initContentArray
{
    self.contentArray = [NSMutableArray array];
    NSArray *userInfoArray = [self userInfoArray];
    
    NSArray *documentArray = @[[self cellInfoWithTitle:@"隐私" detail:nil], [self cellInfoWithTitle:@"修改密码" detail:nil]];
    NSArray *clearRecordArray = @[[self cellInfoWithTitle:@"清空聊天记录" detail:nil]];
    
    [self.contentArray addObject:userInfoArray];
    [self.contentArray addObject:documentArray];
    [self.contentArray addObject:clearRecordArray];
}

#pragma mark - Inherited Methods from Superclass

- (UIView *)getTableFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 50.0)];
    footerView.backgroundColor = [UIColor clearColor];
    
	UIButton *signOutButton = [UIHelper redBtnWithTitle:@"注销登录" target:nil action:nil];
    signOutButton.frame = CGRectMake(10.0, 0, 300.0, 40.0);
    
    [signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signOutButton addTarget:self action:@selector(signOut:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:signOutButton];
    
    return [footerView autorelease];;
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return ((NSArray*)self.contentArray[section]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 5.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ccid";
    
    GOSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[GOSettingCell alloc] initWithReuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSDictionary *cellInfo = self.contentArray[indexPath.section][indexPath.row];
    
    cell.title = cellInfo[@"title"];
    cell.detail = cellInfo[@"detail"];
    if (indexPath.row == 2 && del.userInOutFlag == UserInOutFlagIn) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%f", self.view.frame.size.height);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0) {
        
        if (indexPath.row != 2) {
            [self hidePickerViewAnimates:YES];
        }
        
        switch (indexPath.row) {
            case 0:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择",nil];
                actionSheet.tag = ACTION_SHEET_PHOTO_TAG;
                [actionSheet showFromTabBar:self.tabBarController.tabBar];
                actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                
                [actionSheet release];
                break;
            }
            case 1:
            {
                SettingEditingViewController *seVC = [[[SettingEditingViewController alloc]
													   initWithTextFieldHeight:35.0
                                                       text:self.contentArray[indexPath.section][indexPath.row][@"detail"]
													   editingDoneBlock:^(UIViewController *vc, NSString *newText, BOOL changed){
                                                           if (!changed || [self changeUserInfo:INFO_TYPE_NAME value:newText showHudView:vc.view])
                                                           {
                                                               [vc.navigationController popViewControllerAnimated:YES];
                                                           }
                                                       }] autorelease];
                seVC.title = self.contentArray[indexPath.section][indexPath.row][@"title"];
                seVC.limitedEditingLength = 20;
                seVC.showsClearButton = YES;
                seVC.hidesBottomBarWhenPushed = YES;
                seVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
                [self.navigationController pushViewController:seVC animated:YES];

                break;
            }
            case 2:
            {
                
                [self showPickerView];
                break;
            }
            case 3:
            {
                SettingEditingViewController *seVC = [[[SettingEditingViewController alloc]
													   initWithTextFieldHeight:35.0
                                                       text:self.contentArray[indexPath.section][indexPath.row][@"detail"]
													   editingDoneBlock:^(UIViewController *vc, NSString *newText, BOOL changed){
                                                           if (!changed || [self changeUserInfo:INFO_TYPE_MOBILEPHONE value:newText showHudView:vc.view])
                                                           {
                                                               [vc.navigationController popViewControllerAnimated:YES];
                                                           }
                                                       }] autorelease];
                seVC.title = self.contentArray[indexPath.section][indexPath.row][@"title"];
                seVC.limitedEditingLength = 15;
                seVC.showsClearButton = YES;
                seVC.textView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                seVC.hidesBottomBarWhenPushed = YES;
                seVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
                [self.navigationController pushViewController:seVC animated:YES];
                
                break;
            }
            case 4:
            {
                SettingEditingViewController *seVC = [[[SettingEditingViewController alloc]
													   initWithTextFieldHeight:35.0
                                                       text:self.contentArray[indexPath.section][indexPath.row][@"detail"]
													   editingDoneBlock:^(UIViewController *vc, NSString *newText, BOOL changed){
                                                           if (!changed || [self changeUserInfo:INFO_TYPE_FIXPHONE value:newText showHudView:vc.view])
                                                           {
                                                               [vc.navigationController popViewControllerAnimated:YES];
                                                           }
                                                       }] autorelease];
                seVC.title = self.contentArray[indexPath.section][indexPath.row][@"title"];
                seVC.limitedEditingLength = 40;
                seVC.showsClearButton = YES;
                seVC.textView.keyboardType = UIKeyboardTypeEmailAddress;
                seVC.hidesBottomBarWhenPushed = YES;
                seVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
                [self.navigationController pushViewController:seVC animated:YES];
                
                break;
            }
            case 5:
            {
                SettingEditingViewController *seVC = [[[SettingEditingViewController alloc]
													   initWithTextFieldHeight:35.0
                                                       text:self.contentArray[indexPath.section][indexPath.row][@"detail"]
													   editingDoneBlock:^(UIViewController *vc, NSString *newText, BOOL changed){
                                                           if (!changed || [self changeUserInfo:INFO_TYPE_EMAIL value:newText showHudView:vc.view])
                                                           {
                                                               [vc.navigationController popViewControllerAnimated:YES];
                                                           }
                                                       }] autorelease];
                seVC.title = self.contentArray[indexPath.section][indexPath.row][@"title"];
                seVC.limitedEditingLength = 40;
                seVC.showsClearButton = YES;
                seVC.textView.keyboardType = UIKeyboardTypeEmailAddress;
                seVC.hidesBottomBarWhenPushed = YES;
                seVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
                [self.navigationController pushViewController:seVC animated:YES];
                
                break;
            }

                
            default:
                break;
        }
    
	}
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            PrivacyViewController *prv = [[PrivacyViewController alloc]initWithNibName:nil bundle:nil];
            prv.hidesBottomBarWhenPushed = YES;
            prv.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:prv action:@selector(navigationBack:)];
            [self.navigationController pushViewController:prv animated:YES];
            [prv release];
        } else {
            PwdChangeViewController *vc = [[PwdChangeViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:vc action:@selector(navigationBack:)];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];

        }
	}
    else if (indexPath.section == 2) {
				
		RIButtonItem *okBtn = [RIButtonItem itemWithLabel:@"确定"];
		okBtn.action = ^(){
			
			[del.client.msgStorage delAllChatSession];
			[del.client.sessionMgr freshChatSession];

		};
		
		RIButtonItem *cancelBtn = [RIButtonItem itemWithLabel:@"取消"];
		UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"将删除所有个人和群组的聊天记录,及消息界面的聊天记录" cancelButtonItem:cancelBtn otherButtonItems:okBtn, nil];
		
		[alertView show];
		[alertView release];
	}
}

- (BOOL)checkUserInfo:(NSString*)userInfoType value:(NSString*)value showHudView:(UIView*)view {
    
    if ([userInfoType isEqualToString:INFO_TYPE_MOBILEPHONE]) {
        if (value.length != 0 && ![Public isValidateMobilePhone:value]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            hud.labelText = @"手机格式不正确";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:2.0f];
            return NO;
        }
    } else if ([userInfoType isEqualToString:INFO_TYPE_FIXPHONE]) {
        if (value.length != 0 && ![Public isValidateFixedPhone:value]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            hud.labelText = @"座机格式不正确";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:2.0f];
            return NO;
        }
    } else if ([userInfoType isEqualToString:INFO_TYPE_EMAIL]) {
        if (value.length != 0 && ![Public isValidateEmail:value]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            hud.labelText = @"邮箱格式不正确";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:2.0f];
            return NO;
        }
    }
    return YES;

}

- (BOOL)changeUserInfo:(NSString*)userInfoType value:(NSString*)value showHudView:(UIView*)view {

    self.currentInfoType = userInfoType;
    self.currentInfoValue = value;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (![self checkUserInfo:userInfoType value:value showHudView:view]) {
        return NO;
    }
    
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
    
    NSString *api = [[NSString stringWithFormat:@"%@%@%@%@%@", CHANGE_USER_INFO_API, userInfoType, @"=", value, [del apiString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api]];
    request.delegate = self;
    [request setDidFinishSelector:@selector(changeInforeRuestFinished:)];
    [request setDidFailSelector:@selector(changeInfoRequestFailed:)];
    [request setTimeOutSeconds:10.0f];
//    [request setNumberOfTimesToRetryOnTimeout:3];
    [request startAsynchronous];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _isLoading = YES;
    self.lastRequest = request;
    return YES;

}

- (void)changeInforeRuestFinished:(ASIHTTPRequest*)request {
    
    _isLoading = NO;
    
    self.lastRequest = nil;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    NSDictionary *dic = [request.responseString objectFromJSONString];
    if (dic && [dic[@"ok"] boolValue]) {
        
        if ([self.currentInfoType isEqualToString:INFO_TYPE_AVATAR]) {
            XMPPvCardTemp *vCard = [del.client.xmppvCardTempModule myvCardTemp];
            vCard.description = self.currentInfoValue;
            [del.client.xmppvCardTempModule updateMyvCardTemp:vCard];
            IMUser *loginUser = [IMContext sharedContext].loginUser;
            loginUser.avatarPath = self.currentInfoValue;
            
            UIImage *image;
            if (self.currentAvatarData) {
                image = [UIImage imageWithData:self.currentAvatarData];
            } else {
                image = [UIImage imageWithContentsOfFile:self.currentInfoValue];
            }
            [[self.contentArray firstObject] replaceObjectAtIndex:0 withObject:[self cellInfoWithTitle:@"头像" detail:image]];
            
        } else if ([self.currentInfoType isEqualToString:INFO_TYPE_NAME]) {
            XMPPvCardTemp *vCard = [del.client.xmppvCardTempModule myvCardTemp];
            vCard.nickname = self.currentInfoValue;
            [del.client.xmppvCardTempModule updateMyvCardTemp:vCard];
            IMUser *loginUser = [IMContext sharedContext].loginUser;
            loginUser.nickname = self.currentInfoValue;
            [[self.contentArray firstObject] replaceObjectAtIndex:1 withObject:[self cellInfoWithTitle:@"姓名" detail:self.currentInfoValue]];
        } else if ([self.currentInfoType isEqualToString:INFO_TYPE_AREA]) {
            [[self.contentArray firstObject] replaceObjectAtIndex:2 withObject:[self cellInfoWithTitle:self.departmentString detail:self.currentInfoValue]];
        } else if ([self.currentInfoType isEqualToString:INFO_TYPE_MOBILEPHONE]) {
            [[self.contentArray firstObject] replaceObjectAtIndex:3 withObject:[self cellInfoWithTitle:@"手机" detail:self.currentInfoValue]];
        } else if ([self.currentInfoType isEqualToString:INFO_TYPE_FIXPHONE]) {
            [[self.contentArray firstObject] replaceObjectAtIndex:4 withObject:[self cellInfoWithTitle:@"电话" detail:self.currentInfoValue]];
        } else if ([self.currentInfoType isEqualToString:INFO_TYPE_EMAIL]) {
            [[self.contentArray firstObject] replaceObjectAtIndex:5 withObject:[self cellInfoWithTitle:@"邮箱" detail:self.currentInfoValue]];
        }

        
        [self.tableView reloadData];
        

        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"修改成功";
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0f];
//        [self requestForUserInfo];

    } else {
        NSString *errorString = nil;
        if (dic && dic[@"error"]) {
            errorString = dic[@"error"];
        } else {
            errorString = @"请检查网络配置是否正确";
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"修改失败";
        hud.detailsLabelText = errorString;
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0f];
    }
       
    self.currentInfoType = nil;
    self.currentInfoValue = nil;
    self.currentAvatarData = nil;

}

- (void)changeInfoRequestFailed:(ASIHTTPRequest*)request {
    
    _isLoading = NO;
    self.lastRequest = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"修改失败";
    hud.detailsLabelText = @"请检查网络配置是否正确";
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:2.0f];
    
    self.currentInfoType = nil;
    self.currentInfoValue = nil;
    self.currentAvatarData = nil;

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"%d",buttonIndex);
    if(actionSheet.tag == ACTION_SHEET_PHOTO_TAG && buttonIndex != actionSheet.cancelButtonIndex)
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        
        if(buttonIndex == 0)
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if(buttonIndex == 1)
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        [imagePicker release];
        imagePicker = nil;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%@",info);
        
    UIImage *image = info[UIImagePickerControllerEditedImage];
        
    NSData *data = UIImageJPEGRepresentation([image scaleToSize:CGSizeMake(100.0f, 100.0f)], 1.0);

    [self uploadAvatar:data];
  
    [picker dismissModalViewControllerAnimated:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.labelText = @"正在上传";
}



- (void) signOut:(UIButton*)sender {
    
    RIButtonItem *okButton = [RIButtonItem itemWithLabel:@"确定"];
    __block typeof(self) weakSelf = self;
    okButton.action = ^{
        
        if (weakSelf.lastRequest && !weakSelf.lastRequest.isFinished) {
            [weakSelf.lastRequest clearDelegatesAndCancel];
            weakSelf.lastRequest = nil;
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        }
        [del signOut];
        [del clearLoginInfoFromUserDefaults];
        [del gotoLoginViewController];
    };
    RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:@"取消"];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil message:@"确认注销" cancelButtonItem:cancelButton otherButtonItems:okButton, nil];

    [view show];
    [view release];
    
}

- (void)uploadAvatar:(NSData*)data {
	NSURL *requestUrl = [[IMConfiguration sharedInstance].configurator fileUploadURL];
    if (self.lastRequest && !self.lastRequest.isFinished) {
        [self.lastRequest clearDelegatesAndCancel];
        self.lastRequest = nil;
    }
    
    self.currentAvatarData = data;

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestUrl];
	
	[request setPostValue:@"6" forKey:@"type"];
    [request addData:data forKey:@"upfile"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(uploadFinished:)];
	[request setDidFailSelector:@selector(uploadFailed:)];
	[request startAsynchronous];
    self.lastRequest = request;
    _isLoading = YES;
}

- (void)uploadFinished:(ASIFormDataRequest*)request {
    
    _isLoading = NO;
    self.lastRequest = nil;
    NSDictionary *dic = [[request responseString] objectFromJSONString];
    if (dic && [dic[@"ok"] boolValue]) {
        
        NSString *url = [dic objectForKey:@"url"];
        
        [self changeUserInfo:INFO_TYPE_AVATAR value:url showHudView:self.view];
                
    } else {
        self.currentAvatarData = nil;
        NSString *errorString = nil;
        if (dic && dic[@"error"]) {
            errorString = dic[@"error"];
        } else {
            errorString = @"请检查网络配置是否正确";
        }

        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"上传失败";
        hud.detailsLabelText = errorString;
        [hud hide:YES afterDelay:2.0f];
    }

}

- (void)uploadFailed:(ASIFormDataRequest*)request {
    self.currentAvatarData = nil;
    _isLoading = NO;
    self.lastRequest = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"上传失败";
    hud.detailsLabelText = @"请检查网络配置是否正确";
    [hud hide:YES afterDelay:2.0f];
}




@end
