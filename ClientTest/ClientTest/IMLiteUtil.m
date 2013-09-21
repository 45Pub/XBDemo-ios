//
//  IMLiteUtil.m
//  IMLite
//
//  Created by pengjay on 13-7-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMLiteUtil.h"
#import "NSDate+PPCategory.h"
#import "PPCore.h"
@implementation IMLiteUtil
+ (NSString *)getChatTimeLabelWithDate:(NSDate *)date
{
	NSString *timestr = nil;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	if([date isToday])
	{
		[dateFormatter setDateFormat:@"今日 HH:mm"];
        timestr = [dateFormatter stringFromDate:date];
	}
	else
	{
		
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        timestr = [dateFormatter stringFromDate:date];
	}
	[dateFormatter release];
	return timestr;
}

+ (NSString *)getTimeStrWithDate:(NSDate *)date
{
	if (date == nil)
	{
		return @"";
	}
	NSString *timestr = nil;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	if([date isToday])
	{
		[dateFormatter setDateFormat:@"HH:mm"];
        timestr = [dateFormatter stringFromDate:date];
	}
	else
	{
		
        [dateFormatter setDateFormat:@"M-d"];
        timestr = [dateFormatter stringFromDate:date];
	}
	[dateFormatter release];
	return timestr;
}

+ (NSString *)presentationalFileSizeWithSize:(unsigned long long)fileSize
{
    double divider = 1024.0;
    double calculatedSize = (double)fileSize;
    
    if (calculatedSize < 800) {
        return [NSString stringWithFormat:@"%.2fB", calculatedSize];
    }
    else if (calculatedSize < 800 * divider) {
        return [NSString stringWithFormat:@"%.2fKB", calculatedSize / divider];
    }
    else if (calculatedSize < 800 * divider * divider) {
        return [NSString stringWithFormat:@"%.2fMB", calculatedSize / (divider * divider)];
    }
    else if (calculatedSize < 800 * divider * divider * divider) {
        return [NSString stringWithFormat:@"%.2fGB", calculatedSize / (divider * divider * divider)];
    }
    else
        return @"未知大小";
}
@end
