//
//  TestViewController.m
//  ClientTest
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"dfadfadf" style:UIBarButtonItemStyleBordered target:self action:@selector(test)];
    }
    return self;
}

- (void)viewDidLoad
{
	self.view.backgroundColor = [UIColor redColor];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
