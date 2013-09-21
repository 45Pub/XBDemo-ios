//
//  IMVideoMsgCell.h
//  GoComIM
//
//  Created by 王鹏 on 13-5-8.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMPicMsgCell.h"

@interface IMVideoMsgCell : IMPicMsgCell
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UIButton *optBtn;
@property (nonatomic, retain) UIImageView *playImageView;
@end
