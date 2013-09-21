//
//  IMConfiguration.m
//  IMClient
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMConfiguration.h"
static IMConfiguration *sharedInstance = nil;
@implementation IMConfiguration

+ (IMConfiguration *)sharedInstance
{
	@synchronized(self)
	{
		if (sharedInstance == nil) {
			[NSException raise:@"IMConfigException" format:@"you must configure first!"];
		}
	}
	return sharedInstance;
}

+ (IMConfiguration *)sharedInstanceWithConfigurator:(IMDefaultConfigurator *)configurator
{
	@synchronized(self)
	{
		if (sharedInstance != nil) {
			[NSException raise:@"IMconfigException" format:@"already configured!"];
		}
		sharedInstance = [[IMConfiguration alloc]initWithConfigurator:configurator];
	}
	return sharedInstance;
}

- (id)initWithConfigurator:(IMDefaultConfigurator *)config
{
	self = [super init];
	if (self) {
		_configurator = config;
	}
	return self;
}
@end
