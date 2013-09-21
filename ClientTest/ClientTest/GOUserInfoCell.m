//
//  GOUserInfoCell.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOUserInfoCell.h"
#import "UIView+PPCategory.h"
#import "UIButton+PPCategory.h"

#define TITLE_LABEL_WIDTH 40.0
#define TITLE_LABEL_HEIGHT 20.0

#define FULL_INFO_LABEL_LENGTH (250.0 - self.titleLabel.width)
#define LABEL_MARGIN_TO_EDGE 10.0
#define TITLEFONT [UIFont systemFontOfSize:13.5] 
@interface GOUserInfoCell ()

@property (nonatomic, retain) UILabel *infoLabel;
@property (nonatomic, retain) UILabel *titleLabel;

@end

@implementation GOUserInfoCell

- (void)dealloc
{
    [_infoLabel release];
    [_titleLabel release];
    Block_release(_accessoryActionBlock);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc] init];
        _infoLabel = [[UILabel alloc] init];
        _infoType = GOUserInfoCellAccessoryTypeNone;
        
        self.titleLabel.font = TITLEFONT;
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.frame = CGRectMake(LABEL_MARGIN_TO_EDGE, LABEL_MARGIN_TO_EDGE * 2, TITLE_LABEL_WIDTH, TITLE_LABEL_HEIGHT);
        
        self.infoLabel.font = TITLEFONT;
        self.infoLabel.textColor = [UIColor blackColor];
        self.infoLabel.backgroundColor = [UIColor clearColor];
        self.infoLabel.baselineAdjustment = UIBaselineAdjustmentNone;
        self.infoLabel.numberOfLines = 0;
        self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.infoLabel];
    }
    return self;
}

+ (UIImage *)imageWithType:(GOUserInfoCellAccessoryType)type
{
    if (type == GOUserInfoCellAccessoryTypeMail) {
        return [UIImage imageNamed:@"btn_sentmail"];
    }
    else if (type == GOUserInfoCellAccessoryTypePhone) {
        return [UIImage imageNamed:@"btn_call"];
    }
    
    return nil;
}

- (void)accessoryButtonAction:(UIButton *)sender
{
    if(self.infoType == GOUserInfoCellAccessoryTypePhone)
    {
        UIDevice *device = [UIDevice currentDevice];
        if([[device model] isEqualToString:@"iPhone"])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.infoLabel.text]]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"你的设备不支持拨号功能" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
    else if(self.infoType == GOUserInfoCellAccessoryTypeMail)
    {
        if (self.accessoryActionBlock) {
            self.accessoryActionBlock(self.infoLabel.text);
        }
    }
}

- (void)setInfoType:(GOUserInfoCellAccessoryType)infoType
{
    _infoType = infoType;
    
    if (infoType != GOUserInfoCellAccessoryTypeNone) {
        if (self.accessoryView == nil) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[[self class] imageWithType:infoType] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(accessoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            button.frame = CGRectMake(100.0, 10.0, 30.0, 30.0);
            self.accessoryView = button;
        }
        self.infoLabel.frame = CGRectMake(2 * LABEL_MARGIN_TO_EDGE + TITLE_LABEL_WIDTH, LABEL_MARGIN_TO_EDGE, FULL_INFO_LABEL_LENGTH - self.accessoryView.width, self.contentView.height - 2 * LABEL_MARGIN_TO_EDGE);
    }
    else {
        self.infoLabel.frame = CGRectMake(2 * LABEL_MARGIN_TO_EDGE + TITLE_LABEL_WIDTH, LABEL_MARGIN_TO_EDGE, FULL_INFO_LABEL_LENGTH, self.contentView.height - 2 * LABEL_MARGIN_TO_EDGE);
    }
}

- (void)setTitle:(NSString *)titleString info:(NSString *)infoString
{
    CGSize textSize = [titleString sizeWithFont:[UIFont systemFontOfSize:13.5]];
    self.titleLabel.frame = CGRectMake(LABEL_MARGIN_TO_EDGE, LABEL_MARGIN_TO_EDGE * 2, textSize.width + 4.0, self.titleLabel.bounds.size.height);
    self.titleLabel.text = titleString;
    self.infoLabel.text = infoString;
}

- (void)setTitle:(NSString *)titleString info:(NSString *)infoString infoType:(GOUserInfoCellAccessoryType)infoType
{
	self.titleLabel.text = titleString;
	[self.titleLabel sizeToFit];
	self.titleLabel.left = LABEL_MARGIN_TO_EDGE;
	self.titleLabel.top = LABEL_MARGIN_TO_EDGE;
	
	CGFloat infoLabelMaxWidth = 300-LABEL_MARGIN_TO_EDGE*2-15-self.titleLabel.width;
	_infoType = infoType;
	if (infoType != GOUserInfoCellAccessoryTypeNone) {
        if (self.accessoryView == nil) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[[self class] imageWithType:infoType] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(accessoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            button.frame = CGRectMake(100.0, 10.0, 30.0, 30.0);
            self.accessoryView = button;
        }
		infoLabelMaxWidth -= 35;
    }
	
	CGSize infoSize = [infoString sizeWithFont:TITLEFONT constrainedToSize:CGSizeMake(infoLabelMaxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	self.infoLabel.frame = CGRectMake(self.titleLabel.right + 15, self.titleLabel.top, infoSize.width, infoSize.height);
	self.infoLabel.text = infoString;
	self.contentView.height = self.infoLabel.bottom;
}

+ (CGFloat)heightwithTitle:(NSString *)titleString InfoString:(NSString *)infoString infoType:(GOUserInfoCellAccessoryType)infoType
{
	if ([infoString length] <= 0)
	{
		return 38.0f;
	}
	CGSize textSize = [titleString sizeWithFont:TITLEFONT];
	
	CGFloat infoLabelMaxWidth = 300-LABEL_MARGIN_TO_EDGE*2-15-textSize.width;
	if (infoType != GOUserInfoCellAccessoryTypeNone) {
		infoLabelMaxWidth -=35;
	}
	CGSize infoSize = [infoString sizeWithFont:TITLEFONT constrainedToSize:CGSizeMake(infoLabelMaxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	return infoSize.height + LABEL_MARGIN_TO_EDGE * 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
        self.infoLabel.textColor = [UIColor whiteColor];
    else
        self.infoLabel.textColor = [UIColor blackColor];
}

@end
