//
//  GOInfoInputView.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-25.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOInfoInputView : UIView

@property (nonatomic, retain) UITextField *textField;

- (instancetype)initWithFrame:(CGRect)frame fieldName:(NSString *)name;

- (void)setCornerDirection:(UIRectCorner)direction;

@end
