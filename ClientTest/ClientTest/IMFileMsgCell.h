//
//  IMFileMsgCell.h
//  GoComIM
//
//  Created by 王鹏 on 13-5-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgCell.h"
@class MCProgressBarView;

@interface IMFileMsgCell : IMMsgCell
{
	UIButton *_bodyBgView;
	UIImageView *_bodyIconView;
	UILabel *_nameLabel;
	UILabel *_stateLabel;
	UIButton *_optBtn;
	MCProgressBarView *_progressBar;
}
@end
