//
//  IMBgButton.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMBgButton.h"

@implementation IMBgButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	//	[self.nextResponder touchesBegan:touches withEvent:event];
	[self setHighlighted:YES];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	//	[self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	//	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	[self setHighlighted:NO];
	//	[self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	[self setHighlighted:NO];
	//	[self.nextResponder touchesCancelled:touches withEvent:event];
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
