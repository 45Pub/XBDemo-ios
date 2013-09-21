//
//  IMPicMsgCell.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgCell.h"
#import "MCProgressBarView.h"
@interface IMPicMsgCell : IMMsgCell
@property (nonatomic, retain) UIButton *bgView;
@property (nonatomic, retain) UIImageView *picView;
@property (nonatomic, retain) MCProgressBarView *progressBarView;
@end
