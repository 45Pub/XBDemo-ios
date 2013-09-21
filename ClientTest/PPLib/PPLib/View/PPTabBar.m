//
//  PPTabBar.m
//  PPLibTest
//
//  Created by Paul Wang on 12-6-18.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PPTabBar.h"
#import "PPCore.h"
#import "PPTab.h"

@implementation PPTabBar
@synthesize itemArray = _itemArray;
@synthesize backgroundView = _backgroundView;
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray
{
	return [self initWithFrame:frame buttonImages:imageArray backgroundImage:nil];
}


- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray backgroundImage:(UIImage *)backgroundImage
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		_backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor  clearColor];
		_backgroundView.image = backgroundImage;
		[self addSubview:_backgroundView];
		
		self.itemArray = [NSMutableArray arrayWithCapacity:[imageArray count]];
		PPTab *ptab;
        CGFloat total = 0;
        for(NSDictionary *dic in imageArray)
        {
            UIImage *dfImg = [dic objectForKey:@"Default"];
            total += dfImg.size.width;
        }
        
//		CGFloat width = self.bounds.size.width / [imageArray count];
        CGFloat pading = (320.0f-total)/2.0f;
        CGFloat startPos = pading;
		for (int i = 0; i < [imageArray count]; i++)
		{
            UIImage *dfImg = [[imageArray objectAtIndex:i] objectForKey:@"Default"];
            CGFloat dfh = dfImg.size.height;
            ptab = [[PPTab alloc]initWithFrame:CGRectMake(startPos, self.bounds.size.height - dfh , dfImg.size.width, dfh)];
            startPos += dfImg.size.width;
            ptab.adjustsImageWhenHighlighted = NO;
            ptab.tag = 200+i;
            [ptab setImage:dfImg forState:UIControlStateNormal];
            [ptab setImage:[[imageArray objectAtIndex:i] objectForKey:@"Highlighted"] forState:UIControlStateHighlighted]; 
            [ptab setImage:[[imageArray objectAtIndex:i] objectForKey:@"Seleted"] forState:UIControlStateSelected];
            [ptab addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.itemArray addObject:ptab];
            [self addSubview:ptab];
        }
	[self selectTabAtIndex:0];
self.curIndex = 0;
    }
    return self;
}



- (void)dealloc
{
    delegate = nil;
    PP_RELEASE(_itemArray);
    PP_RELEASE(_backgroundView);
    [super dealloc];
}

- (void)selectTabAtIndex:(NSInteger)index
{
	for (int i = 0; i < [self.itemArray count]; i++)
	{
		PPTab *b = [self.itemArray objectAtIndex:i];
		b.selected = NO;
		b.userInteractionEnabled = YES;
	}
	PPTab *btn = [self.itemArray objectAtIndex:index];
	btn.selected = YES;
	btn.userInteractionEnabled = NO;
}


- (void)tabBarButtonClicked:(id)sender
{
    PPTab *btn = sender;
    int idx = btn.tag - 200;
	[self selectTabAtIndex:idx];
	self.curIndex = idx;
    if ([delegate respondsToSelector:@selector(tabBar:didSelectIndex:)])
    {
        [delegate tabBar:self didSelectIndex:idx];
    }
}

- (void)updateBadgeNum:(NSInteger)badgeNum atIndex:(NSInteger)index
{
    if(index < [self.itemArray count] && index >= 0)
    {
        PPTab *btn = [self.itemArray objectAtIndex:index];
        [btn updateBadege:badgeNum];
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
