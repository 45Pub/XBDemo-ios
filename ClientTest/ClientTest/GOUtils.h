//
//  GOUtils.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
/////////Notification Name////////
static NSString *const kGoChatViewContrllerNote = @"kGoChatViewContrllerNote";
static NSString *const kGoSetUserInfoNote = @"kGoSetUserInfoNote";
static NSString *const kGoSetUserAvatarInfoNote = @"kGoSetUserAvatarInfoNote";
static NSString *const kGoSetUservCardInfoNote = @"kGoSetUservCardInfoNote";
static NSString *const kGoSetUserSignInfoNote = @"kGoSetUserSignInfoNote";



//#define IGNORE_LOCK

typedef NS_ENUM(NSUInteger, GOFileType) {
    GOFileTypeAll = 0,
    GOFileTypeOffice = 1,
    GOFileTypePDFTEXT = 2,
    GOFileTypePicture = 3,
    GOFileTypeVideoAudio = 4,
    GOFileTypeOther = 5
};

extern NSString *GOFileListSelectionDidChangedNotification;

@interface GOUtils : NSObject

+ (NSDictionary *)loginInfo;

+ (void)clearLoginInfo;

// returns if we are now connected(login succeeded) to server
+ (BOOL)isAgentConnectedWithFailureAlert:(BOOL)shouldShowAlertView;

#pragma mark - Secure Code Methods
+ (NSString *)secureCode;

+ (void)setSecureCode:(NSString *)secureCode updateExisting:(BOOL)shouldUpdate;

+ (void)removeSecureCode;

#pragma mark - Document File Handling Methods

+ (void)enumerateFilesWithPath:(NSString *)path comletionBlock:(void (^)(NSArray*))completionBlock;

+ (NSString *)presentationalFileSizeWithSize:(unsigned long long)fileSize;

+ (NSString *)thumbnailImagePathWithOriginPath:(NSString *)originPath;

+ (NSDictionary *)documentInfoWithFilePath:(NSString *)filePath fileManager:(NSFileManager *)fm;

+ (BOOL)writeImage:(UIImage *)originImage
                   toPath:(NSString *)filePath
      generatingThumbnail:(BOOL)shouldThumbnail;

+ (void)moveFileAtPath:(NSString *)originPath toPath:(NSString *)toPath completionBlock:(void (^)(BOOL))completionBlock;

+ (void)deleteFilesWithPathsArray:(NSArray *)array;
+ (void)deleteFileAtPath:(NSString *)filePath;

+ (void)enumerateDocumentsOfType:(GOFileType)fileType
                 completionBlock:(void(^)(NSArray*))completionBlock;

#pragma mark - Preveiw
+ (NSString *)filePreviewTiltleWithPath:(NSString *)path;
#pragma mark - Userid Methods

+ (NSString *)avatarPathForUserID:(NSString *)userid;

+ (NSString *)vcardPathForUserID:(NSString *)userid;

+ (NSString *)signPathForUserID:(NSString *)userid;

#pragma mark - NSNotification Name getter -

+ (NSString *)avatarChangeNoteName:(NSString *)userid;

+ (NSString *)vcardChangeNoteName:(NSString *)userid;

+ (NSString *)signChangeNoteName:(NSString *)userid;

+ (NSString *)getGroupUsersNoteName:(NSString *)groupid;

+ (NSString *)getGroup2UsersNoteName:(NSString *)groupid;

+ (NSString *)getGroupInfoNoteName:(NSString *)groupid;

+ (NSString *)getGroup2InfoNoteName:(NSString *)groupid;

+ (NSString *)createGroupNoteName:(NSString *)groupid;

+ (NSString *)reviseGroupNoteName:(NSString *)groupid;

+ (NSString *)exitGroupNote:(NSString *)groupid;

+ (NSString *)updateGroupNameNote:(NSString *)groupid;

//+ (ADB_TYPE)adbTypeOfUser:(IMUser *)user;
//
//+ (NSString *)adbStrTypeOfUser:(IMUser *)user;
//
//+ (NSString *)userTypeString:(IMUser *)user;
@end
