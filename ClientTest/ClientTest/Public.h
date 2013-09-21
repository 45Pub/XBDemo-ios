//
//  Public.h
//  IMLite
//
//  Created by Ethan on 13-8-2.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IMUser.h>

@interface Public : NSObject

//+ (NSString*)localDataPathForUrl:(NSString*)url;

+ (NSString*)formatUrlPathToLocalAvatarSavePath:(NSString*)url withUserId:(NSString*)userId;

+ (BOOL)saveDataToPath:(NSString*)path data:(NSData*)data overwrite:(BOOL)overwrite;

//+ (void)setLocalCachePath:(NSString*)cachePath forUrlKey:(NSString*)url;

+ (NSString*)formatStringifNull:(NSString*)formatString;

+ (UIImage*)imageOfUser:(IMUser*)user;

+ (NSString*)urlImagePathToLocalImagePathAndSave:(NSString*)urlPath user:(IMUser*)user overWrite:(BOOL)overWrite;

+ (BOOL)isValidateEmail:(NSString *)email;

+ (BOOL)isValidateMobilePhone:(NSString *)mobilePhone;

+ (BOOL)isValidateFixedPhone:(NSString *)fixedPhone;

+ (dispatch_queue_t)getAvatarDispatchQueue;


@end
