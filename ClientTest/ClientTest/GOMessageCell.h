//
//  GOMessageCell.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-27.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IMUser;
@interface GOMessageCell : UITableViewCell

- (void)setCellInfoWithFromUser:(IMUser *)fromUser
                    unreadCount:(NSUInteger)unreadCount
                      msgSource:(NSString *)source
                       subtitle:(NSString *)subtitle
                           time:(NSString *)time;

@end
