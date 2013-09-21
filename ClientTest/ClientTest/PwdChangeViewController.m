//
//  PwdChangeViewController.m
//  IMLite
//
//  Created by Ethan on 13-9-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PwdChangeViewController.h"

#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "Reachability.h"
#import "IMContext.h"
#import "IMUser.h"
#import <ASIFormDataRequest.h>
#import <JSONKit.h>
#import "Public.h"

@interface PwdChangeViewController ()

@property (nonatomic, retain) GOInfoInputView *oldPasswordInputView;
@property (nonatomic, retain) GOInfoInputView *passwordInputView;
@property (nonatomic, retain) GOInfoInputView *rePasswordInputView;

@property (nonatomic, retain) ASIHTTPRequest *lastRequest;

@end

#define INPUTVIEW_BOUNDS CGRectMake(15.0, 1.0, 295.0, 40.0)

@implementation PwdChangeViewController

- (void)dealloc {
    self.oldPasswordInputView = nil;
    self.passwordInputView = nil;
    self.rePasswordInputView = nil;
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
        self.title = @"修改密码";
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.contentArray = [NSMutableArray array];
    
    _oldPasswordInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"旧密码"];
    //    _userIDInputView.center = topCenter;
    _oldPasswordInputView.textField.returnKeyType = UIReturnKeyNext;
	_oldPasswordInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _oldPasswordInputView.textField.clearsOnBeginEditing = YES;
	_oldPasswordInputView.textField.secureTextEntry = YES;
    _oldPasswordInputView.textField.delegate = self;
    //    _oldPasswordInputView.backgroundColor = [UIColor clearColor];
    //    _oldPasswordInputView.textField.backgroundColor = [UIColor clearColor];
    [_oldPasswordInputView setCornerDirection:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self.contentArray addObject:_oldPasswordInputView];
    
    _passwordInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"设置密码"];
    //    _userIDInputView.center = topCenter;
    _passwordInputView.textField.returnKeyType = UIReturnKeyNext;
    _passwordInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_passwordInputView.textField.clearsOnBeginEditing = YES;
	_passwordInputView.textField.secureTextEntry = YES;
    _passwordInputView.textField.delegate = self;
    //    _passwordInputView.backgroundColor = [UIColor clearColor];
    //    _passwordInputView.textField.backgroundColor = [UIColor clearColor];
    //    _passwordInputView.textField.backgroundColor = [UIColor clearColor];
    [self.contentArray addObject:_passwordInputView];
    
    _rePasswordInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"确认密码"];
	_rePasswordInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _rePasswordInputView.textField.clearsOnBeginEditing = YES;
	_rePasswordInputView.textField.secureTextEntry = YES;
    _rePasswordInputView.textField.delegate = self;
    //    _rePasswordInputView.backgroundColor = [UIColor clearColor];
    //    _rePasswordInputView.textField.backgroundColor = [UIColor clearColor];
    _rePasswordInputView.textField.returnKeyType = UIReturnKeyDone;
    [_rePasswordInputView setCornerDirection:UIRectCornerBottomLeft | UIRectCornerBottomRight];
    [self.contentArray addObject:_rePasswordInputView];
    
 }


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    //
    //    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tableView.scrollEnabled = NO;
        
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.oldPasswordInputView.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.oldPasswordInputView = nil;
    self.passwordInputView = nil;
    self.rePasswordInputView = nil;
}


- (void)resignFirstResponderForAllInputView {
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.tableView.frame = CGRectMake(0, 0, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
    }];
    [self.oldPasswordInputView.textField resignFirstResponder];
    [self.passwordInputView.textField resignFirstResponder];
    [self.rePasswordInputView.textField resignFirstResponder];
}

- (BOOL)allInputViewPassCheck {
    if (self.oldPasswordInputView.textField.text.length == 0) {
        
        [self showHudWithTitle:@"请输入旧密码" detail:nil];
        
        return NO;
    } else if (self.passwordInputView.textField.text.length == 0) {
        
        [self showHudWithTitle:@"请填写用户密码" detail:nil];
        
        return NO;
    } else if (self.rePasswordInputView.textField.text.length == 0) {
        
        [self showHudWithTitle:@"请确认用户密码" detail:nil];
        
        return NO;
    } else if (![self.rePasswordInputView.textField.text isEqualToString:self.passwordInputView.textField.text]) {
        
        [self showHudWithTitle:@"两次密码输入不同" detail:nil];
        
        return NO;
    }
//    else if (![self.oldPasswordInputView.textField.text.md5Hash isEqualToString:[[del loginInfoFromUserDefaults] objectForKey:@"password"]]) {
//        [self showHudWithTitle:@"旧密码输入错误" detail:nil];
//        return NO;
//    }
    
    return YES;
}


- (void) changePasswordTapped:(UIButton *)sender {
    
    [self resignFirstResponderForAllInputView];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];

    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    if (NotReachable == netStatus) {
        [self showHudWithTitle:@"无网络连接" detail:nil];
        return;
    }
    
    if ([self allInputViewPassCheck]) {
        
        if (self.lastRequest && !self.lastRequest.isFinished) {
            [self.lastRequest clearDelegatesAndCancel];
            self.lastRequest = nil;
        }

        NSString *api = [[NSString stringWithFormat:@"%@%@%@%@%@%@%@", CHANGE_USER_INFO_API, @"newpwd", @"=", self.passwordInputView.textField.text.md5Hash, @"&oldpwd=", self.oldPasswordInputView.textField.text.md5Hash, [del apiString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api]];
        request.delegate = self;
        [request setDidFinishSelector:@selector(changeInforeRuestFinished:)];
        [request setDidFailSelector:@selector(changeInfoRequestFailed:)];
        [request setTimeOutSeconds:10.0f];
        [request startAsynchronous];
        self.lastRequest = request;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    }
}

- (void)changeInforeRuestFinished:(ASIHTTPRequest*)request {
    
    self.lastRequest = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    NSDictionary *dic = [request.responseString objectFromJSONString];
    if (dic && [dic[@"ok"] boolValue]) {
        
        NSDictionary *userInfo = [del loginInfoFromUserDefaults];
        [del refreshLoginInfoFromUserDefaultsWithAccount:userInfo[@"account"] password:self.passwordInputView.textField.text.md5Hash host:userInfo[@"host"] port:[userInfo[@"port"] intValue]];
        
        __block typeof(self) weakSelf = self;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"修改成功";
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0f];
        hud.completionBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };

        
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
    
}

- (void)changeInfoRequestFailed:(ASIHTTPRequest*)request {
    
    self.lastRequest = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"修改失败";
    hud.detailsLabelText = @"请检查网络配置是否正确";
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:2.0f];

}


- (void)showHudWithTitle:(NSString*)title detail:(NSString*)detail {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.detailsLabelText = detail;
    [hud hide:YES afterDelay:2.0];
}


#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.oldPasswordInputView.textField) {
        [self.passwordInputView.textField becomeFirstResponder];
    } else if (textField == self.passwordInputView.textField) {
        [self.rePasswordInputView.textField becomeFirstResponder];
    } else if (textField == self.rePasswordInputView.textField) {
        [self changePasswordTapped:nil];
    }
    return YES;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    
//    __block typeof(self) weakSelf = self;
//    
//    if (textField != self.departmentInputView.textField) {
//        [self hidePickerView];
//    }
//    
//    
//    if (textField == self.mobilePhoneInputView.textField) {
//        [UIView animateWithDuration:0.2f animations:^{
//            weakSelf.tableView.frame = CGRectMake(0, -50, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
//        }];
//    } else if (textField == self.fixedPhoneInputView.textField) {
//        [UIView animateWithDuration:0.2f animations:^{
//            weakSelf.tableView.frame = CGRectMake(0, -100, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
//        }];
//    } else if (textField == self.passwordInputView.textField) {
//        [UIView animateWithDuration:0.2f animations:^{
//            weakSelf.tableView.frame = CGRectMake(0, -150, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
//        }];
//    } else if (textField == self.rePasswordInputView.textField) {
//        [UIView animateWithDuration:0.2f animations:^{
//            weakSelf.tableView.frame = CGRectMake(0, -190, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
//        }];
//    } else {
//        [UIView animateWithDuration:0.2f animations:^{
//            weakSelf.tableView.frame = CGRectMake(0, 0, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
//        }];
//    }
//    return YES;
//}

#pragma mark - UITable Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArray.count;
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
    
    [cell addSubview:self.contentArray[indexPath.row]];
    
    return cell;
    
}

//- (UIView *)getTableFooterView {
//    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 40.0)] autorelease];
//    [view addSubview:self.registerButton];
//    [view addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponderForAllInputView)] autorelease]];
//    
//    return view;
//}

@end
