//
//  GoDiscChatSetViewController.m
//  GoComIM
//
//  Created by 王鹏 on 13-5-14.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GoDiscChatSetViewController.h"
#import "GoMemebersViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "GOUtils.h"
#import "NSArray+PPCategory.h"
#import "SettingEditingViewController.h"
#import <IMUser.h>
#import <IMContext.h>

@interface GoDiscChatSetViewController ()

@end

@implementation GoDiscChatSetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[self.fromUser removeObserver:self forKeyPath:@"changeFlag"];
    self.pVC = nil;
	[super dealloc];
}

- (void)initContentArray
{
	BOOL isAdim = [del.client.xbRosterStorage memberIsAdmin:[IMContext sharedContext].loginUser.userID withDgid:self.fromUser.userID];
	self.contentArray = [NSMutableArray array];
    if (isAdim) {
        [self.contentArray addObject:@[@{@"title": @"查看讨论组成员"}, @{@"title": @"修改讨论组名称"}]];
    } else {
        [self.contentArray addObject:@[@{@"title": @"查看讨论组成员"}]];
    }
	[self.contentArray addObject:@[@{@"title": @"从组织里添加成员", @"image":[UIImage imageNamed:@"tableview_icon_add.png"]},
	 @{@"title": @"从通讯录里添加成员", @"image":[UIImage imageNamed:@"tableview_icon_add.png"]}]];
	
}

- (void)setFromUser:(IMUser *)fromUser
{
	[super setFromUser:fromUser];
	[self.fromUser addObserver:self forKeyPath:@"changeFlag" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"changeFlag"])
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)getTableFooterView
{
	UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 110)];

	UIButton *redBtn = [UIHelper redBtnWithTitle:@"删除并退出" target:self action:@selector(delDicussion:)];
	redBtn.frame = CGRectMake(10, 0, 300, 40);
	[footerView addSubview:redBtn];
	
	return [footerView autorelease];
	
}


- (void)delDicussion:(id)sender
{
	[self exitGroup];
}

#pragma mark - UITableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"] autorelease];
	}
	
	NSArray *array = [self.contentArray objectOrNilAtIndex:indexPath.section];
	
	NSDictionary *dic = [array objectOrNilAtIndex:indexPath.row];
	
	cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
	cell.textLabel.text = [dic objectForKey:@"title"];
	cell.imageView.image = [dic objectForKey:@"image"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.detailTextLabel.text = nil;
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            GoMemebersViewController *memvc = [[GoMemebersViewController alloc]initWithIMUser:self.fromUser];
            memvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:memvc animated:YES];
            [memvc release];
        } else {
            __block typeof(self) weakSelf = self;
            SettingEditingViewController *seVC = [[[SettingEditingViewController alloc]
                                                   initWithTextFieldHeight:35.0
                                                   text:self.fromUser.nickname
                                                   editingDoneBlock:^(UIViewController *vc, NSString *newText, BOOL changed){
                                                       if (changed)
                                                       {
                                                           
                                                           [del.client.xbRoster changeDiscussGroup:weakSelf.fromUser.userID withNewName:newText];
                                                           weakSelf.pVC.title = newText;
                                                           
                                                       }
                                                       
                                                       [vc.navigationController popViewControllerAnimated:YES];
                                                       
                                                   }] autorelease];
            seVC.title = self.contentArray[indexPath.section][indexPath.row][@"title"];
            seVC.limitedEditingLength = 20;
            seVC.showsClearButton = YES;
            seVC.hidesBottomBarWhenPushed = YES;
            seVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
            [self.navigationController pushViewController:seVC animated:YES];
        }
	}
	else if (indexPath.section == 1)
	{
		if (indexPath.row == 0)
		{
			[self push2Contacts];
		}
		else
			[self push2orgVc];

	}
}

@end
