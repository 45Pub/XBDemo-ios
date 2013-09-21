//
//  GOMultiSelectCell.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOMultiSelectCell.h"
#import "PPCore.h"
#import "UIColor+PPCategory.h"
#import "UIButton+PPCategory.h"


@interface GOMultiSelectCell ()
{
    BOOL _touchingCheckbox;
}

@property (nonatomic, retain) UIView *multiSelectedBackgroundView;
@property (nonatomic, retain) UIButton *checkBoxButton;
@property (nonatomic, assign) CGRect checkBoxReconglizeRect;

@property (nonatomic, assign, readwrite) GOMultiSelectCellCheckBoxPosition checkBoxPosition;

@end

@implementation GOMultiSelectCell

- (void)dealloc
{
    PP_RELEASE(_multiSelectedBackgroundView);
    PP_RELEASE(_checkBoxButton);
    Block_release(_multiSelectedBlock);
    
    [super dealloc];
}

- (instancetype)initWithCheckBoxPosition:(GOMultiSelectCellCheckBoxPosition)position reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.checkBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.checkBoxButton.opaque = NO, _checkBoxButton.alpha = 0.0;
        self.checkBoxButton.bounds = CGRectMake(0.0, 0.0, 26.0, 26.0);
        
        if (position == GOMultiSelectCellCheckBoxPositionLeft) {
            [self.contentView addSubview:self.checkBoxButton];
        }
        else if (position == GOMultiSelectCellCheckBoxPositionRight) {
            self.editingAccessoryView = self.checkBoxButton;
        }
        
        self.canMultiSelectThroughSelect = YES;
        self.shouldKeepBackgroundDuringMultiSelecting = NO;
        _stateMask = UITableViewCellStateDefaultMask;
        self.checkBoxPosition = position;
        
        [self.checkBoxButton addTarget:self action:@selector(checkBoxAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        [self setCheckBoxSelectedImage:[UIImage imageNamed:@"checked"] unselected:[UIImage imageNamed:@"check"]];
        
        _checkable = YES;
    }
    return self;
}

- (void)enableEditingAccerroryView {
    if (self.checkBoxButton) {
        self.editingAccessoryView = self.checkBoxButton;
    }
}

- (void)disableEditingAccessoryView {
    self.editingAccessoryView = nil;
}

- (void)checkBoxAction:(id)sender
{
    [self setMultiSelected:!self.multiSelected animated:YES];
}

#pragma mark - Private Methods

- (void)_changeBuiltInLabelsTextColor
{
    UIColor *white = [UIColor whiteColor];
    UIColor *black = [UIColor blackColor];
    
    if (self.multiSelected) {
        self.textLabel.textColor = white;
        self.detailTextLabel.textColor = white;
    }
    else {
        self.textLabel.textColor = black;
        self.detailTextLabel.textColor = black;
    }
}

#pragma mark - Cell configuration Methods

- (void)setShouldKeepBackgroundDuringMultiSelecting:(BOOL)shouldKeepBackgroundDuringMultiSelecting
{
    _shouldKeepBackgroundDuringMultiSelecting = shouldKeepBackgroundDuringMultiSelecting;
    
    if (shouldKeepBackgroundDuringMultiSelecting && _multiSelectedBackgroundView == nil) {
        _multiSelectedBackgroundView = [[UIView alloc] init];
        _multiSelectedBackgroundView.backgroundColor = [UIColor colorWithRed:3.0/255.0 green:113.0/255.0 blue:236.0/255.0 alpha:1.0];
        _multiSelectedBackgroundView.opaque = NO;
        _multiSelectedBackgroundView.alpha = 0.0;
        [self insertSubview:self.multiSelectedBackgroundView belowSubview:self.contentView];
    }
}

- (void)setMultiSelected:(BOOL)multiSelected animated:(BOOL)animated executeCompletionBlock:(BOOL)shouldExecute
{
    _multiSelected = multiSelected;
    
    self.checkBoxButton.selected = multiSelected;
    
    if (self.multiSelectedBackgroundView) {
        CGFloat alphaValue = multiSelected ? 1.0 : 0.0;
        if (animated == NO) {
            self.multiSelectedBackgroundView.alpha = alphaValue;
        }
        else {
            [UIView animateWithDuration:0.2 animations:^{
                self.multiSelectedBackgroundView.alpha = alphaValue;
            }];
        }
        [self _changeBuiltInLabelsTextColor];
    }
    
    if (shouldExecute && self.multiSelectedBlock) {
        self.multiSelectedBlock(multiSelected);
    }
    
    if (self.checkable == NO) {
        // use the system builtin mask to show a button is disable or not, so we should has different normal image.
        if (multiSelected) {
            [self.checkBoxButton setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        }
        else {
            [self.checkBoxButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        }
    }
}

- (void)setCheckable:(BOOL)checkable
{
    _checkable = checkable;
    
    self.checkBoxButton.enabled = checkable;
    
    if (_checkable) {
        // recover the image.
        [self setCheckBoxSelectedImage:[UIImage imageNamed:@"checked"] unselected:[UIImage imageNamed:@"check"]];
    }
}

- (void)setMultiSelected:(BOOL)multiSelected animated:(BOOL)animated
{
    [self setMultiSelected:multiSelected animated:animated executeCompletionBlock:YES];
}

// simply setter won't call completion block.
- (void)setMultiSelected:(BOOL)multiSelected
{
    [self setMultiSelected:multiSelected animated:NO executeCompletionBlock:NO];
}

- (void)setCheckBoxSelectedImage:(UIImage *)selectedImage unselected:(UIImage *)unselectedImage
{
    [self.checkBoxButton setImage:selectedImage forState:UIControlStateSelected];
    [self.checkBoxButton setImage:unselectedImage forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_touchingCheckbox) {
        selected = NO;
        _touchingCheckbox = NO;
    }
    [super setSelected:selected animated:animated];
}

#pragma mark - Touch Handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self.contentView];
    
    if (CGRectContainsPoint(self.checkBoxReconglizeRect, location)) {
        _touchingCheckbox = YES;
    }
    else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.checkable == NO) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.contentView];
    
    if (_touchingCheckbox && !CGRectContainsPoint(self.checkBoxReconglizeRect, location)) {
        _touchingCheckbox = NO;
    }
    else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    _touchingCheckbox = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.contentView];
    
    if (_touchingCheckbox && CGRectContainsPoint(self.checkBoxReconglizeRect, location)) {
        if (self.checkable) {
            [self.checkBoxButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    else {
        [super touchesEnded:touches withEvent:event];
    }
}

#pragma mark - State Transition

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.multiSelectedBackgroundView) {
        self.multiSelectedBackgroundView.frame = self.bounds;
    }
    
    if (self.stateMask == UITableViewCellStateEditingMask) {
        [UIView animateWithDuration:CELL_EDIT_INTENTATON_ANIMATION_DURATION animations:^{
            self.checkBoxButton.alpha = 1.0;
        }];
        
        if (self.checkBoxPosition == GOMultiSelectCellCheckBoxPositionRight && self.editingStyle == UITableViewCellEditingStyleNone) {
            // explicitly settle the contentView's frame to prevent intentation animation.
            self.contentView.frame = self.contentView.bounds;
        }
        else if (self.checkBoxPosition == GOMultiSelectCellCheckBoxPositionLeft) {
            self.checkBoxButton.center = CGPointMake(-16.0, CGRectGetHeight(self.bounds) * 0.5);
        }
    }
    else if (self.stateMask == UITableViewCellStateDefaultMask) {
        [UIView animateWithDuration:CELL_EDIT_INTENTATON_ANIMATION_DURATION animations:^{
            self.checkBoxButton.alpha = 0.0;
        }];
        
        if (self.checkBoxPosition == GOMultiSelectCellCheckBoxPositionRight) {
            self.checkBoxButton.center = CGPointMake(CGRectGetWidth(self.bounds) + 16.0, CGRectGetHeight(self.bounds) * 0.5);
        }
        else if (self.checkBoxPosition == GOMultiSelectCellCheckBoxPositionLeft) {
            self.checkBoxButton.center = CGPointMake(-16.0, CGRectGetHeight(self.bounds) * 0.5);
        }
    }
    
    self.checkBoxReconglizeRect = CGRectMake(self.checkBoxButton.frame.origin.x - 10.0,
                             self.checkBoxButton.frame.origin.y - 10.0,
                             self.checkBoxButton.frame.size.width + 20.0,
                             self.checkBoxButton.frame.size.height + 20.0);
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    self.stateMask = state;
    [super willTransitionToState:state];
}

@end
