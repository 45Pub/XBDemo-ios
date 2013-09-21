//
//  GOSelectedBar.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-8.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APPEND_ANIMATION_DURATION 0.3

extern NSString *GOSelectedBarItemDidDeselectNotification;

@interface GOSelectedBar : UIView
@property (nonatomic, assign) BOOL isCountGRP;//计算已选择的人数时，是否算上讨论组，群组，和部门，默认不算；

+ (CGSize)imageButtonSize;

- (BOOL)isUserSelectedWithID:(NSString *)identifier;
- (void)appendItemWithImage:(UIImage *)image withID:(NSString *)identifier;
- (void)appendItemWithURL:(NSURL *)url withID:(NSString *)identifier;
- (void)deleteItemWithID:(NSString *)identifier;

- (void)setDoneTarget:(id)target action:(SEL)selector;
- (void)setDoneButtonTitle;

@end
