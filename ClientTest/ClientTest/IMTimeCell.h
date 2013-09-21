//
//  IMTimeCell.h
//  DoctorChat
//
//  Created by 王鹏 on 13-3-5.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMTimeCell : UITableViewCell
{
	UIImageView *_bgImageView;
	UILabel *_timeLabel;
}
@property (nonatomic, retain) NSDate *msgTime;
@end
