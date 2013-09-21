//
//  GOMultiSelectCell.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_EDIT_INTENTATON_ANIMATION_DURATION 0.4

typedef NS_ENUM(NSInteger, GOMultiSelectCellCheckBoxPosition) {
    GOMultiSelectCellCheckBoxPositionLeft = 10,
    GOMultiSelectCellCheckBoxPositionRight = 11
};

typedef void (^MultiSelectedBlock)(BOOL mSelected);

@interface GOMultiSelectCell : UITableViewCell

@property (nonatomic, assign, readonly) GOMultiSelectCellCheckBoxPosition checkBoxPosition;

@property (nonatomic, assign) BOOL multiSelected;

// if this property is set to NO, we can only multi-select through tapping the checkbox. Default YES
@property (nonatomic, assign) BOOL canMultiSelectThroughSelect;

@property (nonatomic, assign) BOOL shouldKeepBackgroundDuringMultiSelecting;

@property (nonatomic, assign, getter = isCheckable) BOOL checkable;

@property (nonatomic, copy) MultiSelectedBlock multiSelectedBlock;

@property (nonatomic, assign) UITableViewCellStateMask stateMask;

- (instancetype)initWithCheckBoxPosition:(GOMultiSelectCellCheckBoxPosition)position reuseIdentifier:(NSString *)reuseIdentifier;

// calling this methods will cause execution of multiSelectedBlock when completion. to avoid this effect, call setMultiSelected directly.
- (void)setMultiSelected:(BOOL)multiSelected animated:(BOOL)animated;

- (void)setCheckBoxSelectedImage:(UIImage *)selectedImage
                      unselected:(UIImage *)unselectedImage;

- (void)enableEditingAccerroryView;

- (void)disableEditingAccessoryView;

@end
