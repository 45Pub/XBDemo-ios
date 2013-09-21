//
//  SelectedBar.h
//  IMLite
//
//  Created by admins on 13-7-24.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedBar : UIView

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, retain) UIButton *checkBox;

@property (nonatomic, copy) void (^allSelectedBlock)(BOOL);

- (void)setNameLabelText:(NSString *)text;

@end
