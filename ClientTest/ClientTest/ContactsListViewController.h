//
//  ContactsListViewController.h
//  IMLite
//
//  Created by Ethan on 13-8-21.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOPlainTableViewController.h"
#import "ContactsViewController.h"
#import <IMUser.h>
#import <ASIHTTPRequest.h>


#define NOT_DEPARTMENT @"NOT_DEPARTMENT"


@interface ContactsListViewController : UITableViewController

//- (void)reloadTableViewWithUser:(IMUser*)user;
- (void) getContentInfoWithDepartmentID:(NSString*)departmentID;

- (void)deselectTheSelectedCell;
- (void)selectTheSelectedCell;

- (NSMutableArray*)departmentIDArray;

- (BOOL)isLoading;

@property (nonatomic, retain) NSMutableArray *contentArray;

@property (nonatomic, retain) ContactsViewController *superViewController;

@property (nonatomic, retain) NSString *departmentId;

@property (nonatomic, assign) BOOL shouldStack;

@property (nonatomic, retain) NSMutableArray *searchArray;

@property (nonatomic, retain) NSMutableArray *searchDepartmentArray;

@property (nonatomic, assign) BOOL isSearching;

@property (nonatomic, assign) BOOL isLeft;

@property (nonatomic, assign) BOOL isMultiSelecting;

@property (nonatomic, retain) ASIHTTPRequest *lastRequest;

@property (nonatomic, assign) BOOL avatarShouldBeOverWrite;

@end
