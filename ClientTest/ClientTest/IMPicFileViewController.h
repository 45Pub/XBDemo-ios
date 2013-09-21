//
//  IMPicFileViewController.h
//  GoComIM
//
//  Created by 王鹏 on 13-5-24.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOBaseViewController.h"
#import <IMFileDownloader.h>
@class IMPicMsg;
@interface IMPicFileViewController : GOBaseViewController
{
	BOOL isObserve;
}
@property (nonatomic, retain) IMPicMsg *picMsg;
@end
