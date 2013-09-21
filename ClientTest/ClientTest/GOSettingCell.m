//
//  GOSettingCell.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOSettingCell.h"
#import "PPCore.h"
#import "UIView+PPCategory.h"
#import <QuartzCore/QuartzCore.h>

#define IMAGE_LENGTH 30
#define DETAIL_LABEL_HEIGHT 28.0
#define DETAIL_LABEL_WIDTH 150.0
#define ACCESSORY_DISCLOSURE_WIDTH 26.0

@interface GOSettingCell ()
@property (nonatomic, retain) UIImageView *detailImageView;
@property (nonatomic, retain) UILabel *detailLabel;
@end

@implementation GOSettingCell

- (void)dealloc
{
    PP_RELEASE(_title);
    PP_RELEASE(_detail);
    PP_RELEASE(_detailLabel);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:14.0];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

- (void)removeDetailLabelView
{
    if (self.detailLabel) {
        [self.detailLabel removeFromSuperview];
        self.detailLabel = nil;
    }
}

- (void)removeDetailImageView
{
    if (self.detailImageView) {
        [self.detailImageView removeFromSuperview];
        self.detailImageView = nil;
    }
}

- (void)removeDetailViews
{
    [self removeDetailLabelView];
    [self removeDetailImageView];
}

- (void)setDetail:(id)detail
{
    if ([detail isKindOfClass:[NSString class]]) {
        [self removeDetailImageView];
        if (self.detailLabel == nil) {
            self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(300.0 - ACCESSORY_DISCLOSURE_WIDTH - DETAIL_LABEL_WIDTH, 6.0, DETAIL_LABEL_WIDTH, DETAIL_LABEL_HEIGHT)];
            self.detailLabel.textColor = [UIColor grayColor];
            self.detailLabel.font = [UIFont systemFontOfSize:13.5];
            self.detailLabel.backgroundColor = [UIColor clearColor];
            self.detailLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:self.detailLabel];

        }
        
        self.detailLabel.text = detail;
    }
    else if ([detail isKindOfClass:[UIImage class]]) {
        [self removeDetailLabelView];
        if (self.detailImageView == nil) {
            self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(300.0 - IMAGE_LENGTH - ACCESSORY_DISCLOSURE_WIDTH, 5.0, IMAGE_LENGTH, IMAGE_LENGTH)];
			self.detailImageView.layer.cornerRadius = 3.0f;
			self.detailImageView.layer.masksToBounds = YES;
            [self.contentView addSubview:self.detailImageView];
        }
        self.detailImageView.image = detail;
    }
    else if (detail == nil) {
        [self removeDetailViews];
    }
    
    if (_detail) [_detail release];
    _detail = [detail retain];
}

- (void)setTitle:(NSString *)title
{
    self.textLabel.text = title;
    
    if (_title) [_title release];
    _title = [title copy];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        self.textLabel.textColor = [UIColor blackColor];
        self.detailLabel.textColor = [UIColor grayColor];
    }
}

@end
