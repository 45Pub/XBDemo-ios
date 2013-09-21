//
//  ViewController.m
//  ClientTest
//
//  Created by pengjay on 13-7-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "LeftButton.h"
#import "TestViewController.h"
#import <IMChatSession.h>
#import <IMMsg.h>
#import <IMUser.h>
#import "AppDelegate.h"
#import "MessageViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		_sessionHandler = [[IMChatSessionHandler alloc]init];
		_sessionHandler.delegate = self;
	}
	return self;
}

- (void)viewDidLoad
{
	LeftButton *btn = [LeftButton buttonWithType:UIButtonTypeCustom];
	UIImage *img = [UIImage imageNamed:@"navbar_btn_left"];
	btn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
	[btn setBackgroundImage:img forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    [super viewDidLoad];
	NSLog(@"%@", btn);
	

	
	_tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.delegate = _sessionHandler;
	_tableView.dataSource = _sessionHandler;
	
	[self.view addSubview:_tableView];
	
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)imClient:(IMBaseClient *)client stateChanged:(IMClientState)state
{
	if (state == IMClientStateConnected) {
		self.title = @"connected";
	}
	else if (state == IMClientStateConnecting) {
		self.title = @"connecting";
	}
	else if (state == IMClientStateDisconnected) {
		self.title = @"disconnected";
	}
		
}

- (void)freshTableView
{
	[_tableView reloadData];
}
- (UITableViewCell *)configureTableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath obj:(id)obj
{
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ddd"];
	if (!cell) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ddd"];
	}

	IMChatSession *se = (IMChatSession *)obj;
	cell.textLabel.text = se.msg.msgBody;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", se.unreadNum];
	return cell;
}

- (void)selectedWithObj:(id)obj
{
	[del.client.sessionMgr readChatSession:obj];
	
	IMChatSession *se = (IMChatSession *)obj;
	
	MessageViewController *mvc = [[MessageViewController alloc]initWithUser:se.fromUser];
	
	[self.navigationController pushViewController:mvc animated:YES];
}

- (void)test
{
//	TestViewController *vvc = [[TestViewController alloc]initWithNibName:nil bundle:nil];
//	
//	[self addChildViewController:vvc];
//	[self.view addSubview:vvc.view];
//	[vvc didMoveToParentViewController:self];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//	for (UIView *view in self.navigationController.navigationBar.subviews) {
//		NSLog(@"%@", view);
//	}
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
