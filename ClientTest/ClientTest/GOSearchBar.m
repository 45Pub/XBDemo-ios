//
//  GOSearchBar.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-7.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOSearchBar.h"

@implementation GOSearchBar


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setSearchFieldBackgroundImage:[[UIImage imageNamed:@"search_box"]resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 18.0, 15.0, 18.0)] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"search_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 30.0, 20.0)]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    

}

- (void)setCancelButton
{
    [self setShowsCancelButton:YES];
    [self setCancelButtonImage:[[UIImage imageNamed:@"btn_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 24.0, 35.0)] title:@"取消" forState:UIControlStateNormal forView:self];
}

- (void)setCancelButtonImage:(UIImage *)image title:(NSString *)title forState:(UIControlState)state forView:(UIView *)view
{
    UIButton *cancelButton = nil;
    for(UIView *subView in view.subviews){
        if([subView isKindOfClass:UIButton.class])
        {
            cancelButton = (UIButton*)subView;
        }
        else
        {
            [self setCancelButtonImage:image title:title forState:state forView:subView];
        }
    }
    
    if (cancelButton) {
        [cancelButton setBackgroundImage:image forState:state];
        [cancelButton setTitle:title forState:state];
    }
}

@end
