//
//  IMBaseChatViewController.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMBaseChatViewController.h"
#import "AppDelegate.h"
#import "UIImage+PPCategory.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "IMMsgQueueManager.h"
#import "FilePreviewController.h"
#import "IMPicFileViewController.h"
//#import "IMChatRecordViewController.h"
#import "UIActionSheet+Blocks.h"
#import <QuartzCore/QuartzCore.h>
#import "NSArray+PPCategory.h"
#import "IMVideoTool.h"
#import <IMContext.h>
#import "WorkFileViewController.h"


static NSString *xmppStateContext = @"xmppStateContext";

@interface IMBaseChatViewController () <IMMsgQueueDelegate, WorkFileViewDelegate>
@property (nonatomic, retain) UIImagePickerController *imgPicker;
@property (nonatomic) BOOL isLoadingHistory;
@property (nonatomic, retain) IMAudioMsg *recordAudioMsg;
//@property (nonatomic, retain) FilesViewController *fileController;
@property (nonatomic, retain) UIImageView *audioRouterView;
@property (nonatomic, retain) UILabel *titleLabel;
@end

@implementation IMBaseChatViewController

- (id)initWithFromUser:(IMUser *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMsg:) name:kIMMsgQueueChanged object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgDownloaded:) name:@"filedownloaderSuc" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oldMsgLoaded:) name:kIMMsgOldMsgLoaded object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouterChanged:) name:kIMAudioRouterChangedNote object:nil];
		self.fromUser = user;
		self.msgQueue = [[IMContext sharedContext].msgQueueMgr openNormalMsgQueueWithUser:self.fromUser delegate:self];
		self.recorder = [[[PPAmrRecorder alloc]init] autorelease];
		self.recorder.delegate = self;
		self.recorder.showMeter = YES;
		self.recorder.limitRecordFrames = 50*60;
		self.myUser = [IMContext sharedContext].loginUser;
		self.hidesBottomBarWhenPushed = YES;
		self.autoScroll = YES;
//		[del.imAgent addObserver:self forKeyPath:@"netState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:(void*)&xmppStateContext];
		[del.client.delegates addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)dealloc
{
//	[del.imAgent removeObserver:self forKeyPath:@"netState" context:(void *)&xmppStateContext];
	[del.client.delegates removeDelegate:self];
	[[IMContext sharedContext].msgQueueMgr closeNormalMsgQueueWithUser:self.fromUser];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
//	self.fileController.delegate = nil;
//	[_fileController release];
	[_tableView release];
	_tableView = nil;
	[_msgArray release];
	_msgArray = nil;
//	[_fromUser removeObserver:self forKeyPath:@"changeFlag"];
	[_fromUser release];
	_fromUser = nil;
	[_msgQueue release];
	_msgQueue = nil;
	[_inputBar release];
	_inputBar = nil;
	[_kbfaceView release];
	[_kbmenuView release];
	[_recorder stop];
	_recorder.delegate = nil;
	[_recorder release];
	[_myUser release];
	[_imgPicker release];
	_imgPicker = nil;
	[_talkMaskView release];
	_talkMaskView = nil;
	[_actView release];
	_actView = nil;
	[_netHud release];
	_netHud = nil;
	[_recordAudioMsg release];
	_recordAudioMsg = nil;
	[_audioRouterView release];
	[_titleLabel release];
	[super dealloc];
}

- (void)loadView
{
	[super loadView];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin;
	self.view.backgroundColor = [UIColor whiteColor];
//	NSString *bgPath = [[IMSession globalIMSession].loginUser.imConf objectForKey:@"chatBg"];
//	if (bgPath)
//	{
//		UIImage *img = [[UIImage alloc ]initWithContentsOfFile:bgPath];
//		PPLOG(@"%@:%f", NSStringFromCGSize(img.size), img.scale);
//		
//		UIImageView *bgView = [[UIImageView alloc]initWithImage:img];
//		[self.view addSubview:bgView];
//		[bgView release];
//		[img release];
//	}
	
	
	self.actView = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.actView.frame = CGRectMake(0, 0, 19, 19);
    self.actView.center = CGPointMake(160, -15);
	
	self.tableView = [[[IMTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 44) style:UITableViewStylePlain] autorelease];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:self.tableView];
	
	[self.tableView addSubview:self.actView];
	
	_inputBar = [[IMInputBar alloc]initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    _inputBar.delegate = self;
	_inputBar.limitWordsNum = 500;
    [self.view addSubview:_inputBar];
	
	_kbmenuView = [[MenuView alloc]initWithFrame:CGRectMake(0, self.view.height, self.view.width, 100)];
	_kbmenuView.delegate = self;
	_kbfaceView = [[IMFaceView alloc]initWithFrame:CGRectMake(0, self.view.height, self.view.width, 190)];
	_kbfaceView.backgroundColor = [UIColor grayColor];
	_kbfaceView.delegate = self;
	
	[self.view addSubview:_kbmenuView];
	[self.view addSubview:_kbfaceView];
	
//	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
//	tapGesture.delegate = self;
//	tapGesture.cancelsTouchesInView = YES;
//	[self.tableView addGestureRecognizer:tapGesture];
//	[tapGesture release];
	
	_talkMaskView = [[TalkView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 44)];
    _talkMaskView.userInteractionEnabled = YES;
    _talkMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
//    _talkMaskView.image = [UIImage imageNamed:@"startTalk.png"];
    _talkMaskView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_talkMaskView];
    _talkMaskView.hidden = YES;
	
	
	self.netHud = [[[IMNetHud alloc]initWithFrame:CGRectMake(20, 10, 280, 50)] autorelease];
    self.netHud.textLabel.text = @"网络不可用，与服务器中断";
    self.netHud.detailLabel.text = @"正在尝试重新连接...";
    [self.view addSubview:_netHud];
    self.netHud.hidden = YES;
	
	self.titleLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)] autorelease];
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
	self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.shadowOffset = CGSizeMake(0, -1);
	
	
	self.navigationItem.titleView = [[[UIView alloc]initWithFrame:CGRectMake(-500, 0, 320, 44)] autorelease];
	self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
	[self.navigationItem.titleView addSubview:self.titleLabel];
	self.titleLabel.text = self.title;
	
	self.audioRouterView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 17, 17)];
	[self.navigationItem.titleView addSubview:self.audioRouterView];
	self.audioRouterView.left = 182;
	self.audioRouterView.top = 14;

}

- (void)viewDidUnload
{
	self.tableView = nil;
	self.inputBar = nil;
	self.kbfaceView = nil;
	self.talkMaskView = nil;
	self.netHud = nil;

	[super viewDidUnload];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//for ios5 bug
	if (PPIOSVersion() < 5.5)
	{
		
	
	if (_parentController)
	{
//		self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
		[del.tabBarController setSelectedIndex:3];
		[del.tabBarController setSelectedIndex:0];
		_parentController = nil;
	}
	}
	
	self.title = self.fromUser.nickname;
	
	self.msgArray = self.msgQueue.msgArray;
	[self.tableView reloadData];
	// Do any additional setup after loading the view.
	
	[self changeAudioRouterImage];
}

- (void)navigationBack:(id)sender
{
//	[[IMMsgQueueManager sharedQueueManager] closeActiveMsgQueueWithUser:self.fromUser];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(self.autoScroll == YES)
	{
		if(self.tableView.contentSize.height > self.tableView.frame.size.height)
		{
			[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height) animated:NO];
		}
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if([touch.view isKindOfClass:[UIButton class]] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
	{
		return NO;
	}
	return YES;
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
	[_inputBar closeInputBar];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[_inputBar closeInputBar];
}


- (void)setTitle:(NSString *)title
{
	[super setTitle:title];
	if ([self isViewLoaded]) {
		self.titleLabel.text = title;
	}
}

- (void)setFromUser:(IMUser *)fromUser
{
	if (_fromUser != fromUser) {
		if (_fromUser) {
			[_fromUser removeObserver:self forKeyPath:@"changeFlag"];
			[_fromUser release];
			_fromUser = nil;
		}
		
		_fromUser = [fromUser retain];
		[_fromUser addObserver:self forKeyPath:@"changeFlag" options:NSKeyValueObservingOptionNew context:nil];
	}
}
#pragma mark - ImmsgQueueDelegate
- (void)immsgQueue:(IMMsgQueue *)msgQueue didChanged:(NSArray *)msgArray
{
	self.msgArray = [msgQueue msgArray];
	[self.tableView reloadData];
	if (self.autoScroll)
		[self.tableView scrollToBottom:NO];
}

- (void)immsgQueue:(IMMsgQueue *)msgQueue didLoadHistory:(NSArray *)hisstroyArray
{
	
	[self actviewStopAnimation];
	
	self.msgArray = self.msgQueue.msgArray;
	NSArray *msgArray = hisstroyArray;
	if(!self.msgQueue.hasMoreHistroy)
	{
		[self hidenActViewInTable];
	}
	
	if([msgArray count] == 0)
		return;
	
	[self.tableView reloadData];
	
	NSMutableArray *array = [NSMutableArray array];
    int cnt = [msgArray count];
    for(int i = 0 ; i< cnt; i++)
    {
        [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
	CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[array count] inSection:0]];
	[self.tableView setContentOffset:CGPointMake(0, rect.origin.y-32)];
}

- (void)immsgQueue:(IMMsgQueue *)msgQueue didRemoveIndexes:(NSArray *)indexes
{
	self.msgArray = msgQueue.msgArray;
	[self.tableView beginUpdates];
	[self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}
#pragma mark Observer
- (void)userInfoChanged
{
		self.title = self.fromUser.nickname;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"changeFlag"])
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self userInfoChanged];
		});
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - AudioRouteChangedNote

- (void)changeAudioRouterImage
{
//	UIImage *img = [UIImage imageNamed:@"voice_mode_earphone"];
//	if ([[[IMSession globalIMSession].loginUser.imConf objectForKey:@"audioRouteSpeaker"] boolValue])
//		img = [UIImage imageNamed:@"voice_mode_loudspeaker"];
//	
//	self.audioRouterView.image = img;
}

- (void)audioRouterChanged:(NSNotification *)note
{
//	[self changeAudioRouterImage];
}

#pragma mark NetHud
#pragma mark - Animation
- (CAAnimation *)hudAnimation
{
    CABasicAnimation *bda = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	
    bda.toValue = [NSNumber numberWithFloat:1.075];
    
	
	bda.duration = 0.3f;
	bda.autoreverses = YES;
	bda.repeatCount = 4;
	bda.removedOnCompletion = YES;
    //	bda.fillMode = kCAFillModeRemoved;
    bda.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    bda.removedOnCompletion = YES;
    return bda;
}

- (void)playNotNetworkAnimation
{
    if(self.netHud.hidden == NO)
    {
        [self.netHud.layer removeAnimationForKey:@"hudani"];
        [self.netHud.layer addAnimation:[self hudAnimation] forKey:@"hudani"];
    }
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.msgArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	id msg = [self.msgArray objectOrNilAtIndex:indexPath.row];
	cell = [IMMsgCellUtil tableView:tableView cellForMsg:msg];
	if([cell isKindOfClass:[IMMsgCell class]])
	{
		IMMsgCell *a = (IMMsgCell *)cell;
		a.delegate = self;
		a.indexPath = indexPath;
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id msg = [self.msgArray objectOrNilAtIndex:indexPath.row];
	return [IMMsgCellUtil cellHeightForMsg:msg];
}

#pragma mark newMsg

- (void)newMsg:(NSNotification *)note
{
	IMUser *tmpUser = (IMUser *)note.object;
	if(![self.fromUser isEqual:tmpUser])
	{
		return;
	}
	
	[self.tableView reloadData];
	[self.tableView scrollToLastRow:YES];
}

- (void)msgDownloaded:(NSNotification *)note
{
	if ([self.msgArray containsObject:note.object])
	{
		[self.tableView reloadData];
	}
}
#pragma mark InPut
- (BOOL)xmppNetCheckOK:(BOOL)animatied
{
//	if(del.imAgent.netState != GoComNetStateConnected)
//	{
//		if(animatied)
//			[self playNotNetworkAnimation];
//		return NO;
//	}
	return YES;
}

- (void)iminputBarBeginRecord
{
	PPLOG(@"begin record");
	if(![self xmppNetCheckOK:YES])
		return;
	[self showBeginTalkMask];
	[IMContext sharedContext].msgQueueMgr.isQueueRecording = YES;

	
	self.recordAudioMsg = [[[IMAudioMsg alloc]init] autorelease];
	self.recordAudioMsg.msgID = [IMMsg generateMessageID];
	self.recordAudioMsg.fromUser = self.fromUser;
	self.recordAudioMsg.msgUser = self.myUser;
	self.recordAudioMsg.fromType = IMMsgFromLocalSelf;
	[self.recorder startRecodeWithPath:self.recordAudioMsg.fileLocalPath];
}

- (void)iminputEndRecord
{
	PPLOG(@"end record");
	[self.recorder stopRecordImd:NO];
}

- (BOOL)iminputBarSendText:(NSString *)message
{
	PPLOG(@"send:%@", message);
	if(![self xmppNetCheckOK:YES])
		return NO;
	
//	if(![Public checkParseableString:message])
//    {
//        [Public showTextTintDelayHide:@"不支持自带表情"];
//        return NO;
//    }

	
	IMMsg *msg = [[IMMsg alloc]init];
	msg.fromUser = self.fromUser;
	msg.msgUser = self.myUser;
	msg.msgBody = message;
	msg.msgID = [IMMsg generateMessageID];
	msg.fromType = IMMsgFromLocalSelf;
	msg.readState = IMMsgReadStateReaded;
	
	[del.client sendMsg:msg];
	[msg release];
//	[_inputBar changeToAudioType];
	return YES;
}

- (void)iminputBarHideFaceViewAndShowMenuView
{
//	if(_inputBar.top <  self.view.height -  _inputBar.height)
//	{
//		_kbfaceView.top = self.view.height;
//		_kbmenuView.top = self.view.height - _kbmenuView.height;
//		_inputBar.top = self.view.height - _kbmenuView.height - _inputBar.height;
//		[self tableViewChangeToEidtMode];
//	}
//	else
//	{
	[UIView animateWithDuration:0.25f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 _kbfaceView.top = self.view.height;
						 _kbmenuView.top = self.view.height - _kbmenuView.height;
						 _inputBar.top = self.view.height - _kbmenuView.height - _inputBar.height;
						 
						[self tableViewChangeToEidtMode];
					 }
					 completion:^(BOOL finished){
						 
						 					 }];
//	}
}

- (void)iminputBarShowFaceView
{
//	if(_inputBar.top <  self.view.height -  _inputBar.height)
//	{
//		_kbfaceView.top = self.view.height - _kbfaceView.height;
//		_inputBar.top = self.view.height - _kbfaceView.height - _inputBar.height;
//		[self tableViewChangeToEidtMode];
//	}
//	else
//	{
		[UIView animateWithDuration:0.25f
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 _kbfaceView.top = self.view.height - _kbfaceView.height;
							 _inputBar.top = self.view.height - _kbfaceView.height - _inputBar.height;
							 [self tableViewChangeToEidtMode];
						 }
						 completion:^(BOOL finished){
							 
						 }];
//	}
}

- (void)iminputBarHideFaceViewAndMenuView
{
	[UIView animateWithDuration:0.25f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 _kbmenuView.top = self.view.height;
						 _kbfaceView.top = self.view.height;
						 _inputBar.top = self.view.height -  _inputBar.height;
						 [self tableViewChangeToNormal];
					 }
					 completion:^(BOOL finished){
					 }];
}

- (void)iminputBarKeyBoardDidShow:(CGFloat)keyBoardHeight
{
//	self.tableView.bottom = self.inputBar.top;
	[self tableViewChangeToEidtMode];
}

- (void)iminputBarKeyBoardDidHide
{
//	self.tableView.bottom = self.inputBar.top;
	[self tableViewChangeToNormal];
}

- (void)iminputBarCancelUpdate:(BOOL)flag
{
	self.talkMaskView.hidden = NO;
	if(flag)
	{
		self.talkMaskView.tstat = TALKVIEWSTATDELETE;
	}
	else
	{
		self.talkMaskView.tstat = TALKVIEWSTATSTART;
	}
}

- (void)iminputBarRecordCancel:(id)sender
{
	[self hideTalkMask];
	
	[self.recorder stopAndCancel];
}
#pragma mark TableViewChange
- (void)tableViewChangeToEidtMode
{
	self.tableView.height = self.inputBar.top ;
	if(self.autoScroll)
	{
		if(self.tableView.contentSize.height > self.tableView.frame.size.height)
		{
			[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height) animated:NO];
		}
	}
}

- (void)tableViewChangeToNormal
{
	self.tableView.height = self.view.height  - self.inputBar.height;
}
#pragma mark RecordDelegate
- (void)ppAmrRecorderDidSatart:(PPAmrRecorder *)recorder
{
	
}

- (void)ppAmrRecorderDidCancel:(PPAmrRecorder *)recorder
{
	[IMContext sharedContext].msgQueueMgr.isQueueRecording = NO;
	PPLOG(@"recorddidcancel");
	[[NSFileManager defaultManager] removeItemAtPath:recorder.mPath error:nil];
}

- (void)ppAmrRecorderDidStop:(PPAmrRecorder *)recorder
{
	[IMContext sharedContext].msgQueueMgr.isQueueRecording = NO;
	PPLOG(@"recorddidstop");
	if(recorder.mRecordFrames <= 25)
	{
		PPLOG(@"too short!");
		[self showTooShortTalkMask];
		return;
	}
	int sc = (recorder.mRecordFrames/50);
	int padsc = (recorder.mRecordFrames%50) < 25?0:1;
	sc = sc + padsc;
	
	PPLOG(@"%@:%d", recorder.mPath, recorder.mRecordFrames);
		
	_recordAudioMsg.msgSize = recorder.mRecordFrames;
	_recordAudioMsg.msgAttach = @{@"length": @(sc)};
	_recordAudioMsg.readState = IMMsgReadStateReaded;
	_recordAudioMsg.playState = IMMsgPlayStatePlayed;
	[del.client sendMsg:_recordAudioMsg];
	[self hideTalkMask];

}

#pragma mark MenuViewDelegate

- (void)menuViewSelectedPhoto:(MenuView *)menuView
{
	if(self.imgPicker == nil)
	{
		self.imgPicker = [[[UIImagePickerController alloc]init] autorelease];
		self.imgPicker.delegate = self;
	}
	
	self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	self.imgPicker.allowsEditing = NO;
	[self presentModalViewController:self.imgPicker animated:NO];
}

- (void)menuViewSelectedCamera:(MenuView *)menuView
{
	if(self.imgPicker == nil)
	{
		self.imgPicker = [[[UIImagePickerController alloc]init] autorelease];
		self.imgPicker.delegate = self;
	}
	
	if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
		return;
	self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
	self.imgPicker.allowsEditing = NO;
	self.imgPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
	[self presentModalViewController:self.imgPicker animated:NO];
}

- (void)menuViewSelectedFiles:(MenuView *)menuView
{
//	//if (self.fileController == nil) {
//		self.fileController = [[[FilesViewController alloc]init] autorelease];
//		self.fileController.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:self.title target:self action:@selector(navigationBack:)];
//		self.fileController.delegate = self;
//	//}
//	
//	[self.navigationController pushViewController:_fileController animated:YES];
    
    WorkFileViewController *workFileVC = [[WorkFileViewController alloc] init];
    workFileVC.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:workFileVC action:@selector(navigationBack:)];
    workFileVC.hidesBottomBarWhenPushed = YES;
	workFileVC.delegate = self;
    
    [self.navigationController pushViewController:workFileVC animated:YES];
    [workFileVC release];
}
#pragma mark - FilesViewControllerDelegate
- (void)workFilesDidSelected:(WorkFileViewController *)wfController withFiles:(NSArray *)files
{
	NSLog(@"%@", files);
	[wfController.navigationController popViewControllerAnimated:YES];
	for (NSDictionary *dic in files) {
		IMFileMsg *fileMsg = [[IMFileMsg alloc]initSendMsg];
		fileMsg.msgType = IMMsgTypeFile;
		fileMsg.msgTime = [NSDate date];
		fileMsg.fromUser = self.fromUser;
		fileMsg.msgUser = self.myUser;
		[fileMsg setFileLocalPath:dic[@"filepath"]];
		fileMsg.msgSize = [dic[@"filesize"] unsignedLongLongValue];
		
		[del.client sendMsg:fileMsg];
		[fileMsg release];
	}
}
//- (void)filesViewController:(FilesViewController *)viewController didFinishSelectionWithFileInfos:(NSArray *)fileInfos
//{
//	[viewController.navigationController popViewControllerAnimated:YES];
//	
//	for (NSDictionary *dic in fileInfos) {
//		PPLOG(@"%@", dic);
//		IMFileMsg *msg = [[IMFileMsg alloc]init];
//		msg.fromUser = self.fromUser;
//		msg.msgUser = self.myUser;
//		msg.msgID = [IMUtils generateMessageID];
//		msg.fromType = IMMsgFromLocalSelf;
//		msg.fileName = [dic objectForKey:@"filename"];
//		msg.displayName = [dic objectForKey:@"filename"];
//		[msg setLocalPath:[dic objectForKey:@"filepath"]];
//		msg.msgSize = [[dic objectForKey:@"filesize"] unsignedLongLongValue];
//		
//		[[IMMsgDeliver sharedDeliver] deliverMsg:msg];
//		[msg release];
//	}
//}
//
//- (void)filesViewControllerDidCancel:(FilesViewController *)viewController
//{
//	[viewController.navigationController popViewControllerAnimated:YES];
//}

- (UIImage* )rotateImage:(UIImage *)image {
//    int kMaxResolution = 320;
    // Or whatever
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
//    if (width > kMaxResolution || height > kMaxResolution) {
//        CGFloat ratio = width  /  height;
//        if (ratio > 1 ) {
//            bounds.size.width = kMaxResolution;
//            bounds.size.height = bounds.size.width / ratio;
//        }
//        else {
//            bounds.size.height = kMaxResolution;
//            bounds.size.width = bounds.size.height * ratio;
//        }
//    }
    CGFloat scaleRatio = 1;//bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch (orient) {
        case UIImageOrientationUp:
            //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0 );
            break;
        case UIImageOrientationDown:
            //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width );
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0 );
            break;
        case UIImageOrientationLeft:
            //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate( transform, 3.0 * M_PI / 2.0  );
            break;
        case UIImageOrientationRightMirrored:
            //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate( transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0 );
            break;
        default:
			return image;
			;
//            [NSExceptionraise:NSInternalInconsistencyExceptionformat:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform );
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

#pragma mark - ImagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:NO];
 
	if(![self xmppNetCheckOK:YES])
		return;
	
	NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
	
	if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
	{
	
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
		image = [self rotateImage:image];
	//    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
	//    [image drawInRect:CGRectMake(0, 0, 100, 100)];
	//    UIImage *thimg = UIGraphicsGetImageFromCurrentImageContext();
	//    UIGraphicsEndImageContext();
		

		
		IMPicMsg *msg = [[IMPicMsg alloc]init];
		msg.fromUser = self.fromUser;
		msg.msgUser = self.myUser;
		msg.msgID = [IMMsg generateMessageID];
		msg.fromType = IMMsgFromLocalSelf;
		
		NSData *data = UIImageJPEGRepresentation(image, 0.75f);
		[data writeToFile:msg.originFileLocalPath atomically:YES];
        msg.msgSize = [data length];
		
		UIImage *thumbImage = image;
		if (image.size.width < kMsgPicCellMaxWidth && image.size.height < kMsgPicCellMaxHeight)
		{
			thumbImage = image;
		}
		else
			thumbImage = [image scaleToFitSize:CGSizeMake(kMsgPicCellMaxWidth, kMsgPicCellMaxHeight)]; // should be thimg //for test
		
		data = UIImageJPEGRepresentation(thumbImage, 0.75f);
		[data writeToFile:msg.fileLocalPath atomically:YES];
		
		NSString *displayName = [msg.originFileLocalPath lastPathComponent];
		msg.msgAttach = @{@"disPlayName":displayName};
		[del.client sendMsg:msg];
		[msg release];
	}
	else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
		 == kCFCompareEqualTo)
	{
		NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
		PPLOG(@"%@", moviePath);
		
		NSURL *imageURL = [info valueForKey:UIImagePickerControllerMediaURL];
		NSLog(@"%@",imageURL);
		
		IMVideoMsg *msg = [[IMVideoMsg alloc]init];
		msg.fromUser = self.fromUser;
		msg.msgUser = self.myUser;
		msg.msgID = [IMMsg generateMessageID];
		msg.fromType = IMMsgFromLocalSelf;
		AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:imageURL options:nil];
		AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
		generator.appliesPreferredTrackTransform = YES;
		generator.maximumSize = CGSizeMake(200, 200);
		NSError *err = NULL;
		CMTime time = CMTimeMake(1, 60);
		CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
		
		UIImage *thumbImage = [[[UIImage alloc] initWithCGImage:imgRef] autorelease];
		NSInteger length =  asset.duration.value / asset.duration.timescale;
		msg.msgSize = length;
		
		NSData *data = UIImageJPEGRepresentation(thumbImage, 0.75f);
		[data writeToFile:msg.fileLocalPath atomically:YES];
		CGImageRelease(imgRef);
		[asset release];
		[generator release];
		
		NSString *displayName = [msg.originFileLocalPath lastPathComponent];
		msg.msgAttach = @{@"length": @(length), @"disPlayName":displayName};
		[[NSFileManager defaultManager] moveItemAtPath:moviePath toPath:msg.originFileLocalPath error:nil];
		[del.client sendMsg:msg];
		
		/////////////////////////////////
		/*
		[IMVideoTool encodeVideoOrientation:imageURL outputFile:[NSURL fileURLWithPath:msg.originPicLocalPath] hander:^(BOOL suc) {
			[[IMMsgDeliver sharedDeliver] deliverMsg:msg];	
		}];*/

	}

}

#pragma mark - CellClcik
- (void)imMsgCellErrorClick:(IMMsgCell *)cell
{
	if(cell.msg.procState == IMMsgProcStateFaied)
	{

		RIButtonItem *okBtn;
        if (cell.msg.fromType != IMMsgFromLocalSelf) {
            
            if (cell.msg.msgType == IMMsgTypeFile) {
                return;
            }
            
            if (cell.msg.msgType == IMMsgTypeAudio) {
                [self.msgQueue selectMsg:cell.msg];
                return;
            }
            
            __block typeof(self) weakSelf = self;
            okBtn = [RIButtonItem itemWithLabel:@"重新接收"];
            okBtn.action = ^(){
                [weakSelf.tableView reloadData];
            };
        } else {
            okBtn = [RIButtonItem itemWithLabel:@"重新发送"];
            okBtn.action = ^(){
                [del.client reSendMsg:cell.msg];
            };
        }
		
		RIButtonItem *cancelBtn = [RIButtonItem itemWithLabel:@"取消"];
		
		UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil cancelButtonItem:cancelBtn destructiveButtonItem:okBtn otherButtonItems:nil, nil];
		[sheet showInView:self.view];
		[sheet release];
		
		return;
	}

}


- (void)imMsgCellBodyDidSelected:(IMMsgCell *)cell
{
	if(cell.msg.procState == IMMsgProcStateFaied)
	{
//		if([self.imUser isChatRoom])
//			[del.xmppDelegate sendChatRoomMsg:cell.msg];
//		else
//			[del.xmppDelegate sendChatMsg:cell.msg];
		PPLOG(@"ffffff");
		
		RIButtonItem *okBtn;
        if (cell.msg.fromType != IMMsgFromLocalSelf) {
            
            if (cell.msg.msgType == IMMsgTypeFile) {
                return;
            }
            
            if (cell.msg.msgType == IMMsgTypeAudio) {
                [self.msgQueue selectMsg:cell.msg];
                return;
            }
            
            __block typeof(self) weakSelf = self;
            okBtn = [RIButtonItem itemWithLabel:@"重新接收"];
            okBtn.action = ^(){
                [weakSelf.tableView reloadData];
            };
        } else {
            okBtn = [RIButtonItem itemWithLabel:@"重新发送"];
            okBtn.action = ^(){
                [del.client reSendMsg:cell.msg];
            };
        }
		
		RIButtonItem *cancelBtn = [RIButtonItem itemWithLabel:@"取消"];
		
		UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil cancelButtonItem:cancelBtn destructiveButtonItem:okBtn otherButtonItems:nil, nil];
		[sheet showInView:self.view];
		[sheet release];
		
		return;
	}
	if([cell.msg isMemberOfClass:[IMAudioMsg class]])
		[self.msgQueue selectMsg:cell.msg];
	
 	else if ([cell.msg isKindOfClass:[IMPicMsg class]])
	{
		IMPicMsg *msg = (IMPicMsg *)cell.msg;
		IMPicFileViewController *pv = [[IMPicFileViewController alloc]initWithNibName:nil bundle:nil];
		pv.picMsg = msg;
		pv.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:pv animated:YES];
		[pv release];
	}
	else if ([cell.msg isMemberOfClass:[IMFileMsg class]])
	{
		[self imMsgCellGotoPreView:cell];
	}
}

- (void)imMsgCellPicDidSelected:(IMMsgCell *)cell
{
	IMPicMsg *msg = (IMPicMsg *)cell.msg;
	PPLOG(@"bigpic:%@", msg.originFileLocalPath);
//	PicViewController *pv = [[PicViewController alloc]initWithNibName:nil bundle:nil];
//	pv.navTitle = msg.msgUser.nickName;
//	pv.hidesBottomBarWhenPushed = YES;
//	pv.msg = msg;
//	[self.navigationController pushViewController:pv animated:YES];
//    [pv release];
	IMPicFileViewController *pv = [[IMPicFileViewController alloc]initWithNibName:nil bundle:nil];
	pv.picMsg = msg;
	pv.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:pv animated:YES];
	[pv release];
}

- (void)imMsgCellHeadDidSelected:(IMMsgCell *)cell
{
	if(cell.msg.fromType != IMMsgFromOther)
	{
		        return;
	}
	
}


- (void)imMsgCellLongPress:(IMMsgCell *)cell
{
	PPLOG(@"Long Press!");
	[_inputBar closeInputBar];
}

- (void)imMsgCellShouldDelete:(IMMsgCell *)cell
{
	IMMsg *msg = cell.msg;
	NSInteger i = [self.msgArray indexOfObject:msg];
	if(i != NSNotFound)
	{
		[self.msgQueue deleteMsgs:@[msg]];
//		if(ar == nil)
//			return;
//		[self.tableView beginUpdates];
//		[self.tableView deleteRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationFade];
//		[self.tableView endUpdates];

	}
	
}

- (void)imMsgCellCancelProcess:(IMMsgCell *)cell
{
	PPLOG(@"cancel Process");
	IMFileMsg *fileMsg = (IMFileMsg *)cell.msg;
	[fileMsg cancelProcessing];
//	if (fileMsg.fromType == IMMsgFromLocalSelf)
//	{
//		[del.imAgent.goComCore cancelSendMessage:fileMsg.fileName];
//	}
//	else
//	{
//		[del.imAgent.goComCore cancelDownloadFileWithName:fileMsg.fileName];
//	}
}

- (void)imMsgCellReProcess:(IMMsgCell *)cell
{
	PPLOG(@"re Process");
	IMFileMsg *fileMsg = (IMFileMsg *)cell.msg;
	if (fileMsg.fromType == IMMsgFromLocalSelf)
	{
		[del.client reSendMsg:cell.msg];
	}
	else
	{
		[fileMsg downloadFile];
	}
}

- (void)imMsgCellGotoPreView:(IMMsgCell *)cell
{
	PPLOG(@"goto preview");
	IMFileMsg *fileMsg = (IMFileMsg *)cell.msg;
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:fileMsg.fileLocalPath] || ![FilePreviewController canPreviewItem:[NSURL fileURLWithPath:fileMsg.fileLocalPath]])
	{
//		[del showHudwithTitle:@"无法预览" detail:@"不支持的格式或文件不存在"];
		return;
	}
	
//	FilePreviewController *filevc = [[FilePreviewController alloc]initWithFile:[NSURL fileURLWithPath:fileMsg.localPath]];
//	filevc.hidesBottomBarWhenPushed = YES;
//	[self.navigationController pushViewController:filevc animated:YES];
//	[filevc release];
	
	IMPicFileViewController *pv = [[IMPicFileViewController alloc]initWithNibName:nil bundle:nil];
	pv.picMsg = (IMPicMsg *)fileMsg;
	pv.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:pv animated:YES];
	[pv release];
	
}
#pragma mark - TalkMaskView

- (void)showBeginTalkMask
{
	self.talkMaskView.tstat = TALKVIEWSTATSTART;
	self.talkMaskView.hidden = NO;
}

- (void)showTooShortTalkMask
{
	self.talkMaskView.tstat = TALKVIEWSTATTOOSHORT;
	self.talkMaskView.hidden = NO;
	[self performSelector:@selector(hideTalkMask) withObject:nil afterDelay:2.0f];
}

- (void)hideTalkMask
{
	self.talkMaskView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	if (self.presentedViewController)
	{
		_parentController = self;
	}
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void)faceViewDeleteLastFace:(IMFaceView *)faceView
{
	[_inputBar deleteLastCharOrFace];
}
- (void)faceView:(IMFaceView *)faceView addFaceStr:(NSString *)facestr
{
	[_inputBar appendFaceText:facestr];
}
- (void)faceViewSend:(IMFaceView *)faceView
{
	[_inputBar sendInputText];
}

#pragma mark - OldMsg
- (void)oldMsgLoaded:(NSNotification *)note
{
	[self actviewStopAnimation];
	
	
	NSArray *msgArray = [note object];
	if(!self.msgQueue.hasMoreHistroy)
	{
		[self hidenActViewInTable];
	}
	
	if([msgArray count] == 0)
		return;
	
	[self.tableView reloadData];
	
	NSMutableArray *array = [NSMutableArray array];
    int cnt = [msgArray count];
    for(int i = 0 ; i< cnt; i++)
    {
        [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
	CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[array count] inSection:0]];
	[self.tableView setContentOffset:CGPointMake(0, rect.origin.y-32)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	NSLog(@"%d:%f", self.isLoadingHistory, scrollView.contentOffset.y);
	if(scrollView.contentOffset.y <= 1 && self.isLoadingHistory == NO && self.msgQueue.hasMoreHistroy == YES)
    {
		if([self.msgQueue beginLoadHistroy])
		{
			[self actviewStartAnimation];
		}
		else
		{
			[self hidenActViewInTable];
		}
	}
	
	if (scrollView.contentOffset.y + scrollView.height >= scrollView.contentSize.height) 
		_autoScroll = YES;
	else
		_autoScroll = NO;
}

- (void)actviewStartAnimation
{
    self.tableView.contentInset = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
    self.actView.hidden = NO;
	self.isLoadingHistory = YES;
    [self.actView startAnimating];
}

- (void)actviewStopAnimation
{
    [self.actView stopAnimating];
    self.actView.hidden = YES;
	self.isLoadingHistory = NO;
}

- (void)hidenActViewInTable
{
	self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

- (void)adjustTableViewContentInset
{
	if(self.msgQueue.hasMoreHistroy == NO)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    else
    {
        self.tableView.contentInset = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
    }
//	[[IMMsgDeliver sharedDeliver] updateChatHistoryList];

}

#pragma mark 
- (void)goChatRecod
{
//	IMChatRecordViewController *chatVc = [[IMChatRecordViewController alloc]initWithNibName:nil bundle:nil];
//	chatVc.hidesBottomBarWhenPushed = YES;
//	[self.navigationController pushViewController:chatVc animated:YES];
//    chatVc.navLabel.text = @"聊天记录";
//    [chatVc release];
}


@end
