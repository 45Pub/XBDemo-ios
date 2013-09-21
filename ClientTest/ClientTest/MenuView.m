//
//  MenuView.m
//  DoctorChat
//
//  Created by 王鹏 on 13-2-5.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "MenuView.h"
#import "UIView+PPCategory.h"
@implementation MenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self setBackgroundImage:[UIImage imageNamed:@"msg_more_bg.png"]];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setBackgroundImage:[UIImage imageNamed:@"msg_more_camera.png"] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
		btn.frame = CGRectMake(20*2+58, 15, 57, 58);
		[self addSubview:btn];
		
		UILabel *label = [[UILabel alloc]init];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = [UIColor whiteColor];
		label.text = NSLocalizedString(@"拍摄", nil);
		[label sizeToFit];
		label.top = btn.bottom + 6;
		label.left = btn.left + (btn.width - label.width)/2;
		[self addSubview:label];
		[label release];
		
		btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setBackgroundImage:[UIImage imageNamed:@"msg_more_photo.png"] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(openPhoto:) forControlEvents:UIControlEventTouchUpInside];
		btn.frame = CGRectMake(20, 15, 57, 58);
		[self addSubview:btn];
		label = [[UILabel alloc]init];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = [UIColor whiteColor];
		label.text = NSLocalizedString(@"照片", nil);
		[label sizeToFit];
		label.top = btn.bottom + 6;
		label.left = btn.left + (btn.width - label.width)/2;
		[self addSubview:label];
		[label release];
		
		btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setBackgroundImage:[UIImage imageNamed:@"msg_more_files.png"] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(openFiles:) forControlEvents:UIControlEventTouchUpInside];
		btn.frame = CGRectMake(20*3+58*2, 15, 57, 58);
		[self addSubview:btn];
		label = [[UILabel alloc]init];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = [UIColor whiteColor];
		label.text = NSLocalizedString(@"文件", nil);
		[label sizeToFit];
		label.top = btn.bottom + 6;
		label.left = btn.left + (btn.width - label.width)/2;
		[self addSubview:label];
		[label release];
    }
    return self;
}

- (void)openPhoto:(id)sender
{
	if(_delegate && [_delegate respondsToSelector:@selector(menuViewSelectedPhoto:)])
	{
		[_delegate menuViewSelectedPhoto:self];
	}
}

- (void)openCamera:(id)sender
{
	if(_delegate && [_delegate respondsToSelector:@selector(menuViewSelectedCamera:)])
	{
		[_delegate menuViewSelectedCamera:self];
	}
}

- (void)openFiles:(id)sender
{
	if (_delegate && [_delegate respondsToSelector:@selector(menuViewSelectedFiles:)])
	{
		[_delegate menuViewSelectedFiles:self];
	}
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
