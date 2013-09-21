//
//  IMBaseChatViewController.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PPBaseViewController.h"
#import "IMInputBar.h"
#import <IMMsgAll.h>
#import <IMUser.h>
#import "IMMsgCellUtil.h"
#import "UITableView+PPCategory.h"
#import "UIView+PPCategory.h"

#import "PPAmrRecorder.h"
#import "UIHelper.h"
#import "MenuView.h"
#import "IMFaceView.h"
#import "TalkView.h"
#import "IMTableView.h"
#import "IMNetHud.h"
#import <IMMsgQueue.h>
//#import "FilesViewController.h"
@interface IMBaseChatViewController : PPBaseViewController <UITableViewDataSource, UITableViewDelegate, IMMsgCellDelegate, IMInputBarDelegate, PPAmrRecorderDelegate, UIGestureRecognizerDelegate, MenuViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, IMFaceViewDelegate>
{
	UIViewController *_parentController;
}
@property (nonatomic, retain) IMTableView *tableView;
@property (nonatomic, retain) NSArray *msgArray;
@property (nonatomic, retain) IMMsgQueue *msgQueue;
@property (nonatomic, retain) IMUser *fromUser;
@property (nonatomic, retain) IMUser *myUser;
@property (nonatomic, retain) IMInputBar *inputBar;
@property (nonatomic, retain) PPAmrRecorder *recorder;
@property (nonatomic, retain) IMFaceView *kbfaceView;
@property (nonatomic, retain) MenuView *kbmenuView;
@property (nonatomic, retain) TalkView *talkMaskView;
@property (nonatomic, retain) IMNetHud *netHud;
@property (nonatomic) BOOL autoScroll;
@property (nonatomic, retain) UIActivityIndicatorView *actView;
- (id)initWithFromUser:(IMUser *)user;
- (void)newMsg:(NSNotification *)note;
- (void)adjustTableViewContentInset;
- (void)goChatRecod;
- (void)showTooShortTalkMask;
- (void)hideTalkMask;
- (void)navigationBack:(id)sender;
- (void)userInfoChanged;
@end
