//
//  GOSelectedBar.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-8.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOSelectedBar.h"
#import "UIButton+PPCategory.h"
#import "UIView+PPCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "UIHelper.h"
//#import "GOOrgCache.h"
#import <IMUser.h>
#import "UIButton+WebCache.h"

#define SCROLLVIEW_WIDTH 238.0
#define SCROLLVIEW_HEIGHT 37.5

#define BAR_LEFT_MARGIN 4.0
#define BAR_RIGHT_MARGIN 6.5

#define THUMBNAIL_LENGTH 37.5
#define THUMBNAIL_PADDING 4.0

NSString *GOSelectedBarItemDidDeselectNotification = @"GOSelectedBarItemDidDeselectNotification";

@interface GOSelectedBar ()

@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *blankThumbnail;

@property (nonatomic, retain) NSMutableArray *identifiersArray;
@property (nonatomic, retain) NSMutableArray *thumbnailButtonsArray;

@end

@implementation GOSelectedBar

- (void)dealloc
{
    [_doneButton release];
    [_scrollView release];
    [_blankThumbnail release];
    [_identifiersArray release];
    [_thumbnailButtonsArray release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isCountGRP = NO;
        
        _identifiersArray = [[NSMutableArray alloc] init];
        _thumbnailButtonsArray = [[NSMutableArray alloc] init];
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundView.image = [[UIImage imageNamed:@"msg_bar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 0.0, -10.0, 0.0)];
        [self addSubview:backgroundView];
        [backgroundView release];
        
        self.doneButton = [UIHelper blueBtnWithTitle:nil target:nil action:nil];
        self.doneButton.bounds = CGRectMake(0.0, 0.0, 60.0, 33.0);
        self.doneButton.center = CGPointMake(self.width - 0.5 * self.doneButton.width - BAR_RIGHT_MARGIN, self.height * 0.5);
        [self setDoneButtonTitle];
        
        _scrollView = [[UIScrollView alloc] init];
        self.scrollView.bounds = CGRectMake(0.0, 0.0, 238.0, 37.5);
        self.scrollView.center = CGPointMake(BAR_LEFT_MARGIN + self.scrollView.width * 0.5, self.height * 0.5);
        self.scrollView.alwaysBounceVertical = NO;
        
        _blankThumbnail = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, THUMBNAIL_LENGTH, THUMBNAIL_LENGTH)];
        self.blankThumbnail.backgroundColor = [UIColor grayColor];
        self.blankThumbnail.layer.masksToBounds = NO;
        self.blankThumbnail.layer.cornerRadius = 4.0;
        
        [self addSubview:self.doneButton];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.blankThumbnail];
        // blankView is alwasy in thumbnailButtonsArray
        [self.thumbnailButtonsArray addObject:self.blankThumbnail];
        
        [self refreshScrollViewContentSize];
    }
    return self;
}

+ (CGSize)imageButtonSize
{
    return CGSizeMake(THUMBNAIL_LENGTH, THUMBNAIL_LENGTH);
}

#pragma mark - Private Helper

- (CGPoint)_centerOfThumbnailAtIndex:(NSUInteger)index
{
    CGFloat originX = index * (THUMBNAIL_LENGTH + THUMBNAIL_PADDING);
    
    return CGPointMake(originX + 0.5 * THUMBNAIL_LENGTH, self.scrollView.height * 0.5);
}

- (void)refreshScrollViewContentSize
{
    CGFloat contentWidth = self.thumbnailButtonsArray.count * (THUMBNAIL_LENGTH + THUMBNAIL_PADDING);
    
    self.scrollView.alwaysBounceHorizontal = (contentWidth > self.scrollView.width);
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.scrollView.height);
}

- (void)setNeedsScroll
{
    CGFloat nOffsetX = self.scrollView.contentSize.width - self.scrollView.width;
    nOffsetX = (nOffsetX > 0.0) ? nOffsetX : 0.0;
    [self.scrollView setContentOffset:CGPointMake(nOffsetX, 0.0) animated:YES];
}

- (void)setDoneButtonTitle
{
    __block NSInteger count = 0;
    
    if (self.isCountGRP)
    {
        count = self.identifiersArray.count;
    }
    else
    {
//        NSArray *array = [[[[GOOrgCache sharedOrgCache] checkedUsers] copy] autorelease];
//        [array enumerateObjectsUsingBlock:^(IMUser *u, NSUInteger idx, BOOL *stop) {
//            if (u.userType == IMUserTypeP2P) {
//                count++;
//            };
//        }];
		 count = self.identifiersArray.count;
    }
    
    NSString *done = @"确认";
    if (self.identifiersArray.count)
        done = [NSString stringWithFormat:@"%@(%d)", done, count];
    
    [self.doneButton setTitle:done forState:UIControlStateNormal];
}



- (void)thumnailBtnTapped:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GOSelectedBarItemDidDeselectNotification object:self userInfo:@{@"delete": self.identifiersArray[sender.tag]}];
    [self deleteItemWithID:self.identifiersArray[sender.tag]];
}

- (UIButton *)thumnailButtonWithImage:(UIImage *)image
{
    // TODO: clip a rounded rect effect on image.
    UIButton *thumbnailBtn = [UIButton buttonWithFrame:CGRectMake(0.0, 0.0, THUMBNAIL_LENGTH, THUMBNAIL_LENGTH) image:image];
    [thumbnailBtn setImage:image forState:UIControlStateNormal];
    thumbnailBtn.alpha = 0.0;
    thumbnailBtn.opaque = NO;
    thumbnailBtn.center = [self _centerOfThumbnailAtIndex:self.identifiersArray.count];
    thumbnailBtn.tag = self.identifiersArray.count;
    thumbnailBtn.layer.masksToBounds = YES;
    thumbnailBtn.layer.cornerRadius = 4.0;
    [thumbnailBtn addTarget:self action:@selector(thumnailBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return thumbnailBtn;
}

#pragma mark - Public Methods

- (BOOL)isUserSelectedWithID:(NSString *)identifier
{
    for (NSString *userID in _identifiersArray) {
        if ([identifier isEqualToString:userID]) {
            return YES;
        };
    }
    return NO;
}

- (void)appendItemWithURL:(NSURL *)url withID:(NSString *)identifier
{
    UIButton *thumbnailBtn = [self thumnailButtonWithImage:nil];
	[thumbnailBtn setImageWithURL:url];
    
    [self.scrollView addSubview:thumbnailBtn];
    
    [UIView animateWithDuration:APPEND_ANIMATION_DURATION animations:^{
        thumbnailBtn.alpha = 1.0;
        self.blankThumbnail.center = [self _centerOfThumbnailAtIndex:self.thumbnailButtonsArray.count];
    }];
    
    [self.thumbnailButtonsArray insertObject:thumbnailBtn atIndex:self.thumbnailButtonsArray.count - 1];
    [self.identifiersArray addObject:identifier];
    
    [self refreshScrollViewContentSize];
    [self setNeedsScroll];
    [self setDoneButtonTitle];
}


- (void)appendItemWithImage:(UIImage *)image withID:(NSString *)identifier
{
    UIButton *thumbnailBtn = [self thumnailButtonWithImage:image];
    
    [self.scrollView addSubview:thumbnailBtn];
    
    [UIView animateWithDuration:APPEND_ANIMATION_DURATION animations:^{
        thumbnailBtn.alpha = 1.0;
        self.blankThumbnail.center = [self _centerOfThumbnailAtIndex:self.thumbnailButtonsArray.count];
    }];
    
    [self.thumbnailButtonsArray insertObject:thumbnailBtn atIndex:self.thumbnailButtonsArray.count - 1];
    [self.identifiersArray addObject:identifier];
    
    [self refreshScrollViewContentSize];
    [self setNeedsScroll];
    [self setDoneButtonTitle];
}

- (void)deleteItemWithID:(NSString *)identifier
{
    __block NSInteger resultIdx = -1;
    [self.identifiersArray enumerateObjectsUsingBlock:^(NSString *idInArray, NSUInteger idx, BOOL *stop){
        if ([idInArray isEqualToString:identifier]) {
            resultIdx = idx;
            *stop = YES;
        }
    }];
    
    if (resultIdx < 0) return;
    
    UIButton *thumbnailBtn = self.thumbnailButtonsArray[resultIdx];
    
    [UIView animateWithDuration:APPEND_ANIMATION_DURATION animations:^{
        thumbnailBtn.alpha = 0.0;
        // move every btn after thumbnail a unit length. (blankView included)
        for (NSUInteger i = resultIdx + 1; i < self.thumbnailButtonsArray.count; i++) {
            UIView *b = self.thumbnailButtonsArray[i];
            b.center = [self _centerOfThumbnailAtIndex:i - 1];
            b.tag = i - 1;
        }
    } completion:^(BOOL finished){
        [thumbnailBtn removeFromSuperview];
        [self refreshScrollViewContentSize];
        [self setNeedsScroll];
    }];
    
    [self.thumbnailButtonsArray removeObjectAtIndex:resultIdx];
    [self.identifiersArray removeObjectAtIndex:resultIdx];
    [self setDoneButtonTitle];
}

- (void)setDoneTarget:(id)target action:(SEL)selector
{
    [self.doneButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
