//
//  GOPlainTableViewController.m
//  GoComIM
//
//  Created by 王鹏 on 13-4-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOPlainTableViewController.h"

@interface GOPlainTableViewController ()

@end

@implementation GOPlainTableViewController
@synthesize contentArray = _contentArray;

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
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
	[_tableView release];
	[_contentArray release];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView = [[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableFooterView = [self getTableFooterView];
	self.tableView.tableHeaderView = [self getTableHeaderView];
	[self.view addSubview:self.tableView];
	// Do any additional setup after loading the view.
}

- (UIView *)getTableHeaderView
{
	return nil;
}

- (UIView *)getTableFooterView
{
	
	return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"infoCell"] autorelease];
	}
	cell.textLabel.text = [[self.contentArray objectAtIndex:indexPath.row] description];
	return cell;
}


@end
