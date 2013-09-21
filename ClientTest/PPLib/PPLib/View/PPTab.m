//
//  PPTab.m
//  PPLibTest
//
//  Created by Paul Wang on 12-6-18.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PPTab.h"
#import "PPCore.h"
#import "UIView+PPCategory.h"

#define kPPTABMAXBADGENUM 99
@implementation PPTab
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    PP_RELEASE(_badge);
    [super dealloc];
}

- (void)updateBadege:(int)badgeNumber
{
    if(badgeNumber > 0)
    {
        if(!_badge)
        {
            _badge = [[PPBadgeView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            _badge.userInteractionEnabled = NO;
            _badge.badgeColor = [UIColor redColor];
            [self addSubview:_badge];
        }
        
        NSString *bdstr;
        if(badgeNumber > kPPTABMAXBADGENUM)
        {
            bdstr = [NSString stringWithFormat:@"%d+", kPPTABMAXBADGENUM];
        }
        else 
        {
            bdstr = [NSString stringWithFormat:@"%d", badgeNumber];
        }
        _badge.badgeString = bdstr;
        [_badge sizeToFit];
        _badge.frame = CGRectMake(self.width - _badge.width - 1, 1, _badge.width, _badge.height);
        _badge.hidden = NO;
    }
    else
    {
        _badge.badgeString = nil;
        _badge.hidden = YES;
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
