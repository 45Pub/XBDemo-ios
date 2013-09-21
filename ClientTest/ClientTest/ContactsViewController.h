//
//  ContactsViewController.h
//  IMLite
//
//  Created by Ethan on 13-8-21.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOBaseViewController.h"
#import "GOSelectedBar.h"
#import <IMUser.h>
#import "StackedLevelViewController.h"


@protocol ContactsViewControllerDelegate;

@interface ContactsViewController : GOBaseViewController<UISearchBarDelegate, UISearchDisplayDelegate, StackedLevelViewControllerDelegate>

@property (nonatomic, assign) id<ContactsViewControllerDelegate> delegate;

@property (nonatomic, retain) UISearchDisplayController *searchController;

@property (nonatomic, retain) GOSelectedBar *selectedBar;

@property (nonatomic, assign) BOOL isMultiSelecting;

@property (nonatomic, retain) NSMutableArray *selectedUsers;

- (void)popViewController;

- (void)pushViewController:(UIViewController*)viewController;

- (void)reloadRightViewControllerWithDepartmentId:(NSString*)departmentId;

@end


@protocol ContactsViewControllerDelegate <NSObject>

// users is a array of IMUser
// you should pop the orgVC in your VC
- (void)ContactsViewController:(ContactsViewController *)contacsVC didFinishSelectionWithUsers:(NSArray *)users;

@end
