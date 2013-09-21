//
//  IMNoticeCell.h
//  GoComIM
//
//  Created by 王鹏 on 13-5-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMMsg.h"
@interface IMNoticeCell : UITableViewCell
{
	UIImageView *_bgImageView;
	UILabel *_timeLabel;
}

@property (nonatomic, retain) IMMsg *msg;
+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg;
@end
