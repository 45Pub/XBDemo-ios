//
//  IMMsgBaseHandler.m
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMMsgObserveHandler.h"
#import "DDLog.h"
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation IMMsgObserveHandler

- (id)initWithMsg:(IMMsg *)msg keyPath:(NSString *)keyPath compeletedBolck:(IMMsgObserveCompeletedBlock )block
{
	self = [super init];
	if (self) {
		_curMsg = msg;
		_block = block;
		_keyPath = keyPath;
		_isObserved = NO;
	}
	return self;
}

- (void)dealloc
{
	[self removeObserver];
	DDLogVerbose(@"%@:%@ dealloc!", NSStringFromClass([self class]), _keyPath);
}

- (void)addObserver
{
	if (_isObserved == NO) {
		_isObserved = YES;
		[_curMsg addObserver:self forKeyPath:_keyPath
					 options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
	
	}
}

- (void)removeObserver
{
	@synchronized(self) {
		if (_isObserved) {
			_isObserved = NO;
			[_curMsg removeObserver:self forKeyPath:_keyPath];
		}
	}
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:_keyPath]) {
		NSNumber *n = [change objectForKey:NSKeyValueChangeNewKey];
		NSNumber *o = [change objectForKey:NSKeyValueChangeOldKey];
		if (_block) {
			_block(self, _curMsg, n, o);
		}
	}
}
@end
