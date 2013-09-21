//
//  GOInfoInputView.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-25.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOInfoInputView.h"
#import "PPCoreMacros.h"
#import "PPCore.h"
#import <QuartzCore/QuartzCore.h>

#define LABEL_HEIGHT 15.0

@implementation GOInfoInputView

- (void)dealloc
{
    PP_RELEASE(_textField);
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _textField = [[UITextField alloc] initWithFrame:self.bounds];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame fieldName:(NSString *)name;
{
    if (self = [self initWithFrame:frame]) {
        UILabel *nameLabel = nil;
        if (name) {
            CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:14.0]];
            CGFloat labelWidth = 60 > nameSize.width ? 60 : nameSize.width + 5;
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.5 * (frame.size.height - LABEL_HEIGHT), labelWidth, LABEL_HEIGHT)];
            nameLabel.font = [UIFont systemFontOfSize:14.0];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.text = name;
            nameLabel.textColor = UICOLOR_RGB(112.0, 112.0, 112.0);
            nameLabel.textAlignment = NSTextAlignmentLeft;
            [self addSubview:nameLabel];
            [nameLabel release];
            self.textField.frame = CGRectMake(CGRectGetWidth(nameLabel.frame) + 10.0, 0.0, CGRectGetWidth(self.textField.frame) - CGRectGetWidth(nameLabel.frame) - 10.0, CGRectGetHeight(self.bounds));
            self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			
            [self addSubview:self.textField];
            self.userInteractionEnabled = YES;
        }
    }
    
    return self;
}

- (void)setCornerDirection:(UIRectCorner)direction
{
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:direction
                                                         cornerRadii:CGSizeMake(5.0, 5.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    self.layer.mask = maskLayer;
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
