//
//  FilePreviewController.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-23.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "FilePreviewController.h"
#import "UIHelper.h"
#import "UIImage+PPCategory.h"
#import "PPCoreSys.h"
#import <objc/runtime.h>

void NISwapInstanceMethods(Class cls, SEL originalSel, SEL newSel) {
	Method originalMethod = class_getInstanceMethod(cls, originalSel);
	Method newMethod = class_getInstanceMethod(cls, newSel);
	method_exchangeImplementations(originalMethod, newMethod);
}


//@implementation UINavigationBar(pp)
//- (void)mypushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated
//{
//	NSLog(@"%@", item);
//}
//@end
@implementation UINavigationItem(pp)
- (void)psetRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
	NSLog(@"Hidden:%@", item);
}

@end

@interface FilePreviewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (nonatomic, retain, readwrite) NSArray *urls;

@end

@implementation FilePreviewController

- (void)dealloc
{
//	NISwapInstanceMethods([UINavigationItem class], @selector(psetRightBarButtonItem:animated:), @selector(setRightBarButtonItem:animated:));
    [_urls release];
    
    [super dealloc];
}

- (instancetype)initWithFiles:(NSArray *)urls
{
    if (self = [super init]) {
//	NISwapInstanceMethods([UINavigationItem class], @selector(setRightBarButtonItem:animated:), @selector(psetRightBarButtonItem:animated:));
        self.urls = urls;
        self.delegate = self;
        self.dataSource = self;
        [self setCurrentPreviewItemIndex:0];
    }
    return self;
}

- (instancetype)initWithFile:(NSURL *)url
{
    return [self initWithFiles:@[url]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"返回" target:self action:@selector(navigationBack:)];

    self.navigationController.toolbarHidden = YES;
	//    if (PPIOSVersion() < 6.0) {
//	self.navigationItem.rightBarButtonItem = nil;
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.toolbarHidden = YES;
//	self.navigationItem.rightBarButtonItem = nil;
    
	[self.navigationController setNavigationBarHidden:NO];
	//    if (PPIOSVersion() >= 6.0) {
//        [self.navigationItem.rightBarButtonItem setBackgroundImage:[[UIImage imageNamed:@"nav_btn"] stretchableImageWithCapInsets:UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    }
}

- (void)navigationBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - QLPreviewControllerDataSource Methods.

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
	return self.urls.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller
                    previewItemAtIndex:(NSInteger)index {
    id<QLPreviewItem> result = self.urls[index];
    
	return result;
}

#pragma mark - QLPreviewControllerDelegate Methods

- (BOOL)previewController:(QLPreviewController *)controller
            shouldOpenURL:(NSURL *)url
           forPreviewItem:(id<QLPreviewItem>)item {
	return YES;
}

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
	//NSLog(@"Quick Look will dismiss");
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
	//NSLog(@"Quick Look did dismiss");
}

@end
