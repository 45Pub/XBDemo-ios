//
//  IMTextMsgCell.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMMsgCell.h"
#import "TTTAttributedLabel.h"
#import "IMBgButton.h"
@interface IMTextMsgCell : IMMsgCell <TTTAttributedLabelDelegate>
@property (nonatomic, retain) TTTAttributedLabel *textView;
@property (nonatomic, retain) IMBgButton *textBgBtnView;
@end
