//
//  StackedLevelViewController.m
//  IMLite
//
//  Created by Ethan on 13-8-21.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "StackedLevelViewController.h"

#define LEFT_VC_HIDE CGRectMake(-125.0, 0, 125.0, self.view.frame.size.height)
#define RIGHT_VC_HIDE CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width-125.0, self.view.frame.size.height)

#define LEFT_VC_FRAME CGRectMake(0, 0, 125.0, self.view.frame.size.height)
#define ROOT_VC_FRAME CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)

#define RIGHT_VC_FRAME CGRectMake(125.0, 0, self.view.frame.size.width-125.0, self.view.frame.size.height)
#define RIGHT_VC_READY_FRAME CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width-125.0, self.view.frame.size.height)

@interface StackedLevelViewController ()

@property (nonatomic, retain) NSMutableArray *stackVCArray;
@property (nonatomic, retain) NSMutableArray *shadowStackArray;

@property (nonatomic, retain) UIViewController *leftViewController;
@property (nonatomic, retain) UIViewController *rightViewController;

@property (nonatomic, assign) BOOL isStacking;


@end

@implementation StackedLevelViewController

- (void)dealloc {
    
    self.stackVCArray = nil;
    self.rightViewController = nil;
    self.leftViewController = nil;
    self.shadowStackArray = nil;
    
    [super dealloc];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithRootViewController:(UIViewController*)viewController withFrame:(CGRect)frame {
    
    self = [super init];
    if (self) {
        
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.rightViewController = viewController;
        self.rightViewController.view.frame = ROOT_VC_FRAME;
        
        self.shadowStackArray = [NSMutableArray array];
        
        self.stackVCArray = [NSMutableArray array];
        [self.stackVCArray addObject:self.rightViewController];
        [self addChildViewController:self.rightViewController];
        
        [self.view addSubview:self.rightViewController.view];

    }
    return self;
    
}

- (void)popToRootViewController {
    while (self.stackVCArray.count != 1) {
        UIViewController *viewController = [self.stackVCArray lastObject];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        [self.stackVCArray removeLastObject];
    }
    
    self.rightViewController = [self.stackVCArray lastObject];
    self.rightViewController.view.frame = ROOT_VC_FRAME;
    if (![self.view.subviews containsObject:self.rightViewController.view]) {
        [self addChildViewController:self.rightViewController];
        [self.view addSubview:self.rightViewController.view];
    }
    while (self.shadowStackArray.count != 0) {
        UIImageView *shadowView = [self.shadowStackArray lastObject];
        [shadowView removeFromSuperview];
        [self.shadowStackArray removeObject:shadowView];
    }
    
    self.leftViewController = nil;
    
}

- (void)pushStackViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.isStacking) {
        return;
    }
    
    UIImageView *shadowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"multilevel_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 3.5, 15.0, 3.5)]];
    shadowView.frame = CGRectMake(self.rightViewController.view.frame.size.width-7, -self.rightViewController.view.frame.size.height, 7, self.rightViewController.view.frame.size.height*3);
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.rightViewController.view addSubview:shadowView];
    [self.shadowStackArray addObject:shadowView];
    [shadowView release];
    
    __block UIViewController *tempLeft = self.leftViewController;
    
    viewController.view.frame = RIGHT_VC_READY_FRAME;
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    
    __block typeof(self) weakSelf = self;
    
    void (^animationBlock)(void) = ^{
        weakSelf.isStacking = YES;
                
        weakSelf.leftViewController.view.frame = LEFT_VC_HIDE;
        weakSelf.rightViewController.view.frame = LEFT_VC_FRAME;
        viewController.view.frame = RIGHT_VC_FRAME;
    };
    
    void (^completeBlock)(BOOL) = ^(BOOL finished){
        weakSelf.leftViewController = [weakSelf.stackVCArray lastObject
                                       ];
        [weakSelf.stackVCArray addObject:viewController];
        
        weakSelf.rightViewController = [weakSelf.stackVCArray lastObject];
        
        [tempLeft.view removeFromSuperview];
        
        [tempLeft removeFromParentViewController];
        
        weakSelf.isStacking = NO;
        
        if ([weakSelf.delegate respondsToSelector:@selector(stackedLevelViewControllerFinishedPush:)]) {
            [weakSelf.delegate stackedLevelViewControllerFinishedPush:self];
        }
        

    };
    
    if ([self.delegate respondsToSelector:@selector(stackedLevelViewControllerBeginPush:)]) {
        [self.delegate stackedLevelViewControllerBeginPush:self];
    }
    if (animated) {
        [UIView animateWithDuration:0.2f animations:animationBlock completion:completeBlock];
    } else {
        animationBlock();
        completeBlock(YES);
    }
    
    Block_release(animationBlock);
    Block_release(completeBlock);
    
}

- (void)popViewControllerAnimated:(BOOL)animated {
    
    if (self.leftViewController == nil || self.isStacking) {
        return;
    }
    __block UIViewController *newLeftViewController = nil;
    if (self.stackVCArray.count >= 3) {
        newLeftViewController = (UIViewController*)[self.stackVCArray objectAtIndex:(self.stackVCArray.count-3)];
        newLeftViewController.view.frame = LEFT_VC_HIDE;
        [self addChildViewController:newLeftViewController];
        [self.view addSubview:newLeftViewController.view];
        [self.view sendSubviewToBack:newLeftViewController.view];
    }
    
    __block typeof(self) weakSelf = self;
    
    void (^animationBlock)(void) = ^{
        
        weakSelf.isStacking = YES;
        
        weakSelf.rightViewController.view.frame = RIGHT_VC_HIDE;
        
        if (newLeftViewController == nil) {
            weakSelf.leftViewController.view.frame = ROOT_VC_FRAME;
        } else {
            weakSelf.leftViewController.view.frame = RIGHT_VC_FRAME;
        }
        
        newLeftViewController.view.frame = LEFT_VC_FRAME;
    };
    
    void (^completeBlock)(BOOL) = ^(BOOL finished){
        [weakSelf.rightViewController.view removeFromSuperview];
        [weakSelf.rightViewController removeFromParentViewController];
        
        [weakSelf.stackVCArray removeLastObject];
        
        weakSelf.rightViewController = weakSelf.leftViewController;
        weakSelf.leftViewController = newLeftViewController;
        
        [[weakSelf.shadowStackArray lastObject] removeFromSuperview];
        [weakSelf.shadowStackArray removeLastObject];
        
        self.isStacking = NO;
        
        if ([weakSelf.delegate respondsToSelector:@selector(stackedLevelViewControllerFinishedPop:)]) {
            [weakSelf.delegate stackedLevelViewControllerFinishedPop:self];
        }
        

    };
    
    if ([self.delegate respondsToSelector:@selector(stackedLevelViewControllerBeginPop:)]) {
        [self.delegate stackedLevelViewControllerBeginPop:self];
    }

    if (animated) {
        [UIView animateWithDuration:0.2f animations:animationBlock completion:completeBlock];
    } else {
        animationBlock();
        completeBlock(YES);
    }
    
    Block_release(animationBlock);
    Block_release(completeBlock);
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
