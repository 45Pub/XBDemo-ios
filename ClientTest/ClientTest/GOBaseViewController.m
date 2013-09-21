//
//  GOBaseViewController.m
//  GoComIM
//
//  Created by 王鹏 on 13-4-22.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOBaseViewController.h"

@interface GOBaseViewController ()

@end

@implementation GOBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
	self.view = [[[UIView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];
}

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

- (void)navigationBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
