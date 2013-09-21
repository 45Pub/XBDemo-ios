//
//  IMChatSessionHandler.m
//  IMClient
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMChatSessionHandler.h"

@implementation IMChatSessionHandler

- (instancetype)init
{
	self = [super init];
	if (self) {
		_sessionArray = [NSMutableArray array];
	}
	return self;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IMSessionDelegate
- (void)imChatSessionDidChanged:(IMChatSessionManager *)mgr sessions:(NSArray *)sessions unreadNum:(NSUInteger)unreadNum
{
	
	if (sessions == nil)
		return;
	
	_sessionArray = [NSMutableArray arrayWithArray:sessions];
	
	if ([self.delegate respondsToSelector:@selector(freshTableView)]) {
		[self.delegate freshTableView];
	}
}


#pragma makr - UItableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_sessionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	if (indexPath.row < _sessionArray.count) {
		id obj = [_sessionArray objectAtIndex:indexPath.row];
		if ([self.delegate respondsToSelector:@selector(configureTableViewCell:indexPath:obj:)]) {
			cell = [self.delegate configureTableViewCell:tableView indexPath:indexPath obj:obj];
		}
		else {
			cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
		}
	}
	else if (cell == nil) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.delegate respondsToSelector:@selector(selectedWithObj:)]) {
		[self.delegate selectedWithObj:[_sessionArray objectAtIndex:indexPath.row]];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

@end
