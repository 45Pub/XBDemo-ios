//
//  IMUser.h
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, IMUserType) {
	IMUserTypeP2P = 1 << 0,
	IMUserTypeDiscuss = 1 << 1,
	IMUserTypeFriendCenter = 1 << 2,
	IMUserTypeAdmin = 1 << 10,
};
@interface IMUser : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatarPath;
@property (nonatomic) IMUserType userType;
@property (nonatomic) NSInteger changeFlag;

+ (IMUserType)userTypeForUserJidStr:(NSString *)jidStr;

//friendcenter
+ (IMUser *)friendCenterUser;
@end
