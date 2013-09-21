//
//  UINavigationBar+PPCategory.m
//  PPLibTest
//
//  Created by 王鹏 on 13-3-14.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "UINavigationBar+PPCategory.h"
#import "PPCore.h"
#import <QuartzCore/QuartzCore.h>
@implementation UINavigationBar (PPCategory)
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
	if(PPIOSVersion() >= 4.9)
	{
		[self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
	}
	else
	{
		self.layer.contents = (id)[backgroundImage CGImage];
	}
	[self setNeedsDisplay];
}
@end
