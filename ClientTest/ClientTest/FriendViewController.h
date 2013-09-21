//
//  ContactsViewController.h
//  GoComIM
//
//  Created by 王鹏 on 13-4-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOListViewController.h"
//#import "GOSelectedBar.h"
#import "SelectedBar.h"

@protocol FriendViewControllerDelegate;
@interface FriendViewController : GOListViewController

@property (nonatomic, retain, readonly) SelectedBar *selectedBar;
@property (nonatomic, assign) id<FriendViewControllerDelegate> delegate;
@property (nonatomic) BOOL showAdd;
@end

@protocol FriendViewControllerDelegate <NSObject>

// users is a array of IMUser
// you should pop the orgVC in your VC
- (void)friendViewController:(FriendViewController *)contacsVC didFinishSelectionWithUsers:(NSArray *)users;

@end