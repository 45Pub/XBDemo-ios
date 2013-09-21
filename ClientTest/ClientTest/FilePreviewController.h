//
//  FilePreviewController.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-5-23.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface FilePreviewController : QLPreviewController

@property (nonatomic, retain, readonly) NSArray *urls;

- (instancetype)initWithFile:(NSURL *)url;

//- (instancetype)initWithFiles:(NSArray *)urls;

@end
