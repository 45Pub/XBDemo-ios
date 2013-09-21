//
//  IMPicFileViewController.m
//  GoComIM
//
//  Created by 王鹏 on 13-5-24.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMPicFileViewController.h"
#import "IMPicMsg.h"
#import "FilePreviewController.h"
#import "MCProgressBarView.h"
#import "GOUtils.h"
@interface IMPicFileViewController () <IMFileDownloaderDelegate>
@property (nonatomic, retain) MCProgressBarView *progressBarView;
@property (nonatomic, retain) FilePreviewController *prevc;
@property (nonatomic, retain) IMFileDownloader *fileDownloader;
@end

@implementation IMPicFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
	self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"后退" target:self action:@selector(navigationBack:)];	
       
    }
    return self;
}

- (void)dealloc
{
	[_fileDownloader cancelDownload];
	[_fileDownloader release];
	[_picMsg release];
	[_prevc release];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
//	if (self.picMsg.displayName.length <= 0)
//	{
//		self.title = self.picMsg.fileName.length > 0? self.picMsg.fileName:@"";
//	}
//	else
//		self.title = self.picMsg.displayName;
	if (self.picMsg.msgType == IMMsgTypePic)
	{
		self.title = @"图片查看";
	}
	else if (self.picMsg.msgType == IMMsgTypeVideo)
	{
		self.title = @"视频播放";
	}
	else if(self.picMsg.msgType == IMMsgTypeFile)
	{
		self.title = [GOUtils filePreviewTiltleWithPath:self.picMsg.fileLocalPath];
		NSURL *url = [NSURL fileURLWithPath:self.picMsg.fileLocalPath];
		
		FilePreviewController *fvc = [[FilePreviewController alloc]initWithFile:url];
		fvc.hidesBottomBarWhenPushed = YES;
		fvc.view.frame = self.view.bounds;
		[self.view addSubview:fvc.view];
		[self addChildViewController:fvc];
		[fvc didMoveToParentViewController:self];
		self.prevc = [fvc autorelease];
		return;
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.picMsg.originFileLocalPath])
	{
		NSURL *url = [NSURL fileURLWithPath:self.picMsg.originFileLocalPath];

		FilePreviewController *fvc = [[FilePreviewController alloc]initWithFile:url];
		fvc.hidesBottomBarWhenPushed = YES;
		fvc.view.frame = self.view.bounds;
		[self.view addSubview:fvc.view];
		[self addChildViewController:fvc];
		[fvc didMoveToParentViewController:self];
		self.prevc = [fvc autorelease];
	}
	else
	{
		UIImage * backgroundImage = [[UIImage imageNamed:@"loading_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
		UIImage * foregroundImage = [[UIImage imageNamed:@"loading"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
		_progressBarView = [[MCProgressBarView alloc] initWithFrame:CGRectMake(60, (self.view.frame.size.height - 10)/2, 200, 10)
													backgroundImage:backgroundImage
													foregroundImage:foregroundImage];
		[self.view addSubview:_progressBarView];
#warning mo
//		[self.picMsg downloadOriginFile];
//		[self.picMsg addObserver:self forKeyPath:@"originProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
//		isObserve = YES;
//		[self.picMsg addObserver:self forKeyPath:@"originProcState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
		_fileDownloader = [[IMFileDownloader alloc]init];
		_fileDownloader.delegate = self;
		[_fileDownloader downloadWithFileURLstr:self.picMsg.originFileRemoteUrl savePath:self.picMsg.originFileLocalPath];
	}
	// Do any additional setup after loading the view.
}



- (void)imFileDownloaderDidStarted:(IMFileDownloader *)downloader
{

}
- (void)imFileDownloaderDidFinished:(IMFileDownloader *)downloader
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.picMsg.originFileLocalPath])
	{
		self.progressBarView.hidden = YES;
		NSURL *url = [NSURL fileURLWithPath:self.picMsg.originFileLocalPath];
		FilePreviewController *fvc = [[FilePreviewController alloc]initWithFile:url];
		fvc.hidesBottomBarWhenPushed = YES;
		fvc.view.frame = self.view.bounds;
		[self.view addSubview:fvc.view];
		[self addChildViewController:fvc];
		[fvc didMoveToParentViewController:self];
		self.prevc = [fvc autorelease];
	}

}

- (void)imFileDownloaderDidFailed:(IMFileDownloader *)downloader
{

}

- (void)imFileDownloader:(IMFileDownloader *)downloader procProgress:(CGFloat)progress
{
	dispatch_async(dispatch_get_main_queue(), ^{
		self.progressBarView.progress = progress;
	});
}
/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"originProcState"])
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.picMsg.originProcState == IMMsgProcStateSuc)
			{
				if ([[NSFileManager defaultManager] fileExistsAtPath:self.picMsg.originPicLocalPath])
				{
				self.progressBarView.hidden = YES;
				NSURL *url = [NSURL fileURLWithPath:self.picMsg.originPicLocalPath];
				FilePreviewController *fvc = [[FilePreviewController alloc]initWithFile:url];
				fvc.hidesBottomBarWhenPushed = YES;
				fvc.view.frame = self.view.bounds;
				[self.view addSubview:fvc.view];
				[self addChildViewController:fvc];
					[fvc didMoveToParentViewController:self];
				self.prevc = [fvc autorelease];
				}
//				[self reloadData];
			}
		});
//		NSLog(@"%f", self.picMsg.originProgress);
	}
	else if ([keyPath isEqualToString:@"originProgress"])
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			self.progressBarView.progress = self.picMsg.originProgress;
		});
	}
}*/


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
