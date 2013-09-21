//
//  GOUserInfoCell.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GOUserInfoCellAccessoryType) {
    GOUserInfoCellAccessoryTypeNone = 0,
    GOUserInfoCellAccessoryTypePhone = 1,
    GOUserInfoCellAccessoryTypeMail = 2
};

@interface GOUserInfoCell : UITableViewCell

@property (nonatomic, assign) GOUserInfoCellAccessoryType infoType;

@property (nonatomic, copy) void (^accessoryActionBlock)(NSString *);

- (void)setTitle:(NSString *)titleString
            info:(NSString *)infoString;

- (void)setTitle:(NSString *)titleString info:(NSString *)infoString infoType:(GOUserInfoCellAccessoryType)infoType;
+ (CGFloat)heightwithTitle:(NSString *)titleString InfoString:(NSString *)infoString infoType:(GOUserInfoCellAccessoryType)infoType;
@end
