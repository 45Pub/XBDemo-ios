//
//  RegisterViewController.m
//  IMLite
//
//  Created by Ethan on 13-7-31.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "Reachability.h"
#import "IMContext.h"
#import "IMUser.h"
#import <ASIFormDataRequest.h>
#import <JSONKit.h>
#import "Public.h"

@interface RegisterViewController ()

@property (nonatomic, retain) GOInfoInputView *emailInputView;
@property (nonatomic, retain) GOInfoInputView *nickNameInputView;
@property (nonatomic, retain) GOInfoInputView *departmentInputView;
@property (nonatomic, retain) GOInfoInputView *mobilePhoneInputView;
@property (nonatomic, retain) GOInfoInputView *fixedPhoneInputView;
@property (nonatomic, retain) GOInfoInputView *passwordInputView;
@property (nonatomic, retain) GOInfoInputView *rePasswordInputView;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIToolbar *toolBar;

@property (nonatomic, retain) UIButton *registerButton;

@property (nonatomic, retain) NSArray *provineceArray;

@property (nonatomic, assign) int lastSelectedProvineceIndex;

@property (nonatomic, retain) ASIHTTPRequest *lastRequest;

@end

#define INPUTVIEW_BOUNDS CGRectMake(15.0, 1.0, 295.0, 40.0)

@implementation RegisterViewController

- (void)dealloc {
    self.emailInputView = nil;
    self.nickNameInputView = nil;
    self.passwordInputView = nil;
    self.rePasswordInputView = nil;
    self.registerButton = nil;
    self.pickerView = nil;
    self.toolBar = nil;
    self.provineceArray = nil;
    
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
        self.title = @"注册新账号";
    }
    return self;
}

- (void)loadView {
    [super loadView];
        
    self.contentArray = [NSMutableArray array];
    
    _emailInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"邮箱账号"];
    //    _userIDInputView.center = topCenter;
    _emailInputView.textField.returnKeyType = UIReturnKeyNext;
	_emailInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailInputView.textField.delegate = self;
//    _emailInputView.backgroundColor = [UIColor clearColor];
//    _emailInputView.textField.backgroundColor = [UIColor clearColor];
    [_emailInputView setCornerDirection:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self.contentArray addObject:_emailInputView];
    
    _nickNameInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"用户名称"];
    //    _userIDInputView.center = topCenter;
    _nickNameInputView.textField.returnKeyType = UIReturnKeyNext;
	_nickNameInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _nickNameInputView.textField.delegate = self;
//    _nickNameInputView.backgroundColor = [UIColor clearColor];
//    _nickNameInputView.textField.backgroundColor = [UIColor clearColor];
    [self.contentArray addObject:_nickNameInputView];

    _departmentInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"所在地区"];
    //    _userIDInputView.center = topCenter;
    _departmentInputView.textField.returnKeyType = UIReturnKeyNext;
	_departmentInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _departmentInputView.textField.delegate = self;
//    _departmentInputView.backgroundColor = [UIColor clearColor];
//    _departmentInputView.textField.backgroundColor = [UIColor clearColor];
    [self.contentArray addObject:_departmentInputView];

    _mobilePhoneInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"移动电话"];
    //    _userIDInputView.center = topCenter;
    _mobilePhoneInputView.textField.returnKeyType = UIReturnKeyNext;
	_mobilePhoneInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _mobilePhoneInputView.textField.delegate = self;
//    _mobilePhoneInputView.backgroundColor = [UIColor clearColor];
//    _mobilePhoneInputView.textField.backgroundColor = [UIColor clearColor];
    _mobilePhoneInputView.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentArray addObject:_mobilePhoneInputView];

    _fixedPhoneInputView = [[GOInfoInputView alloc] initWithFrame:INPUTVIEW_BOUNDS fieldName:@"固定电话"];
    //    _userIDInputView.center = topCenter;
    _fixedPhoneInputView.textField.returnKeyType = UIReturnKeyNext;
	_fixedPhoneInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _fixedPhoneInputView.textField.delegate = self;
//    _fixedPhoneInputView.backgroundColor = [UIColor clearColor];
//    _fixedPhoneInputView.textField.backgroundColor = [UIColor clearColor];
    _fixedPhoneInputView.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentArray addObject:_fixedPhoneInputView];

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

    self.registerButton = [UIHelper greenBtnWithTitle:@"注册" target:self action:@selector(registerTapped:)];
    self.registerButton.frame = CGRectMake(320/2-140/2, 0, 140.0, 40);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Provineces.plist" ofType:nil];
    self.provineceArray = [NSArray arrayWithContentsOfFile:path];
    
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

}

- (void)pickercancel {
    self.lastSelectedProvineceIndex = 0;
    [self hidePickerView];
}

- (void)pickerDone {
    int row1 = [self.pickerView selectedRowInComponent:1];
    NSString *value = [NSString stringWithFormat:@"%@%@", self.provineceArray[self.lastSelectedProvineceIndex][@"P_Name"], self.provineceArray[self.lastSelectedProvineceIndex][@"Citys"][row1][@"C_Name"]];
    self.departmentInputView.textField.text = value;
    [self hidePickerView];
    self.lastSelectedProvineceIndex = 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    if (pickerView == self.pickerView) {
//        return self.provineceArray.count;
//    } else {
//        return [[[self.provineceArray objectAtIndex:self.selectRow] objectForKey:@"Citys"] count];
//    }
    if (component == 0) {
        return self.provineceArray.count;
    } else {
        return [[[self.provineceArray objectAtIndex:[pickerView selectedRowInComponent:0]] objectForKey:@"Citys"] count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    if (pickerView == self.pickerView) {
//        return [self.provineceArray[row] objectForKey:@"p_Name"];
//    } else {
//        return [[[[self.provineceArray objectAtIndex:self.selectRow] objectForKey:@"Citys"] objectAtIndex:row] objectForKey:@"C_Name"];
//    }

    if (component == 0) {
        return [self.provineceArray[row] objectForKey:@"P_Name"];
    } else {
        NSArray *citys = [[self.provineceArray objectAtIndex:self.lastSelectedProvineceIndex] objectForKey:@"Citys"];
        return [[citys  objectAtIndex:row] objectForKey:@"C_Name"];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    if (pickerView == self.pickerView) {
//        self.selectRow = row;
//    }
    if (component == 0) {
        self.lastSelectedProvineceIndex = row;
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tableView.scrollEnabled = NO;
    
    [self.view addSubview:self.pickerView];
    [self.view addSubview:self.toolBar];
    
    NSString *value = [NSString stringWithFormat:@"%@%@", self.provineceArray[0][@"P_Name"], self.provineceArray[0][@"Citys"][0][@"C_Name"]];
    self.departmentInputView.textField.text = value;
    self.lastSelectedProvineceIndex = 0;
//    [self.view addSubview:self.rightPickerView];
//    UIGestureRecognizer *tapGesture = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponderForInputView:)];
//    [self.view addGestureRecognizer:tapGesture];
//    [tapGesture release];

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

- (void)hidePickerView {
    
    self.lastSelectedProvineceIndex = 0;
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.pickerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-40, weakSelf.view.frame.size.width, 180);
        weakSelf.toolBar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, weakSelf.view.frame.size.width, 40);
    } completion:^(BOOL finished) {
        weakSelf.pickerView.hidden = YES;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.emailInputView.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.emailInputView = nil;
    self.nickNameInputView = nil;
    self.passwordInputView = nil;
    self.rePasswordInputView = nil;
    self.registerButton = nil;
}


- (void)resignFirstResponderForAllInputView {
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.tableView.frame = CGRectMake(0, 0, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
    }];
    [self.emailInputView.textField resignFirstResponder];
    [self.nickNameInputView.textField resignFirstResponder];
    [self.departmentInputView.textField resignFirstResponder];
    [self.mobilePhoneInputView.textField resignFirstResponder];
    [self.fixedPhoneInputView.textField resignFirstResponder];
    [self.passwordInputView.textField resignFirstResponder];
    [self.rePasswordInputView.textField resignFirstResponder];
}

- (BOOL)allInputViewPassCheck {
    if (self.emailInputView.textField.text.length == 0) {

        [self showHudWithTitle:@"请填写邮箱账号" detail:nil];

        return NO;
    } else if (![Public isValidateEmail:self.emailInputView.textField.text]) {
        
        [self showHudWithTitle:@"邮箱账号格式错误" detail:nil];
        
        return NO;
    } else if (self.nickNameInputView.textField.text.length == 0) {
        
        [self showHudWithTitle:@"请填写用户名称" detail:nil];
        
        return NO;
    } else if (self.departmentInputView.textField.text.length == 0) {
        
        [self showHudWithTitle:@"请填写所在地区" detail:nil];
        
        return NO;
    } else if (self.mobilePhoneInputView.textField.text.length != 0
               && ![Public isValidateMobilePhone:self.mobilePhoneInputView.textField.text]) {
        
        [self showHudWithTitle:@"移动电话格式错误" detail:nil];
        
        return NO;
    } else if (self.fixedPhoneInputView.textField.text.length != 0
               && ![Public isValidateFixedPhone:self.fixedPhoneInputView.textField.text]) {
        
        [self showHudWithTitle:@"固定电话格式错误" detail:nil];
        
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
    
    return YES;
}


- (void) registerTapped:(UIButton *)sender {
    
    [self resignFirstResponderForAllInputView];
    
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
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"请稍后";
        
        NSString *userId = [NSString stringWithFormat:@"%@-%@", self.emailInputView.textField.text, [self.emailInputView.textField.text sha1Hash]];
        NSString *pasword = [self.passwordInputView.textField.text md5Hash];
        NSString *name = self.nickNameInputView.textField.text;
        NSString *deparment = self.departmentInputView.textField.text;
        NSString *mobilePhone = self.mobilePhoneInputView.textField.text;
        NSString *fixedPhone = self.fixedPhoneInputView.textField.text;
        NSString *email = self.emailInputView.textField.text;
        del.userAccount = nil;
        
        NSString *api = [[NSString stringWithFormat:@"%@%@", REGISTER_INFO_API, [del apiString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:api]];
        request.delegate = self;
        [request setPostValue:userId forKey:@"user"];
        [request setPostValue:pasword forKey:@"pwd"];
        [request setPostValue:name forKey:@"name"];
        [request setPostValue:deparment forKey:@"department"];
        [request setPostValue:mobilePhone forKey:@"phone"];
        [request setPostValue:fixedPhone forKey:@"tel"];
        [request setPostValue:email forKey:@"email"];
        
        [request setDidFailSelector:@selector(registerInfoFailed:)];
        [request setDidFinishSelector:@selector(registerInfoFinished:)];
        [request setTimeOutSeconds:10.0f];
//        [request setNumberOfTimesToRetryOnTimeout:3];
        [request startAsynchronous];
        
        self.lastRequest = request;

        
//        [del signupWithUserID:[userId stringByAppendingString:SERVER_DOMAIN] password:self.passwordInputView.textField.text host:SERVER_HOST port:SERVER_PORT];
    }
}

- (void)registerInfoFinished:(ASIFormDataRequest*)request {
    
    self.lastRequest = nil;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSDictionary *dic = [request.responseString objectFromJSONString];
    if (dic && [dic[@"ok"] boolValue]) {
        
        del.userAccount = self.emailInputView.textField.text;
        del.userInOutFlag = UserInOutFlagOut;
        
        del.window.rootViewController = del.tabBarController;
        [del refreshLoginInfoFromUserDefaultsWithAccount:self.emailInputView.textField.text password:[self.passwordInputView.textField.text md5Hash] host:SERVER_HOST port:SERVER_PORT];
//        [MBProgressHUD showHUDAddedTo:del.window.rootViewController.view animated:YES];
        NSString *imuser = [Public formatStringifNull:dic[@"imuser"]];
        NSString *impwd = [Public formatStringifNull:dic[@"impwd"]];
        [del loginToIMWithUserId:imuser password:impwd];
    } else {
        
        NSString *errorString = nil;
        if (dic && dic[@"error"]) {
            errorString = dic[@"error"];
        } else {
            errorString = @"请检查网络配置是否正确";
        }
        [self showHudWithTitle:@"注册失败" detail:errorString];
    }
}

- (void)registerInfoFailed:(ASIFormDataRequest*)request {
    
    self.lastRequest = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self showHudWithTitle:@"注册失败" detail:@"请检查网络配置是否正确"];
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
    if (textField == self.emailInputView.textField) {
        [self.nickNameInputView.textField becomeFirstResponder];
    } else if (textField == self.nickNameInputView.textField) {
        [self.departmentInputView.textField becomeFirstResponder];
    } else if (textField == self.departmentInputView.textField) {
        [self.mobilePhoneInputView.textField becomeFirstResponder];
    } else if (textField == self.mobilePhoneInputView.textField) {
        [self.fixedPhoneInputView.textField becomeFirstResponder];
    } else if (textField == self.fixedPhoneInputView.textField) {
        [self.passwordInputView.textField becomeFirstResponder];
    } else if (textField == self.passwordInputView.textField) {
        [self.rePasswordInputView.textField becomeFirstResponder];
    } else if (textField == self.rePasswordInputView.textField) {
        [self registerTapped:nil];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.departmentInputView.textField) {
//        [textField resignFirstResponder];
//        [self showPickerView];
        [self showPickerView];
        [self performSelector:@selector(resignFirstResponderForAllInputView) withObject:nil afterDelay:0.001f];
    }
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    __block typeof(self) weakSelf = self;
    
    if (textField != self.departmentInputView.textField) {
        [self hidePickerView];
    }
    
    
    if (textField == self.mobilePhoneInputView.textField) {
        [UIView animateWithDuration:0.2f animations:^{
            weakSelf.tableView.frame = CGRectMake(0, -50, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
        }];
    } else if (textField == self.fixedPhoneInputView.textField) {
        [UIView animateWithDuration:0.2f animations:^{
            weakSelf.tableView.frame = CGRectMake(0, -100, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
        }];
    } else if (textField == self.passwordInputView.textField) {
        [UIView animateWithDuration:0.2f animations:^{
            weakSelf.tableView.frame = CGRectMake(0, -150, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
        }];
    } else if (textField == self.rePasswordInputView.textField) {
        [UIView animateWithDuration:0.2f animations:^{
            weakSelf.tableView.frame = CGRectMake(0, -190, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.2f animations:^{
            weakSelf.tableView.frame = CGRectMake(0, 0, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
        }];
    }
    return YES;
}

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

- (UIView *)getTableFooterView {
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 40.0)] autorelease];
    [view addSubview:self.registerButton];
    [view addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponderForAllInputView)] autorelease]];
    
    return view;
}


@end
