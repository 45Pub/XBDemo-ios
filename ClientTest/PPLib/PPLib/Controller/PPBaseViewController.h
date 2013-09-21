//
//  PPBaseViewController.h
//  PPLibTest
//
//  Created by Paul Wang on 12-6-14.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPBaseViewController : UIViewController
@property(nonatomic, readonly) BOOL isViewAppearing;
@property(nonatomic, assign) BOOL observeKeyboard;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
@end
