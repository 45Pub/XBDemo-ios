//
//  MenuView.h
//  DoctorChat
//
//  Created by 王鹏 on 13-2-5.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MenuViewDelegate;
@interface MenuView : UIView
@property (nonatomic, assign) id <MenuViewDelegate> delegate;
@end

@protocol MenuViewDelegate <NSObject>

@optional
- (void)menuViewSelectedPhoto:(MenuView *)menuView;
- (void)menuViewSelectedCamera:(MenuView *)menuView;
- (void)menuViewSelectedFiles:(MenuView *)menuView;
@end