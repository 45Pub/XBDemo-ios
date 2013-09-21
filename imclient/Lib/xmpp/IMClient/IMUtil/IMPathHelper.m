//
//  IMPathHelper.m
//  IMClient
//
//  Created by pengjay on 13-7-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMPathHelper.h"
#import "IMMsg.h"
#import "IMUser.h"
#import "IMContext.h"
@implementation IMPathHelper
+ (NSString *)documentDirPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if (paths.count > 0) {
		return [paths objectAtIndex:0];
	}
	NSLog(@"Get Path Error!");
	return NSTemporaryDirectory();
}

+ (BOOL)addSkipBackupAttrToPath:(NSString *)path
{
	int result = 0;
	NSURL *URL = [NSURL fileURLWithPath:path];
	NSError *error = nil;
	result = [URL setResourceValue: [NSNumber numberWithBool: YES]
							forKey: NSURLIsExcludedFromBackupKey error: &error];
	if(!result){
		NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
	}
	
	return result;
}

+ (void)createDirIfNotExsit:(NSString *)path
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
													   attributes:nil error:nil];
//			[[self class] addSkipBackupAttrToPath:path];
	}
}

+ (NSString *)userWorkBasePath:(NSString *)userID
{
	NSString *path = [[[self class] documentDirPath] stringByAppendingPathComponent:userID];
	[[self class] createDirIfNotExsit:path];
	return path;
}


+ (NSString *)userStoragePath:(NSString *)userID
{
	NSString *path = [[[self class] userWorkBasePath:userID] stringByAppendingPathComponent:@"img.db"];
	return path;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)docFilePathWithUserID:(NSString *)userID fileName:(NSString *)fileName  isSend:(BOOL)flag
{
	NSString *docPath = [NSString stringWithFormat:@"%@/doc/%@", flag == YES?[self sendFilePath]:[self recvFilePath], userID];
	[[self class] createDirIfNotExsit:docPath];
	return [docPath stringByAppendingPathComponent:fileName];
}

+ (NSString *)thumbnailPathWithUserID:(NSString *)userID fileName:(NSString *)fileName
{
	NSString *docPath = [NSString stringWithFormat:@"%@/thumbnail/%@", [[self class] userWorkBasePath:[IMContext sharedContext].loginUser.userID], userID];
	[[self class] createDirIfNotExsit:docPath];
	return [docPath stringByAppendingPathComponent:fileName];
}

+ (NSString *)picPathWithUserID:(NSString *)userID fileName:(NSString *)fileName isSend:(BOOL)flag
{
	NSString *docPath = [NSString stringWithFormat:@"%@/pic/%@", flag == YES?[self sendFilePath]:[self recvFilePath], userID];
	[[self class] createDirIfNotExsit:docPath];
	return [docPath stringByAppendingPathComponent:fileName];
}

+ (NSString *)audioPathWithUserID:(NSString *)userID fileName:(NSString *)fileName
{
	NSString *docPath = [NSString stringWithFormat:@"%@/audio/%@", [[self class] userWorkBasePath:[IMContext sharedContext].loginUser.userID], userID];
	[[self class] createDirIfNotExsit:docPath];
	return [docPath stringByAppendingPathComponent:fileName];
}

+ (NSString *)videoPathWithUserID:(NSString *)userID fileName:(NSString *)fileName isSend:(BOOL)flag
{
	NSString *docPath = [NSString stringWithFormat:@"%@/video/%@", flag == YES?[self sendFilePath]:[self recvFilePath], userID];
	[[self class] createDirIfNotExsit:docPath];
	return [docPath stringByAppendingPathComponent:fileName];
}


+ (NSString *)sendFilePath
{
	NSString *docPath = [NSString stringWithFormat:@"%@/send", [[self class] userWorkBasePath:[IMContext sharedContext].loginUser.userID]];
	[[self class] createDirIfNotExsit:docPath];
	return docPath;
}

+ (NSString *)recvFilePath
{
	NSString *docPath = [NSString stringWithFormat:@"%@/recv", [[self class] userWorkBasePath:[IMContext sharedContext].loginUser.userID]];
	[[self class] createDirIfNotExsit:docPath];
	return docPath;
}

+ (NSString *)originDocFilePath:(NSString *)filename isSend:(BOOL)flag
{
	NSString *docPath = flag == YES? [[self class] sendFilePath]:[[self class] recvFilePath];
	return [docPath stringByAppendingPathComponent:filename];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSURL *)fileSvrUrlForMsg:(IMMsg *)msg
{
	return [NSURL URLWithString:@"http://www.baidu.com"];
}


+ (NSString *)fileThumbPathForMsg:(IMMsg *)msg
{
	return [[self userWorkBasePath:msg.fromUser.userID] stringByAppendingPathComponent:@"1.thb"];
}

+ (NSString *)fileOriginPathForMsg:(IMMsg *)msg
{
	return [[self userWorkBasePath:msg.fromUser.userID] stringByAppendingPathComponent:@"1.org"];
}
@end
