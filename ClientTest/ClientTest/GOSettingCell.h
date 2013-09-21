//
//  GOSettingCell.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOSettingCell : UITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) id detail;

@end
