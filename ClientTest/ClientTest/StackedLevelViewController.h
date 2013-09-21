//
//  StackedLevelViewController.h
//  IMLite
//
//  Created by Ethan on 13-8-21.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOBaseViewController.h"

@protocol StackedLevelViewControllerDelegate;

@interface StackedLevelViewController : GOBaseViewController

@property (nonatomic, assign) id<StackedLevelViewControllerDelegate> delegate;

- (id)initWithRootViewController:(UIViewController*)viewController withFrame:(CGRect)frame;

- (void)pushStackViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)popViewControllerAnimated:(BOOL)animated;

- (void)popToRootViewController;

- (UIViewController *)rightViewController;
- (UIViewController *)leftViewController;


@end

@protocol StackedLevelViewControllerDelegate <NSObject>

@optional

- (void) stackedLevelViewControllerBeginPush:(StackedLevelViewController*)stackedLevelViewController;

- (void) stackedLevelViewControllerFinishedPush:(StackedLevelViewController*)stackedLevelViewController;

- (void) stackedLevelViewControllerBeginPop:(StackedLevelViewController*)stackedLevelViewController;

- (void) stackedLevelViewControllerFinishedPop:(StackedLevelViewController*)stackedLevelViewController;

@end
