//
//  IMConfiguration.h
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMDefaultConfigurator.h"
@interface IMConfiguration : NSObject
@property (nonatomic, strong, readonly) IMDefaultConfigurator *configurator;
+ (IMConfiguration *)sharedInstance;
+ (IMConfiguration *)sharedInstanceWithConfigurator:(IMDefaultConfigurator *)configurator;
@end
