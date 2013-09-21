//
//  Public.m
//  IMLite
//
//  Created by Ethan on 13-8-2.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "Public.h"
#import "AppDelegate.h"
#import "IMContext.h"
#import <IMUser.h>
#import "NSString+PPCategory.h"


@implementation Public

static dispatch_queue_t queue = NULL;

//+ (NSString*)localDataPathForUrl:(NSString*)url {
//    
//    if (!url || [url isEqualToString:@""]) {
//        return nil;
//    }
//    
//    NSString *dataSavePath = [[NSUserDefaults standardUserDefaults] objectForKey:url];
//    
//    return dataSavePath;
//}

+ (NSString*)formatUrlPathToLocalAvatarSavePath:(NSString*)url withUserId:(NSString*)userId {
    if (!url || [url isEqualToString:@""]) {
        return nil;
    }
    
    NSString *userDocument = [IMContext sharedContext].loginUser.userID;
    
    NSString *userDocPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:userDocument];
    NSString *avatarDocPath = [userDocPath stringByAppendingPathComponent:@"avatar"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir;
    if (![fileManager fileExistsAtPath:avatarDocPath isDirectory:&isDir] || !isDir) {
        [fileManager createDirectoryAtPath:avatarDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [avatarDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [url lastPathComponent], [userId substringToIndex:(userId.length-SERVER_DOMAIN.length)]]];
}

+ (BOOL)saveDataToPath:(NSString*)path data:(NSData*)data overwrite:(BOOL)overwrite {
    
    if (path == nil && data == nil) {
        return NO;
    }
    
    if (!overwrite && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    
    [data writeToFile:path atomically:YES];
    return YES;
    
}

+ (NSString*)urlImagePathToLocalImagePathAndSave:(NSString*)urlPath user:(IMUser*)user overWrite:(BOOL)overWrite {
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:urlPath isDirectory:&isDir]) {
        
        NSString *localPath = [self formatUrlPathToLocalAvatarSavePath:urlPath withUserId:user.userID];
        BOOL isDir1;
        
        if (overWrite || ![[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDir1]) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPath]];
            if (data == nil) {
                return @"";
            } else {
                [data writeToFile:localPath atomically:YES];
                return localPath;
            }
        } else {
            if (isDir1) {
                return @"";
            } else {
                return localPath;
            }
        }
    } else {
        if (isDir) {
            return @"";
        } else {
            return urlPath;
        }
    }
}

+ (UIImage*)imageOfUser:(IMUser*)user {
    
    NSString *defaultImageName;
    
    if (user.userType != IMUserTypeP2P) {
        defaultImageName = @"avatar_discussion";
    } else {
        defaultImageName = @"avatar_user";
    }
    
    if (user.avatarPath.length <= 0) {
        return [UIImage imageNamed:defaultImageName];
    }
    
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:user.avatarPath isDirectory:&isDir]) {
        NSString *localPath = [self formatUrlPathToLocalAvatarSavePath:user.avatarPath withUserId:user.userID];
        BOOL isDir1;
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDir1]) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.avatarPath]];
            if (data == nil) {
                return [UIImage imageNamed:defaultImageName];
            } else {
                [data writeToFile:localPath atomically:YES];
                return [UIImage imageWithContentsOfFile:localPath];
            }
        } else {
            if (isDir1) {
                return [UIImage imageNamed:defaultImageName];
            } else {
                return [UIImage imageWithContentsOfFile:localPath];
            }
        }
    } else {
        if (isDir) {
            return [UIImage imageNamed:defaultImageName];
        } else {
            return [UIImage imageWithContentsOfFile:user.avatarPath];
        }
    }
}

//+ (void)setLocalCachePath:(NSString*)cachePath forUrlKey:(NSString*)url {
//    
//    [[NSUserDefaults standardUserDefaults] setObject:cachePath forKey:url];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//}

+ (NSString*)formatStringifNull:(NSString*)formatString{
    
    if (formatString == nil || [formatString isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    return formatString;
    
}

+ (BOOL)isValidateEmail:(NSString *)email {
    
//    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//    
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    
//    return [emailTest evaluateWithObject:email];
    return YES;
    
}

+ (BOOL)isValidateMobilePhone:(NSString *)mobilePhone {
    
//    NSString *regex = @"^d{11}$";
//    
//    NSPredicate *mobilePhoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    
//    return [mobilePhoneTest evaluateWithObject:mobilePhone];
    return YES;

}

+ (BOOL)isValidateFixedPhone:(NSString *)fixedPhone {
    
//    NSString *regex = @"^[0-9]*$";
//    
//    NSPredicate *fixedPhoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    
//    return [fixedPhoneTest evaluateWithObject:fixedPhone];
    return YES;

}

+ (dispatch_queue_t)getAvatarDispatchQueue {
    if (!queue) {
        queue = dispatch_queue_create("avatar_queue", NULL);
    }

    return queue;
}

@end
