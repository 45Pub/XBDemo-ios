//
//  IMLiteUtil.h
//  IMLite
//
//  Created by pengjay on 13-7-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *const kGoChatViewContrllerNote = @"kGoChatViewContrllerNote";
@interface IMLiteUtil : NSObject
+ (NSString *)getChatTimeLabelWithDate:(NSDate *)date;
+ (NSString *)getTimeStrWithDate:(NSDate *)date;
+ (NSString *)presentationalFileSizeWithSize:(unsigned long long)fileSize;
@end
