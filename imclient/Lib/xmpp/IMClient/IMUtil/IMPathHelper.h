//
//  IMPathHelper.h
//  IMClient
//
//  Created by pengjay on 13-7-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMMsg, IMUser;
@interface IMPathHelper : NSObject
+ (NSString *)userWorkBasePath:(NSString *)userID;
+ (NSString *)userStoragePath:(NSString *)userID;
+ (NSURL *)fileSvrUrlForMsg:(IMMsg *)msg;
+ (NSString *)fileThumbPathForMsg:(IMMsg *)msg;
+ (NSString *)fileOriginPathForMsg:(IMMsg *)msg;



+ (NSString *)docFilePathWithUserID:(NSString *)userID fileName:(NSString *)fileName  isSend:(BOOL)flag;
+ (NSString *)thumbnailPathWithUserID:(NSString *)userID fileName:(NSString *)fileName;
+ (NSString *)picPathWithUserID:(NSString *)userID fileName:(NSString *)fileName  isSend:(BOOL)flag;
+ (NSString *)audioPathWithUserID:(NSString *)userID fileName:(NSString *)fileName;
+ (NSString *)videoPathWithUserID:(NSString *)userID fileName:(NSString *)fileName  isSend:(BOOL)flag;
+ (NSString *)originDocFilePath:(NSString *)filename isSend:(BOOL)flag;

+ (NSString *)sendFilePath;
+ (NSString *)recvFilePath;
@end
