//
//  AppDelegate.h
//  ClientTest
//
//  Created by pengjay on 13-7-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <IMXbcxClient.h>
#import "PPUITabBarController.h"

//#define SERVER_HOST @"lvxk.xbcx.com.cn"
#define SERVER_HOST @"xbcx.com.cn"
#define SERVER_PORT 31004
#define SERVER_DOMAIN @"@lhxk.com"
#define TIMESTAMP_STRING_SINCE_1970 [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]


//#define API_PREFIX @"http://lvxk.xbcx.com.cn/lianhuaxingke/index.php?g=Api"
#define API_PREFIX @"http://xbcx.com.cn/lianhuaxingke/index.php?g=Api"

#define CHANGE_USER_INFO_API [NSString stringWithFormat:@"%@%@", API_PREFIX, @"&a=index&m=Changeuserinfo&"] 
#define USER_INFO_API [NSString stringWithFormat:@"%@%@", API_PREFIX, @"&m=Getuserinfo&a=index&imuser="]
#define LOGIN_INFO_API [NSString stringWithFormat:@"%@%@", API_PREFIX, @"&a=index&m=Login&pwd="]
#define DEPARTMENT_INFO_API [NSString stringWithFormat:@"%@%@", API_PREFIX, @"&a=index&m=Getdepinfo&id="]
#define SEARCH_INFO_API [NSString stringWithFormat:@"%@%@", API_PREFIX, @"&a=index&m=Search&search="]
#define REGISTER_INFO_API [NSString stringWithFormat:@"%@%@", API_PREFIX, @"&a=index&m=Register"]
#define USER_INFO_API [NSString stringWithFormat:@"%@%@", API_PREFIX, @"&m=Getuserinfo&a=index&imuser="]

typedef NS_ENUM(NSInteger, UserInOutFlag) {
    UserInOutFlagIn = 0,
    UserInOutFlagOut,
};

@class ViewController;

static NSString *const kLoginSuccessFromLoginVCNote = @"kLoginSuccessFromLoginVCNote";
static NSString *const kLoginFailedFromLoginVCNote = @"kLoginFailedFromLoginVCNote";

@interface AppDelegate : UIResponder <UIApplicationDelegate, IMClientDelegate>

@property (nonatomic, copy) NSString *deviceUID;
@property (nonatomic, copy) NSString *device;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *userAccount;

@property (nonatomic, assign) UserInOutFlag userInOutFlag;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, strong) IMXbcxClient *client;
@property (nonatomic, retain) PPUITabBarController *tabBarController;


- (void)loginWithUserAccount:(NSString*)userAccount password:(NSString*)password;
- (void)loginToIMWithUserId:(NSString *)userID password:(NSString *)password;

- (void)signOut;

- (NSDictionary *)loginInfoFromUserDefaults;

- (void)clearLoginInfoFromUserDefaults;

- (void)refreshLoginInfoFromUserDefaultsWithAccount:(NSString *)email password:(NSString *)password host:(NSString *)host port:(int)port;

- (void)gotoLoginViewController;

- (NSString *)apiString;


@end

extern AppDelegate *del;