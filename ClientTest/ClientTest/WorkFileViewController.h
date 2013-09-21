//
//  WorkFileViewController.h
//  IMLite
//
//  Created by admins on 13-7-24.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOPlainTableViewController.h"

typedef NS_ENUM(NSInteger, fileKind)
{
    fileKindReceieve = 0,
    fileKindMySend = 1
};

@protocol WorkFileViewDelegate;
@interface WorkFileViewController : GOPlainTableViewController

@property (nonatomic, retain) NSMutableArray *selectedFilePaths;

@property (nonatomic, assign) id<WorkFileViewDelegate> delegate;

@end

@protocol WorkFileViewDelegate<NSObject>

- (void)workFilesDidSelected:(WorkFileViewController *)wfController withFiles:(NSArray *)files;

@end
