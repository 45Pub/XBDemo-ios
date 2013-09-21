//
//  IMAudioMsgCell.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgCell.h"

@interface IMAudioMsgCell : IMMsgCell
@property (nonatomic, retain) UIButton *bgView;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UIImageView *playStateView;
@property (nonatomic, retain) UILabel *secLabel;
@end
