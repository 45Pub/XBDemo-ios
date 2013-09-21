//
//  LeftButton.m
//  ClientTest
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "LeftButton.h"

@implementation LeftButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
	frame.origin.x -= 5;
	[super setFrame:frame];
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
