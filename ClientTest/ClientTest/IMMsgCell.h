//
//  IMMsgCell.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IMMsgAll.h>
#import <IMUser.h>
#import "PPCore.h"
#import "UIImage+PPCategory.h"
#import "UIView+PPCategory.h"
#import "NSString+PPCategory.h"

#define kMsgCellTopPading 6 
#define kMsgCellLeftPading 10
#define kMsgCellRightPading 10 
#define kMsgCellBottomPadding 8

#define kMsgCellPadding 5.0f
#define kMsgCellUserHeadViewWidth 35
#define kMsgCellUserHeadViewHeight 35
#define kMsgCellTotalWidth 320
//userName
#define kMsgCellUserNameColor UICOLOR_RGB(75, 75, 75)
#define kMsgCellUserNameFont [UIFont systemFontOfSize:12.0f]
#define kMsgCellHeadUserSpace 12.0
//body
#define KMsgCellBodyTextFont [UIFont systemFontOfSize:14.0f]
#define kMsgCellBodyTextColor [UIColor blackColor]
#define kMsgCellUserBodySpace 2.0
#define kMsgCellBodyMaxWidth (320-kMsgCellUserHeadViewWidth*2-kMsgCellUserBodyHeadSapce-kMsgCellLeftPading-kMsgCellRightPading)
#define kMsgCellUserBodyHeadSapce 5.0
#define kMsgCellUserBodyBackGroundHeading 6.0f
#define kMsgCellUserBodyBackGroundHeadingWL 16.0f
#define kMsgCellUserBodyBackGroundHeadingWR 7.0f
#define kMsgCellUserBodyBackGroundHeadingH 10.0f
#define kMsgCellAudioCellHeiht 35.0f
//pic
#define kMsgPicCellDefaultPic @"msg_pic_default.png"
#define kMsgPicCellMaxWidth  100.0f
#define kMsgPicCellMaxHeight  100.0f
#define kMsgPicCellBodyLeftPadding 8+5
#define kMsgPicCellBodyPadding 5

//File
#define kMsgBodyIconSize 25
#define kMsgCellFileBodyWidth (320 - kMsgCellUserHeadViewWidth - kMsgCellUserBodyHeadSapce - kMsgCellLeftPading - 66) 

//video
#define kMsgVideoCellDefualtPic @"msg_video_default.png"


#define kMsgCellChatBubbleGrayImage [[UIImage imageNamed:@"chat_bubble_gray.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:26]
#define kMsgCellChatBubbleGreenImage [[UIImage imageNamed:@"chat_bubble_green.png"] stretchableImageWithLeftCapWidth:23 topCapHeight:26]


//Mail ,Post, News
#define kMsgMailCellPadding 9
@class IMMsgCell;
@protocol IMMsgCellDelegate <NSObject>

@optional
- (void)imMsgCellBodyDidSelected:(IMMsgCell *)cell;
- (void)imMsgCellHeadDidSelected:(IMMsgCell *)cell;
- (void)imMsgCellPicDidSelected:(IMMsgCell *)cell;
- (void)imMsgCellLongPress:(IMMsgCell *)cell;
- (void)imMsgCellShouldDelete:(IMMsgCell *)cell;
- (void)imMsgCellCancelProcess:(IMMsgCell *)cell;
- (void)imMsgCellReProcess:(IMMsgCell *)cell;
- (void)imMsgCellGotoPreView:(IMMsgCell *)cell;
- (void)imMsgCellErrorClick:(IMMsgCell *)cell;
@end

@interface IMMsgCell : UITableViewCell
@property (nonatomic, retain) UIImageView *userHeadView;
@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) UIButton *errorView;
@property (nonatomic, retain) IMMsg *msg;
@property (nonatomic, assign) id <IMMsgCellDelegate> delegate;
@property (nonatomic) BOOL canDelete;
@property (nonatomic, retain) NSIndexPath *indexPath;
+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg;
- (void)cellBodyClick:(id)sender;
@end
