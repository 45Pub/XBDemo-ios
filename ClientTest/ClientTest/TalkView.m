//
//  TalkView.m
//  lty
//
//  Created by Paul Wang on 12-6-27.
//  Copyright (c) 2012年 pjsoft. All rights reserved.
//

#import "TalkView.h"
#import "UIView+PPCategory.h"

@implementation TalkView
@synthesize tstat;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f];
    }
    return self;
}

- (void)setTstat:(TALKVIEWSTAT)t
{
    tstat = t;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage *img;
    if(tstat == TALKVIEWSTATSTART)
    {
        img = [UIImage imageNamed:@"tips_start.png"];
    }
    else if(tstat == TALKVIEWSTATNOMIC)
    {
//        img = [UIImage imageNamed:@"talknomic.png"];
        return;
    }
    else if(tstat == TALKVIEWSTATDELETE)
    {
        img = [UIImage imageNamed:@"tips_cancel.png"];
 
    }
    else if(tstat == TALKVIEWSTATTOOSHORT)
    {
        img = [UIImage imageNamed:@"tips_shortage.png"];
    }
	else
	{
		[super drawRect:rect];
		return;
	}
    CGFloat sx = (self.width - img.size.width)/2;
    CGFloat sy = (self.height - img.size.height)/2;
    
    [img drawAtPoint:CGPointMake(sx, sy)];
}


//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *tch = [touches anyObject];
//    CGPoint p = [tch locationInView:self];
//    NSLog(@"%@", NSStringFromCGPoint(p));
//    
//}


@end
