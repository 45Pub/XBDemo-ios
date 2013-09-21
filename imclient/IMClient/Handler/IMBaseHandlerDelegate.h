//
//  IMBaseHandlerDelegate.h
//  IMClient
//
//  Created by pengjay on 13-7-10.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMBaseHandlerDelegate <NSObject>
@optional

- (void)freshTableView;
- (UITableViewCell *)configureTableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
										obj:(id)obj;
- (void)selectedWithObj:(id)obj;
@end
