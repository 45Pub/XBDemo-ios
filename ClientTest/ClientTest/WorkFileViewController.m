//
//  WorkFileViewController.m
//  IMLite
//
//  Created by admins on 13-7-24.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "WorkFileViewController.h"
#import "UIHelper.h"
#import "WorkFileCell.h"
#import "GOUtils.h"
#import <IMPathHelper.h>

#define kSelectedButtonTiltleColor [UIColor colorWithRed:7.0/255 green:141.0/255 blue:212.0/255 alpha:1.0]

@interface WorkFileViewController ()

@property (nonatomic, retain) UIButton *receieveFileBtn;

@property (nonatomic, retain) UIButton *sendFileBtn;

@property (nonatomic, retain) UIButton *totalBtn;

@property (nonatomic, retain) UIImageView *footerView;

@property (nonatomic, retain) UIImageView *selectedFlagView;

@property (nonatomic, retain) NSMutableArray *fileInfoArray;

@property (nonatomic, assign) fileKind filekind;

@end

@implementation WorkFileViewController

- (void)dealloc
{
    [_selectedFilePaths release];
    [_receieveFileBtn release];
    [_sendFileBtn release];
    [_totalBtn release];
    [_footerView release];
    [_selectedFlagView release];
    [_fileInfoArray release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.filekind = fileKindReceieve;
        _contentArray = [[NSMutableArray alloc] init];
        _selectedFilePaths = [[NSMutableArray alloc] init];
        _fileInfoArray = [[NSMutableArray alloc] init];
        
        self.title = @"对话文档";
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 50.0, 44.0);
        [btn setBackgroundImage:[UIImage imageNamed:@"nav_btn_refresh"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
    }
    return self;
}

//- (void)initFileInfoArray
//{
//    NSArray *array = @[@{@"fileName":@"桂圆进",@"time":@"2013-10-20",@"kind":@"rec"},@{@"fileName":@"大中华",@"time":@"2013-10-20",@"kind":@"rec"},@{@"fileName":@"以是脸吗",@"time":@"2013-10-20",@"kind":@"rec"},@{@"fileName":@"小日本子",@"time":@"2013-10-20",@"kind":@"rec"},@{@"fileName":@"sfdlkfsdk",@"time":@"2013-10-20",@"kind":@"send"},@{@"fileName":@"柘城植物",@"time":@"2013-10-20",@"kind":@"send"},@{@"fileName":@"成都夺城",@"time":@"2013-10-20",@"kind":@"send"},@{@"fileName":@"标配dsldkfj破口大骂破口大骂破口大骂大声点",@"time":@"2013-10-20",@"kind":@"send"}];
//    
//    self.fileInfoArray = [NSMutableArray arrayWithArray:array];
//}

- (void)initContentArray
{
    NSString *path = nil;
    if(self.filekind == fileKindMySend)
    {
        path = [IMPathHelper sendFilePath];
    }
    else if(self.filekind == fileKindReceieve)
    {
        path = [IMPathHelper recvFilePath];
    }
    
    [GOUtils enumerateFilesWithPath:path comletionBlock:^(NSArray *array) {
        self.contentArray = [array mutableCopy];
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    [self initFileInfoArray];
    [self initContentArray];

    self.receieveFileBtn = [self getReceieveFileBtn];
    [self.view addSubview:self.receieveFileBtn];
    
    self.sendFileBtn = [self getSendFileBtn];
    [self.view addSubview:self.sendFileBtn];
    
    UIImage *footerViewBg = [[UIImage imageNamed:@"workfile_footbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)];
    _footerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.height - 44.0, self.view.width, 44.0)];
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.footerView.image = footerViewBg;
    [self.view addSubview:self.footerView];
    
    UIImageView *seperator = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 42.0, self.view.width, 1.0)] autorelease];
    seperator.image = footerViewBg;
    [self.view addSubview:seperator];
    
    _selectedFlagView = [[UIImageView alloc] initWithFrame:CGRectMake(40.0, 37.0, 78.0, 6.0)];
    self.selectedFlagView.image = [UIImage imageNamed:@"workfile_sub_selected"];
    [self.view addSubview:self.selectedFlagView];
    
    self.totalBtn = [UIHelper blueBtnWithTitle:@"发送文档" target:self action:@selector(totalBtnClicked:)];
    self.totalBtn.enabled = NO;
    self.totalBtn.frame = CGRectMake(112.0, self.view.height - 37.0, 96.0, 30.0);
    self.totalBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.totalBtn];
    
    self.tableView.frame = CGRectMake(0, 44.0, self.view.width, self.view.height - 44.0- 44.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.editing = YES;
}

- (UIButton *)getReceieveFileBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(40.0, 7.0, 78.0, 30.0);
    btn.tag = 101;
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.backgroundColor = [UIColor clearColor];
    [btn setTitle:@"我收到的" forState:UIControlStateNormal];
    [btn setTitleColor:kSelectedButtonTiltleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(receieveOrSendFileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (UIButton *)getSendFileBtn
{
    UIButton *btn = [UIButton buttonWithFrame:CGRectMake(202.0, 7.0, 78.0, 30.0)];
    btn.tag = 102;
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    btn.backgroundColor = [UIColor whiteColor];
    btn.titleLabel.backgroundColor = [UIColor clearColor];
    [btn setTitle:@"我发出的" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(receieveOrSendFileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)refresh:(id)sender
{
    [self initContentArray];
}

- (void)setTotalButtonTitle
{
    if(self.selectedFilePaths.count == 0)
    {
        self.totalBtn.enabled = NO;
        [self.totalBtn setTitle:@"发送文档" forState:UIControlStateNormal];
    }
    else if(self.selectedFilePaths.count > 0)
    {
        self.totalBtn.enabled = YES;
        NSString *title = [NSString stringWithFormat:@"发送文档(%d)",self.selectedFilePaths.count];
        [self.totalBtn setTitle:title forState:UIControlStateNormal];
    }
}

- (void)totalBtnClicked:(id)sender
{
//    NSLog(@"sfsfsfsfsfsfsdf");
    if(self.selectedFilePaths.count > 0 && [self.delegate respondsToSelector:@selector(workFilesDidSelected:withFiles:)])
    {
        [self.delegate workFilesDidSelected:self withFiles:self.selectedFilePaths];
    }
}

- (void)receieveOrSendFileButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == 101)
    {
        self.selectedFlagView.left = 40.0;
        [self.receieveFileBtn setTitleColor:kSelectedButtonTiltleColor forState:UIControlStateNormal];
        [self.sendFileBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if(self.filekind != fileKindReceieve)
        {
            self.filekind = fileKindReceieve;
            [self initContentArray];
            [self.tableView reloadData];
        }
    }
    else if(btn.tag == 102)
    {
        self.selectedFlagView.left = 202.0;
        [self.receieveFileBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.sendFileBtn setTitleColor:kSelectedButtonTiltleColor forState:UIControlStateNormal];
        
        if(self.filekind != fileKindMySend)
        {
            self.filekind = fileKindMySend;
            [self initContentArray];
            [self.tableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
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
    WorkFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkFileCell"];
    
    if(!cell)
    {
        cell = [[[WorkFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WorkFileCell"] autorelease];
    }
    
    [cell setFileName:[self.contentArray[indexPath.row] objectForKey:@"filename"] time:[self.contentArray[indexPath.row] objectForKey:@"time"]];
    cell.isSelected = [self.selectedFilePaths indexOfObject:self.contentArray[indexPath.row]] != NSNotFound;
    
    __block typeof(self) weakSelf = self;
    cell.accessoryActionBlock = ^(BOOL isSelected)
    {
        if(isSelected)
        {
            [weakSelf.selectedFilePaths addObject:weakSelf.contentArray[indexPath.row]];
        }
        else
        {
            [weakSelf.selectedFilePaths removeObject:weakSelf.contentArray[indexPath.row]];
        }
        
        [weakSelf setTotalButtonTitle];
    };
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end


























