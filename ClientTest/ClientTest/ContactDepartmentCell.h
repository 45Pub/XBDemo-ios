//
//  ContactDepartmentCell.h
//  IMLite
//
//  Created by admins on 13-7-23.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactUserCell.h"

@interface ContactDepartmentCell : ContactUserCell

@property (nonatomic, retain) UIImageView *stateView;

@property (nonatomic, assign) BOOL isOpen;

- (void)setIsOpen:(BOOL)isOpen;

- (void)setUserName:(NSString *)userName;

@end
