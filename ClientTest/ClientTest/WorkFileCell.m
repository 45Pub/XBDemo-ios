//
//  WorkFileCell.m
//  IMLite
//
//  Created by admins on 13-7-24.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "WorkFileCell.h"
#import "UIView+PPCategory.h"

#define LeftMargin 8.0
#define IconWidth 15.0
#define IconHEight 16.0
#define Icon_PathLabel_Padding 5.0
#define filePathLabelWidth 170.0
#define filePathLabelHeight 30.0
#define TimeLabelLeft 220.0
#define TimeLabelWidth 60.0
#define TimeLabelHeight 30.0

@interface WorkFileCell()

@property (nonatomic, retain) NSString *timeStr;

@property (nonatomic, retain) UILabel *timeLabel;

@end

@implementation WorkFileCell

- (void)dealloc
{
    [_fileName release];
    [_fileNameLabel release];
    [_fileIcon release];
    [_checkBox release];
    [_timeLabel release];
    [_timeStr release];
    Block_release(_accessoryActionBlock);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _fileIcon = [[UIImageView alloc] initWithFrame:CGRectMake(LeftMargin, (self.contentView.height - IconHEight) / 2, IconWidth, IconHEight)];
        self.fileIcon.image = [UIImage imageNamed:@"workfile_icon"];
        [self.contentView addSubview:self.fileIcon];
        
        _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.fileIcon.right + Icon_PathLabel_Padding, (self.contentView.height - filePathLabelHeight) / 2, filePathLabelWidth, filePathLabelHeight)];
        _fileNameLabel.font = [UIFont systemFontOfSize:12.0];
        self.fileNameLabel.backgroundColor = [UIColor clearColor];
        self.fileNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self.contentView addSubview:self.fileNameLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TimeLabelLeft, (self.contentView.height - TimeLabelHeight) / 2, TimeLabelWidth, TimeLabelHeight)];
        self.timeLabel.font = [UIFont systemFontOfSize:10.0];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self.contentView addSubview:self.timeLabel];
        
        UIImageView *seperator = [[[UIImageView alloc] initWithFrame:CGRectMake(0, self.contentView.height - 1.0, self.contentView.width, 1.0)] autorelease];
        seperator.image = [[UIImage imageNamed:@"workfile_footbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)];
        [self.contentView addSubview:seperator];

        
        self.checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.checkBox.bounds = CGRectMake(0, 0, 26.0, 26.0);
        self.checkBox.bounds = CGRectMake(0, 0, 40.0, 40.0);
        [self setCheckBoxImage:@"check" selectedImage:@"checked"];
        [self.checkBox addTarget:self action:@selector(checkBoxClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.editingAccessoryView = self.checkBox;
    }
    return self;
}

- (void)checkBoxClicked:(id)sender
{
    self.checkBox.selected = !self.checkBox.selected;
    self.isSelected = self.checkBox.isSelected;
    
    if(self.accessoryActionBlock)
    {
        self.accessoryActionBlock(self.isSelected);
    }
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    self.checkBox.selected = self.isSelected;
}

- (void)setCheckBoxImage:(NSString *)check selectedImage:(NSString *)checked
{
    [self.checkBox setImage:[UIImage imageNamed:check] forState:UIControlStateNormal];
    [self.checkBox setImage:[UIImage imageNamed:checked] forState:UIControlStateSelected];
}

- (void)setFileName:(NSString *)fileName time:(NSString *)time
{
    self.fileName = fileName;
    self.timeStr = time;
    
    self.fileNameLabel.text = self.fileName;
    self.timeLabel.text = self.timeStr;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.stateMask == UITableViewCellStateEditingMask)
    {
        self.contentView.frame = self.contentView.bounds;
        //NSLog(@"%f,%f",self.editingAccessoryView.left,self.editingAccessoryView.top);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    self.stateMask = state;
    
    [super willTransitionToState:state];
}

@end
