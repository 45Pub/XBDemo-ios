//
//  IMTableView.m
//  DoctorChat
//
//  Created by 王鹏 on 13-3-6.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMTableView.h"

@implementation IMTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	if(self.delegate && [self.delegate respondsToSelector:@selector(tapGesture:)])
	{
		[self.delegate performSelector:@selector(tapGesture:) withObject:nil];
	}
}
@end
