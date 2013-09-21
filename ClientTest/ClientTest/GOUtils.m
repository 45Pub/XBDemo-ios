//
//  GOUtils.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOUtils.h"
//#import "SFHFKeychainUtils.h"
#import "NSFileManager+PPCategory.h"
#import "NSString+PPCategory.h"
//#import "IMSession.h"
#import "PPCore.h"
#import "UIImage+PPCategory.h"
#import "AppDelegate.h"

#define KEYCHAIN_USRNAME @"com.xbcx"
#define KEYCHAIN_SVCNAME @"security_code.com.xbcx"

NSString *GOFileListSelectionDidChangedNotification = @"GOFileListSelectionDidChangedNotification";

@implementation GOUtils

+ (NSDictionary *)loginInfo
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
}

+ (void)clearLoginInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"login"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//+ (BOOL)isAgentConnectedWithFailureAlert:(BOOL)shouldShowAlertView
//{
//    BOOL connected = NO;
//    GoComNetState netState = del.imAgent.netState;
//    if (netState == GoComNetStateConnected) {
//        connected = YES;
//    }
//    
//    if (connected == NO && shouldShowAlertView) {
//        NSString *title = nil;
//        if (netState == GoComNetStateConnecting) {
//            title = @"正在连接服务器，请稍后再试";
//        }
//        else if (netState == GoComNetStateunConnect) {
//            title = @"未连接到服务器，请注销后重新登录";
//        }
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
//    }
//    
//    return connected;
//}

#pragma mark - Secure Code Methods

//+ (NSString *)secureCode
//{
//#ifdef IGNORE_LOCK
//    return nil;
//#endif
//    return [SFHFKeychainUtils getPasswordForUsername:KEYCHAIN_USRNAME andServiceName:KEYCHAIN_SVCNAME error:nil];
//}
//
//+ (void)setSecureCode:(NSString *)secureCode updateExisting:(BOOL)shouldUpdate
//{
//    [SFHFKeychainUtils storeUsername:KEYCHAIN_USRNAME andPassword:secureCode forServiceName:KEYCHAIN_SVCNAME updateExisting:shouldUpdate error:nil];
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"LockChange" object:nil];
//}
//
//+ (void)removeSecureCode
//{
//    [SFHFKeychainUtils deleteItemForUsername:KEYCHAIN_USRNAME andServiceName:KEYCHAIN_SVCNAME error:nil];
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"LockChange" object:nil];
//}

#pragma mark - Thumbnail pic Methods

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

+ (NSString *)thumbnailImagePathWithOriginPath:(NSString *)originPath
{
    NSString *originFileName = [originPath lastPathComponent];
    NSArray *dividedName = [originFileName componentsSeparatedByString:@"."];
    
    NSString *thumbnailFileName = [NSString stringWithFormat:@"%@_t.%@", dividedName[0], dividedName[1]];
    
    return [[originPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:thumbnailFileName];
}

+ (NSDictionary *)documentInfoWithFilePath:(NSString *)filePath fileManager:(NSFileManager *)fm
{
    if (fm == nil) {
        fm = [NSFileManager defaultManager];
    }
    
    NSError *aErr = nil;
    NSDictionary *attributes = [fm attributesOfItemAtPath:filePath error:&aErr];
    if (aErr != nil) {
        return nil;
    }
    
    NSString *fileName = [filePath lastPathComponent];
    unsigned long long size = [attributes[NSFileSize] longLongValue];
    GOFileType fileType = [[self class] _fileTypeForFileExtension:[fileName pathExtension]];
    
    return @{@"filesize": [NSNumber numberWithLongLong:size],
             @"filepath": filePath,
             @"filename": fileName,
             @"filetype": [NSNumber numberWithUnsignedInteger:fileType]};
}

+ (BOOL)writeImage:(UIImage *)originImage toPath:(NSString *)filePath generatingThumbnail:(BOOL)shouldThumbnail
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        // file already exist, write fail
        return NO;
    }
    
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    [fm createDirectoryIfNeeded:dirPath];
    
    NSData *originData = UIImageJPEGRepresentation(originImage, 0.75);
    NSError *oErr = nil;
    [originData writeToFile:filePath options:NSDataWritingAtomic error:&oErr];
    
    if (shouldThumbnail) {
        NSString *thumbnailPath = [[self class] thumbnailImagePathWithOriginPath:filePath];
        UIImage *thumbnailImage = [[originImage cropCenter] scaleToSize:CGSizeMake(130.0, 130.0)];
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.75);
        NSError *tErr = nil;
        [thumbnailData writeToFile:thumbnailPath options:NSDataWritingAtomic error:&tErr];
    }
    
    return (oErr == nil);
}

+ (void)moveFileAtPath:(NSString *)originPath toPath:(NSString *)toPath completionBlock:(void (^)(BOOL))completionBlock
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:originPath] == NO) {
        if (completionBlock) {
            completionBlock(NO);
        }
        return;
    }
    
    [fm createDirectoryIfNeeded:[toPath stringByDeletingLastPathComponent]];
    
    dispatch_queue_t movingQueue = dispatch_queue_create("file_moving.com.xbcx", NULL);
    dispatch_async(movingQueue, ^{
        NSError *mErr = nil;
        [fm moveItemAtPath:originPath toPath:toPath error:&mErr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock((mErr == nil));
            }
        });
    });
    dispatch_release(movingQueue);
}

+ (void)deleteFilesWithPathsArray:(NSArray *)array
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    [array enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL *stop){
        NSString *thumbnailPath = [[self class] thumbnailImagePathWithOriginPath:filePath];
        
        [fileManager removeItemAtPath:filePath error:nil];
        [fileManager removeItemAtPath:thumbnailPath error:nil];
    }];
    
    [fileManager release];
}

+ (void)deleteFileAtPath:(NSString *)filePath
{
    [[self class] deleteFilesWithPathsArray:@[filePath]];
}

+ (GOFileType)_fileTypeForFileExtension:(NSString *)extension
{
    if ([extension equalsToString:@"pdf" ignoringCase:YES] ||
        [extension equalsToString:@"txt" ignoringCase:YES])
        return GOFileTypePDFTEXT;
    
    else if ([extension equalsToString:@"doc" ignoringCase:YES]  ||
             [extension equalsToString:@"docx" ignoringCase:YES] ||
             [extension equalsToString:@"xls" ignoringCase:YES]  ||
             [extension equalsToString:@"xlsx" ignoringCase:YES] ||
             [extension equalsToString:@"ppt" ignoringCase:YES]  ||
             [extension equalsToString:@"pptx" ignoringCase:YES])
        return GOFileTypeOffice;
    
    else if ([extension equalsToString:@"png" ignoringCase:YES]  ||
             [extension equalsToString:@"jpg" ignoringCase:YES]  ||
             [extension equalsToString:@"jpeg" ignoringCase:YES] ||
             [extension equalsToString:@"gif" ignoringCase:YES])
        return GOFileTypePicture;
    
    else if ([extension equalsToString:@"mp3" ignoringCase:YES] ||
             [extension equalsToString:@"mp4" ignoringCase:YES] ||
             [extension equalsToString:@"mov" ignoringCase:YES] ||
             [extension equalsToString:@"m4v" ignoringCase:YES] ||
             [extension equalsToString:@"m4a" ignoringCase:YES])
        return GOFileTypeVideoAudio;
    
    else
        return GOFileTypeOther;
}

+ (NSString *)filePreviewTiltleWithPath:(NSString *)path
{
	NSString *extension = [path pathExtension];
	GOFileType type = [self _fileTypeForFileExtension:extension];
	if (type == GOFileTypePicture)
	{
		return @"图片查看";
	}
	else if (type == GOFileTypeVideoAudio)
	{
		return @"视频播放";
	}
	else
		return @"文件查看";
}

+ (void)enumerateFilesWithPath:(NSString *)path comletionBlock:(void (^)(NSArray*))completionBlock
{
    dispatch_queue_t fileQueue = dispatch_queue_create("file_enumerating.com.xbcx", NULL);
    dispatch_async(fileQueue, ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
        NSString *relativeFilePath = nil;
        NSMutableArray *contentArray = [NSMutableArray array];
        
        while (relativeFilePath = [enumerator nextObject]) {
            NSString *fullPath = [path stringByAppendingPathComponent:relativeFilePath];
            NSDictionary *attributes = [manager attributesOfItemAtPath:fullPath error:nil];
            NSDate *time = attributes[NSFileCreationDate];
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"yy-MM-dd"];
            NSString *timeStr = [formatter stringFromDate:time];
            if (attributes[NSFileType] != NSFileTypeDirectory) {
                unsigned long long size = [attributes[NSFileSize] longLongValue];
                
                NSDictionary *fileInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          [NSNumber numberWithLongLong:size], @"filesize",
                                          fullPath, @"filepath",
                                          [relativeFilePath lastPathComponent], @"filename",
                                          timeStr, @"time", nil];
                
                [contentArray addObject:fileInfo];
                [fileInfo release];
            }
        }
        
        [contentArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSDictionary *attr1 = [manager attributesOfItemAtPath:obj1[@"filepath"] error:nil];
            NSDictionary *attr2 = [manager attributesOfItemAtPath:obj2[@"filepath"] error:nil];
            
            NSDate *date1 = attr1[NSFileCreationDate];
            NSDate *date2 = attr2[NSFileCreationDate];
            
            return [date1 compare:date2];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock)
            {
                completionBlock(contentArray);
            }
        });
        
    });
    
    dispatch_release(fileQueue);
}
/*
+ (void)enumerateDocumentsOfType:(GOFileType)fileType completionBlock:(void (^)(NSArray*))completionBlock
{
    dispatch_queue_t fileQueue = dispatch_queue_create("file_enumerating.com.xbcx", NULL);
    dispatch_async(fileQueue, ^{
        NSFileManager *docManager = [[NSFileManager alloc] init];
        
        NSString *workPath = [[IMSession globalIMSession].loginUser userWorkBasePath];
        NSString *docPath = [workPath stringByAppendingPathComponent:@"Doc/"];
		NSMutableArray *docArray = [NSMutableArray array];
		[docArray addObject:docPath];
		[docArray addObject:[workPath stringByAppendingPathComponent:@"Pic/"]];
		[docArray addObject:[workPath stringByAppendingPathComponent:@"Video/"]];
		
		
        NSMutableArray *contentArray = [NSMutableArray array];
        
		for (NSString *dPath in docArray)
		{
			NSDirectoryEnumerator *enumerator = [docManager enumeratorAtPath:dPath];
			
			NSString *relativeFilePath = nil;
			while (relativeFilePath = [enumerator nextObject]) {
				GOFileType currentFileType = [[self class] _fileTypeForFileExtension:[relativeFilePath pathExtension]];
				if (fileType == GOFileTypeAll || fileType == currentFileType) {
					NSString *fullPath = [dPath stringByAppendingPathComponent:relativeFilePath];
					NSDictionary *attributes = [docManager attributesOfItemAtPath:fullPath error:nil];
					BOOL isThumbnail = [relativeFilePath containsString:@"_t."];
					if (attributes[NSFileType] != NSFileTypeDirectory && !isThumbnail) {
						unsigned long long size = [attributes[NSFileSize] longLongValue];
						
						NSDictionary *fileInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
												  [NSNumber numberWithLongLong:size], @"filesize",
												  fullPath, @"filepath",
												  [relativeFilePath lastPathComponent], @"filename",
												  [NSNumber numberWithUnsignedInteger:currentFileType] , @"filetype", nil];
						
						[contentArray addObject:fileInfo];
						[fileInfo release];
					}
				}
			}
		}
        [contentArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSDictionary *attr1 = [docManager attributesOfItemAtPath:obj1[@"filepath"] error:nil];
            NSDictionary *attr2 = [docManager attributesOfItemAtPath:obj2[@"filepath"] error:nil];
            
            NSDate *date1 = attr1[NSFileCreationDate];
            NSDate *date2 = attr2[NSFileCreationDate];
            
            return [date1 compare:date2];
        }];
        [docManager release];
		
		//create thumbnail image if not exsit
		for (NSDictionary *dic in contentArray)
		{
			@autoreleasepool
			{
				if ([dic[@"filetype"] integerValue] == GOFileTypePicture)
				{
					NSString *thumbnailPath = [[self class] thumbnailImagePathWithOriginPath:dic[@"filepath"]];
					if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath])
					{
						UIImage *originImage = [UIImage imageWithContentsOfFile:dic[@"filepath"]];
						
						UIImage *thumbnailImage = [[originImage cropCenter] scaleToSize:CGSizeMake(130.0, 130.0)];
						NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.75);
						NSError *tErr = nil;
						if (thumbnailData)
							[thumbnailData writeToFile:thumbnailPath options:NSDataWritingAtomic error:&tErr];
					}
				}
			}
		}
        
		
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(contentArray);
            }
        });
    });
    dispatch_release(fileQueue);
}
*/
#pragma mark - Userid Methods

+ (NSString *)avatarPathForUserID:(NSString *)userid
{
	NSString *prefix = [userid sha1Hash];
	NSString *path = [[[NSFileManager defaultManager] documentsDirectoryPath] stringByAppendingPathComponent:@"avatar"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        PPaddSkipBackupAttributeToItemAtPath(path);
    }
	return [NSString stringWithFormat:@"%@/%@", path, prefix];
}

+ (NSString *)vcardPathForUserID:(NSString *)userid
{
	NSString *prefix = [userid sha1Hash];
	NSString *path = [[[NSFileManager defaultManager] documentsDirectoryPath] stringByAppendingPathComponent:@"vcard"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        PPaddSkipBackupAttributeToItemAtPath(path);
    }
	return [NSString stringWithFormat:@"%@/%@", path, prefix];
}

+ (NSString *)signPathForUserID:(NSString *)userid
{
	NSString *prefix = [userid sha1Hash];
	NSString *path = [[[NSFileManager defaultManager] documentsDirectoryPath] stringByAppendingPathComponent:@"sign"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        PPaddSkipBackupAttributeToItemAtPath(path);
    }
	return [NSString stringWithFormat:@"%@/%@", path, prefix];

}

+ (NSString *)avatarChangeNoteName:(NSString *)userid
{
	return [NSString stringWithFormat:@"fetchavatar%@", userid];
}

+ (NSString *)vcardChangeNoteName:(NSString *)userid
{
	return [NSString stringWithFormat:@"queryvcard%@", userid];
}

+ (NSString *)signChangeNoteName:(NSString *)userid
{
	return [NSString stringWithFormat:@"querysign%@", userid];
}

+ (NSString *)getGroupUsersNoteName:(NSString *)groupid
{
	return [NSString stringWithFormat:@"getGroupUsers%@", groupid];
}

+ (NSString *)getGroup2UsersNoteName:(NSString *)groupid
{
	return [NSString stringWithFormat:@"getGroup2Users%@", groupid];
}

+ (NSString *)getGroupInfoNoteName:(NSString *)groupid
{
	return [NSString stringWithFormat:@"getGroupinfo%@", groupid];
}

+ (NSString *)getGroup2InfoNoteName:(NSString *)groupid
{
	return [NSString stringWithFormat:@"getGroup2info%@", groupid];
}

+ (NSString *)createGroupNoteName:(NSString *)groupid
{
	return [NSString stringWithFormat:@"createGroup"];
}

+ (NSString *)reviseGroupNoteName:(NSString *)groupid
{
	return [NSString stringWithFormat:@"reviseGroup%@", groupid];
}

+ (NSString *)exitGroupNote:(NSString *)groupid
{
	return [NSString stringWithFormat:@"exitGroup%@", groupid];
}

+ (NSString *)updateGroupNameNote:(NSString *)groupid
{
	return [NSString stringWithFormat:@"updategourpName%@", groupid];
}

//+ (ADB_TYPE)adbTypeOfUser:(IMUser *)user
//{
//    if (user.userType == IMUserTypeP2P) {
//        return ADB_TYPE_PERSON;
//    }
//    else if (user.userType == IMUserTypeDepartMent) {
//        return ADB_TYPE_DEPARTMENT;
//    }
//    else if (user.userType == IMUserTypeGRP) {
//        return ADB_TYPE_GRP;
//    }
//    else if (user.userType == IMUserTypeGRP2) {
//        return ADB_TYPE_GRP2;
//    }
//    
//    return -1;
//}
//
//+ (NSString *)adbStrTypeOfUser:(IMUser *)user
//{
//    if (user.userType == IMUserTypeP2P) {
//        return @"p";
//    }
//    else if (user.userType == IMUserTypeDepartMent) {
//        return @"d";
//    }
//    else if (user.userType == IMUserTypeGRP) {
//        return @"g";
//    }
//    else if (user.userType == IMUserTypeGRP2) {
//        return @"q";
//    }
//    
//    return @"";
//}
//
//+ (NSString *)userTypeString:(IMUser *)user
//{
//	if (user.userType == IMUserTypeP2P)
//	{
//		return @"个人";
//	}
//	else if (user.userType == IMUserTypeGRP)
//	{
//		return @"讨论组";
//	}
//	else if (user.userType == IMUserTypeGRP2)
//	{
//		return @"群";
//	}
//	else if (user.userType == IMUserTypeDepartMent)
//	{
//		return @"部门";
//	}
//	return @"";
//}
@end
