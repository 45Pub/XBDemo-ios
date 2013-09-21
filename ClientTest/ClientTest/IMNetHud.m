//
//  IMNetHud.m
//  DoctorChat
//
//  Created by 王鹏 on 13-3-8.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMNetHud.h"
#import <QuartzCore/QuartzCore.h>
#import "PPCore.h"
@implementation IMNetHud

- (id)initWithFrame:(CGRect)frame
{

        // Initialization code
		self = [super initWithFrame:frame];
		if (self) {
			// Initialization code
			self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f];
			self.bounds = CGRectMake(0, 0, 280, 45);
			self.layer.cornerRadius = 3.0f;
			self.layer.masksToBounds = YES;
			
			UIImageView *imgv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"roomgantanhao.png"]];
			imgv.frame = CGRectMake(10, 9, 34, 30);
			[self addSubview:imgv];
			[imgv release];
			
			_textLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 8, 220, 15)];
			_textLabel.font = [UIFont systemFontOfSize:14.0f];
			_textLabel.textColor = UICOLOR_RGB(255, 249, 140);
			_textLabel.shadowColor = UICOLOR_RGB(16, 39, 0);
//			_textLabel.shadowOffset = SHOUYESHADOWRECT;
			_textLabel.backgroundColor = [UIColor clearColor];
			[self addSubview:_textLabel];
			
			_detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 26, 220, 14)];
			_detailLabel.backgroundColor = [UIColor  clearColor];
			_detailLabel.font = [UIFont systemFontOfSize:14.0f];
			_detailLabel.textColor = UICOLOR_RGB(255, 249, 140);
			_detailLabel.shadowColor = UICOLOR_RGB(16, 39, 0);
//			detailLabel.shadowOffset = SHOUYESHADOWRECT;
			[self addSubview:_detailLabel];
    }
    return self;
}

- (void)dealloc
{
    [_textLabel release];
    [_detailLabel release];
    [super dealloc];
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
