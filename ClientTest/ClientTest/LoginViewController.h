//
//  LoginViewController.h
//  IMLite
//
//  Created by Ethan on 13-7-30.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOBaseViewController.h"
#import "GOInfoInputView.h"
#import "GoGroupedTableViewController.h"

@interface LoginViewController : GoGroupedTableViewController<UITextFieldDelegate>

@property (nonatomic, retain) GOInfoInputView *emailInputView;
@property (nonatomic, retain) GOInfoInputView *passwordInputView;
//@property (nonatomic, retain) GOInfoInputView *hostInputView;

@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIButton *registerButton;

@end
