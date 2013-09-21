//
//  PPBaseViewController.m
//  PPLibTest
//
//  Created by Paul Wang on 12-6-14.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PPBaseViewController.h"
#import "PPCoreMisc.h"
@interface PPBaseViewController ()

@end

@implementation PPBaseViewController
@synthesize observeKeyboard = _observeKeyboard;
@synthesize isViewAppearing = _isViewAppearing;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isViewAppearing = NO;
        _observeKeyboard = NO;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _isViewAppearing = NO;
        _observeKeyboard = NO;
    }
    return self;
}

- (void)dealloc 
{    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [nc removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
}

#pragma mark - observe Note
- (void)setObserveKeyboard:(BOOL)observeKeyboard
{
    if (!PPIsBoolEqualToBool(_observeKeyboard, observeKeyboard)) {
        _observeKeyboard = observeKeyboard;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        if (_observeKeyboard) {
            [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
            [nc addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
            [nc addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        } else {
            [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
            [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
            [nc removeObserver:self name:UIKeyboardDidShowNotification object:nil];
            [nc removeObserver:self name:UIKeyboardDidHideNotification object:nil];
        }
    }

}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
}

- (void)keyboardWillHide:(NSNotification *)notification {
}

- (void)keyboardDidShow:(NSNotification *)notification {
}

- (void)keyboardDidHide:(NSNotification *)notification {
}

@end
