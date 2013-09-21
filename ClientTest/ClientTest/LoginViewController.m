//
//  LoginViewController.m
//  IMLite
//
//  Created by Ethan on 13-7-30.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "LogInViewController.h"
#import "UIButton+PPCategory.h"
#import "PPCore.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UIHelper.h"
#import "Reachability.h"
#import "RegisterViewController.h"

#define INPUTVIEW_BOUNDS CGRectMake(15.0, 1.0, 295.0, 40.0)

@interface LoginViewController()

@property (nonatomic, retain) UIView *hudOverlayView;
@property (nonatomic, retain) NSDictionary *loginInfo;

@end

@implementation LoginViewController

- (void)dealloc {
    [_emailInputView release];
    _emailInputView = nil;
    
    [_passwordInputView release];
    _passwordInputView = nil;
    
    [_loginButton release];
    _loginButton = nil;
    
    [_registerButton release];
    _registerButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSuccessFromLoginVCNote object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginFailedFromLoginVCNote object:nil];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = @"登录/注册";
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    _emailInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"邮箱"];
    _emailInputView.textField.returnKeyType = UIReturnKeyNext;
    _emailInputView.textField.keyboardType = UIKeyboardTypeEmailAddress;
	_emailInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailInputView.textField.delegate = self;
    _emailInputView.backgroundColor = [UIColor clearColor];
    _emailInputView.textField.backgroundColor = [UIColor clearColor];
    [_emailInputView setCornerDirection:UIRectCornerTopLeft | UIRectCornerTopRight];
    
    _passwordInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"密码"];
    _passwordInputView.textField.clearsOnBeginEditing = YES;
	_passwordInputView.textField.secureTextEntry = YES;
    _passwordInputView.textField.delegate = self;
    _passwordInputView.backgroundColor = [UIColor clearColor];
    _passwordInputView.textField.backgroundColor = [UIColor clearColor];
    _passwordInputView.textField.returnKeyType = UIReturnKeyDone;
    [_passwordInputView setCornerDirection:UIRectCornerBottomLeft | UIRectCornerBottomRight];
    
    _hudOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 300.0)];
    self.hudOverlayView.backgroundColor = [UIColor clearColor];
    self.hudOverlayView.hidden = YES;
    
    self.registerButton = [UIHelper blueBtnWithTitle:@"注册新账号" target:self action:@selector(registerTapped:)];
    self.registerButton.frame = CGRectMake(10, 0, 140.0, 40);
    
    self.loginButton = [UIHelper greenBtnWithTitle:@"登录" target:self action:@selector(loginTapped:)];
    self.loginButton.frame = CGRectMake(170, 0, 140.0, 40);
    
	NSDictionary *dic = [del loginInfoFromUserDefaults];
	if (dic && dic[@"account"]) {
		self.emailInputView.textField.text = dic[@"account"];
	}
    
    //TODO for test
    
//    self.emailInputView.textField.text = @"pp4@jianhua.com";
//    self.emailInputView.textField.text = @"test@qq.com";
//    self.passwordInputView.textField.text = @"123456";

    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.hudOverlayView];
    

    self.tableView.scrollEnabled = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.emailInputView.textField becomeFirstResponder];

}

- (void)loginSuccessCallbackNotificationReceived:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSuccessFromLoginVCNote object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginFailedFromLoginVCNote object:nil];

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [del.tabBarController setSelectedIndex:0];
	[del.window setRootViewController:del.tabBarController];
}

- (void)loginFailedCallbackNotificationReceived:(NSNotification *)notification {
    // TDOO: hud error info
//    NSError *err = [notification object];
    
    self.loginInfo = nil;
    self.loginButton.enabled = YES;
    [MBProgressHUD hideAllHUDsForView:self.hudOverlayView animated:NO];
    	
//	if ([err code] == 1234) {
//		[self showHUDTitle:[err localizedDescription] detail:@"请输入正确的账号密码"];
//	}
//	else {
//        [self showHUDTitle:@"链接失败" detail:@"请检查网络是否正常和服务器地址是否正确"];
//    }
    NSString *errorString = notification.object;
    
    if (errorString) {
        [self showHUDTitle:@"登录失败" detail:errorString];
    } else {
        [self showHUDTitle:@"登录失败" detail:@"请检查网络配置是否正确"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSuccessFromLoginVCNote object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginFailedFromLoginVCNote object:nil];

}

- (void)showHUDTitle:(NSString *)title detail:(NSString *)detail {
    
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.yOffset = -80;
	hud.mode = MBProgressHUDModeText;
	hud.labelText = title;
	hud.detailsLabelText = detail;
	[hud hide:YES afterDelay:2.0];
    
}

- (void)loginTapped:(UIButton *)sender {
    
//    [self.userIDInputView.textField resignFirstResponder];
//    [self.passwordInputView.textField resignFirstResponder];
    
    self.hudOverlayView.hidden = NO;
    
    __block typeof(self) weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.hudOverlayView animated:YES];
    hud.frame = CGRectMake(0.0, 100.0, 320.0, 100.0);
    hud.completionBlock = ^{weakSelf.hudOverlayView.hidden = YES;};

    if (self.emailInputView.textField.text.length == 0) {
        
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请填写用户名";
        [hud hide:YES afterDelay:2.0];
        
    } else if ([self.passwordInputView.textField.text length] < 1) {
        
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"密码长度不够";
        [hud hide:YES afterDelay:2.0];

    } else {
        
        Reachability *hostReach = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [hostReach currentReachabilityStatus];
        if (NotReachable == netStatus) {
            hud.labelText = @"无网络连接";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:2.0f];
            return;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessCallbackNotificationReceived:) name:kLoginSuccessFromLoginVCNote object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailedCallbackNotificationReceived:) name:kLoginFailedFromLoginVCNote object:nil];
        
        [del loginWithUserAccount:self.emailInputView.textField.text password:[self.passwordInputView.textField.text md5Hash]];
        
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"登录中";
        self.loginButton.enabled = NO;
        
    }
}

- (void)registerTapped:(UIButton *)sender {
    
    [self.emailInputView.textField resignFirstResponder];
    [self.passwordInputView.textField resignFirstResponder];
    
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    registerVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:self action:@selector(navigationBack:)];
    registerVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:registerVC animated:YES];
    
    [registerVC release];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.emailInputView = nil;
    self.passwordInputView = nil;
//    self.hostInputView = nil;
    self.loginButton = nil;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailInputView.textField) {
        [self.passwordInputView.textField becomeFirstResponder];
    } else if (textField == self.passwordInputView.textField) {
//        [self.hostInputView.textField becomeFirstResponder];
//    } else if (textField == self.hostInputView.textField) {
        [self loginTapped:nil];
    }
    return YES;
}

#pragma mark - UITable Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        [cell addSubview:self.emailInputView];
        
    } else if (indexPath.row == 1) {
        [cell addSubview:self.passwordInputView];
    }
    
    return cell;
    
}

- (UIView *)getTableFooterView {

    
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 40.0)] autorelease];
    [view addSubview:self.registerButton];
    [view addSubview:self.loginButton];
    return view;
}



@end
