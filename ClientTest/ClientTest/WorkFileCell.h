//
//  WorkFileCell.h
//  IMLite
//
//  Created by admins on 13-7-24.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkFileCell : UITableViewCell

@property (nonatomic, retain) NSString *fileName;

@property (nonatomic, retain) UIImageView *fileIcon;

@property (nonatomic, retain) UILabel *fileNameLabel;

@property (nonatomic, retain) UIButton *checkBox;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign)UITableViewCellStateMask stateMask;

@property (nonatomic, copy) void (^accessoryActionBlock)(BOOL);

- (void)setFileName:(NSString *)fileName time:(NSString *)time;

@end
