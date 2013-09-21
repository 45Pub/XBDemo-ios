//
//  IMInputBar.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "TalkButton.h"

typedef NS_ENUM(NSInteger, IMInputType)
{
	IMInputTypeAudio = 0,
	IMInputTypeText ,
	IMInputTypeFace ,
	IMInputTypeMenu ,
};
@protocol IMInputBarDelegate;
@interface IMInputBar : UIView <HPGrowingTextViewDelegate>
{
	HPGrowingTextView *_textView;
	IMInputType _barType;
	UIButton *_atSwitchBtn;
	TalkButton *_audioBtn;
	UIButton *_faceBtn;
	UIButton *_menuBtn;
	
}
@property (nonatomic) NSInteger limitWordsNum;
@property (nonatomic, assign) id <IMInputBarDelegate> delegate;
- (void)changeToAudioType;
- (void)appendFaceText:(NSString *)faceText;
- (void)sendInputText;
- (void)deleteLastCharOrFace;
- (void)changeToTextType;
- (void)closeInputBar;
@end


@protocol IMInputBarDelegate <NSObject>

@optional
- (void)iminputBarBeginRecord;
- (void)iminputEndRecord;
- (BOOL)iminputBarSendText:(NSString *)message;
- (void)iminputBarHideFaceViewAndShowMenuView;
- (void)iminputBarShowFaceView;
- (void)iminputBarHideFaceViewAndMenuView;
- (void)iminputBarKeyBoardDidShow:(CGFloat)keyBoardHeight;
- (void)iminputBarKeyBoardDidHide;
- (void)iminputBarCancelUpdate:(BOOL)flag;
- (void)iminputBarRecordCancel:(id)sender;
@end