//
//  SelectedBar.m
//  IMLite
//
//  Created by admins on 13-7-24.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "SelectedBar.h"
#import "UIView+PPCategory.h"

#define LeftMargin 8.0
#define NameLabelWidth 200.0

@interface SelectedBar()

@property (nonatomic, retain) UILabel *nameLabel;

@end

@implementation SelectedBar

- (void)dealloc
{
    [_nameLabel release];
    [_checkBox release];
    Block_release(_allSelectedBlock);
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(LeftMargin, 0, NameLabelWidth, self.height)];
        self.nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont systemFontOfSize:13.0];
        [self addSubview:self.nameLabel];
        
        self.checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        self.checkBox.frame = CGRectMake(284.0, (self.height - 26.0)/2, 26.0, 26.0);
        [self setCheckBoxImage:@"check" selectedImage:@"checked"];
        [self.checkBox addTarget:self action:@selector(checkBoxClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.checkBox];
        
        UIImage *bg = [[UIImage imageNamed:@"workfile_footbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)];
        [self setBackgroundImage:bg];
    }
    return self;
}

- (void)checkBoxClicked:(id)sender
{
    self.checkBox.selected = !self.checkBox.selected;
    self.isSelected = self.checkBox.isSelected;
    
    if(self.allSelectedBlock)
    {
        self.allSelectedBlock(self.isSelected);
    }
}

- (void)setCheckBoxImage:(NSString *)check selectedImage:(NSString *)checked
{
    [self.checkBox setImage:[UIImage imageNamed:check] forState:UIControlStateNormal];
    [self.checkBox setImage:[UIImage imageNamed:checked] forState:UIControlStateSelected];
}

- (void)setNameLabelText:(NSString *)text
{
    self.nameLabel.text = text;
}

- (void)setIsSelected:(BOOL)isSelected
{
    if(_isSelected == isSelected)
        return;
    
    _isSelected = isSelected;
    self.checkBox.selected = _isSelected;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
