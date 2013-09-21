//
//  PPTabBar.h
//  PPLibTest
//
//  Created by Paul Wang on 12-6-18.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PPTabBarDelegate;

@interface PPTabBar : UIView
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) NSMutableArray *itemArray;
@property (nonatomic, assign) id <PPTabBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray;
- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray backgroundImage:(UIImage *)backgroundImage;
- (void)updateBadgeNum:(NSInteger)badgeNum atIndex:(NSInteger)index;
- (void)selectTabAtIndex:(NSInteger)index;
@property (nonatomic) NSInteger curIndex;
@end

@protocol PPTabBarDelegate <NSObject>
@optional
- (void)tabBar:(PPTabBar *)tabBar didSelectIndex:(NSInteger)index;
@end
