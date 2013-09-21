//
//  GOPlainTableViewController.h
//  GoComIM
//
//  Created by 王鹏 on 13-4-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOBaseViewController.h"

@interface GOPlainTableViewController : GOBaseViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_contentArray;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *contentArray;
- (UIView *)getTableHeaderView;
- (UIView *)getTableFooterView;
@end
