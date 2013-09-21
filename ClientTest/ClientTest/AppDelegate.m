//
//  AppDelegate.m
//  ClientTest
//
//  Created by pengjay on 13-7-9.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "ContactsViewController.h"
#import "FriendViewController.h"
#import "ChatSessionViewController.h"
#import "SetViewController.h"

#import "UINavigationController+PPCategory.h"
#import <IMChatSessionManager.h>
#import <IMConfiguration.h>
#import <IMDefaultConfigurator.h>
#import "IMJHConfigurator.h"
#import "UIAlertView+Blocks.h"
#import "LoginViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import "IMContext.h"
#import <ASIHttpRequest.h>
#import <JSONKit.h>
#import "Public.h"
#import "MBProgressHUD.h"


 AppDelegate *del = nil;
@interface AppDelegate()

@property (nonatomic, copy) NSString *devToken;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
	del = self;
    
    self.userInOutFlag = UserInOutFlagOut;
    
    self.deviceUID = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    self.device = @"ios";
    self.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if (self.version == nil) {
        self.version = @"1.0";
    }
	
	[IMConfiguration  sharedInstanceWithConfigurator:[[[IMJHConfigurator alloc]init] autorelease]];

    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

//    [self clearLoginInfoFromUserDefaults];
    NSDictionary *userInfo = [self loginInfoFromUserDefaults];
    if (userInfo && userInfo[@"account"] && userInfo[@"password"]) {
        
        NSString *userAccount = userInfo[@"account"];

        [self loginWithUserAccount:userAccount password:[userInfo objectForKey:@"password"]];
        self.window.rootViewController = self.tabBarController;

        [self.window makeKeyAndVisible];
        [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        
    } else {
        [self gotoLoginViewController];
        [self.window makeKeyAndVisible];
    }
    
    // for test
//    [self loginIM];
//    self.window.rootViewController = self.tabBarController;
    

    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    
    //将令牌转换为16进制字符串，通过presence发送
    NSMutableString *pushToken = [NSMutableString string];
    Byte *bytes = (Byte *)[deviceToken bytes];
    int length = [deviceToken length];
    for(int i = 0; i< length; i++)
    {
        NSString *hex = [NSString stringWithFormat:@"%02x", bytes[i]&0xff];
        [pushToken appendString:hex];
    }
    
    self.devToken = pushToken;
    
    if(self.client.isOnline) {
        [self.client sendToken:self.devToken];
    }

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
} 

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}


- (void)loginIM
{
//#warning change user and passwd
//	if (_client) {
//		[_client.delegates removeAllDelegates];
//		[_client release];
//	}
//	
//	_client = [[IMXbcxClient alloc]initWithUserID:@"test111@lhxk.com"
//										   passwd:@"1234567" host:SERVER_HOST port:SERVER_PORT];
//	
//	[_client.delegates addDelegate:self delegateQueue:dispatch_get_main_queue()];
//	[_client connectAndSignup];
//	
////	[_client.sessionMgr addDelegate:self delegateQueue:dispatch_get_main_queue()];
//	
//	[_client.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self loginWithUserAccount:@"597376825@qq.com" password:[@"123456" md5Hash]];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (PPUITabBarController *)tabBarController
{
	if(_tabBarController == nil)
	{
		UIImage *navBackImage = [UIImage imageNamed:@"nav-bg.png"];
		ChatSessionViewController *msgVC = [[ChatSessionViewController alloc]initWithNibName:nil bundle:nil];
		UINavigationController *msgNav = [[UINavigationController alloc]initWithRootViewController:msgVC navigationBarBackgroundImage:navBackImage];
		[msgVC release];
		
		ContactsViewController *orgVC = [[ContactsViewController alloc]initWithNibName:nil bundle:nil];
		UINavigationController *orgNav = [[UINavigationController alloc]initWithRootViewController:orgVC navigationBarBackgroundImage:navBackImage];
		[orgVC release];
		
		FriendViewController *contactVC = [[FriendViewController alloc]initWithNibName:nil bundle:nil];
		UINavigationController *contactNav = [[UINavigationController alloc]initWithRootViewController:contactVC navigationBarBackgroundImage:navBackImage];
//		contactVC.showAdd = YES;
		[contactVC release];
		
		SetViewController *setVC = [[SetViewController alloc]initWithNibName:nil bundle:nil];
		UINavigationController *setNav = [[UINavigationController alloc]initWithRootViewController:setVC navigationBarBackgroundImage:navBackImage];
		[setVC release];
		
		NSArray *tabArray = @[msgNav,  contactNav, orgNav,setNav];
		[msgNav release];
		[orgNav release];
		[contactNav release];
		[setNav release];
		
		NSMutableDictionary *itemDic1 = [NSMutableDictionary dictionary];
		[itemDic1 setObject:[UIImage imageNamed:@"tab_01.png"] forKey:@"Default"];
		[itemDic1 setObject:[UIImage imageNamed:@"tab_05.png"] forKey:@"Seleted"];
		
		NSMutableDictionary *itemDic2 = [NSMutableDictionary dictionary];
		[itemDic2 setObject:[UIImage imageNamed:@"tab_02.png"] forKey:@"Default"];
		[itemDic2 setObject:[UIImage imageNamed:@"tab_06.png"] forKey:@"Seleted"];
		
		NSMutableDictionary *itemDic3 = [NSMutableDictionary dictionary];
		[itemDic3 setObject:[UIImage imageNamed:@"tab_03.png"] forKey:@"Default"];
		[itemDic3 setObject:[UIImage imageNamed:@"tab_07.png"] forKey:@"Seleted"];
		
		NSMutableDictionary *itemDic4 = [NSMutableDictionary dictionary];
		[itemDic4 setObject:[UIImage imageNamed:@"tab_04.png"] forKey:@"Default"];
		[itemDic4 setObject:[UIImage imageNamed:@"tab_08.png"] forKey:@"Seleted"];
		
		NSArray *items = [NSArray arrayWithObjects:itemDic1, itemDic2, itemDic3, itemDic4, nil];
		
		_tabBarController = [[PPUITabBarController alloc]initWithViewControllers:tabArray tabImageArray:items];
		
	}
	
	return _tabBarController;
}


- (void)gotoLoginViewController {
    NSLog(@"go to login View controller");
    self.userAccount = nil;
    self.userInOutFlag = UserInOutFlagOut;
    self.client.isOnline = NO;

    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:loginVC navigationBarBackgroundImage:[UIImage imageNamed:@"nav-bg.png"]];
    
    self.window.rootViewController = navC;
    
    [loginVC release];
    [navC release];
    
    [_tabBarController release];
    _tabBarController = nil;
    
}

- (void)loginToIMWithUserId:(NSString *)userID password:(NSString *)password {
    
    if (_client) {
        [_client.delegates removeAllDelegates];
        [_client release];
    }
    
    _client = [[IMXbcxClient alloc]initWithUserID:[userID stringByAppendingString:SERVER_DOMAIN]
                                           passwd:password host:SERVER_HOST port:SERVER_PORT];
    
    [_client.delegates addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_client connect];
    
    //	[_client.sessionMgr addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [_client.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    if (self.devToken) {
        _client.devToken = self.devToken;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatDelegateNote object:nil];
}

- (void)loginWithUserAccount:(NSString*)userAccount password:(NSString*)password {
    
    self.userAccount = userAccount;
    
    [self refreshLoginInfoFromUserDefaultsWithAccount:userAccount password:password host:SERVER_HOST port:SERVER_PORT];
    
    NSString *api = [[NSString stringWithFormat:@"%@%@%@", LOGIN_INFO_API, password, [del apiString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api]];
    request.delegate = self;
    [request setDidFailSelector:@selector(loginInfoFailed:)];
    [request setDidFinishSelector:@selector(loginInfoFinished:)];
    [request setTimeOutSeconds:10.0f];
//    [request setNumberOfTimesToRetryOnTimeout:3];
    [request startAsynchronous];

}

- (void)loginInfoFinished:(ASIHTTPRequest*)request {
    
    NSDictionary *dic = [[request responseString] objectFromJSONString];
    if (dic && [dic[@"ok"] boolValue]) {
        NSString *imuser = [Public formatStringifNull:dic[@"imuser"]];
        NSString *impwd = [Public formatStringifNull:dic[@"impwd"]];
        self.userInOutFlag = [[Public formatStringifNull:dic[@"role"]] integerValue];
        [self loginToIMWithUserId:imuser password:impwd];
        [MBProgressHUD hideAllHUDsForView:self.window animated:NO];
    } else {
        NSString *errorString = nil;
        if (dic && dic[@"error"]) {
            errorString = dic[@"error"];
        } else {
            errorString = @"请检查网络配置是否正确";
        }
        [self loginFailedWithError:nil withErrorString:errorString];
    }

}

- (void)loginInfoFailed:(ASIHTTPRequest*)request {
    
    [self loginFailedWithError:nil withErrorString:@"请检查网络配置是否正确"];
    
}

- (void)signOut {
    
    if (_client) {
		[_client.delegates removeAllDelegates];
		[_client release];
        _client = nil;
        self.devToken = nil;
	}
}

- (NSDictionary *)loginInfoFromUserDefaults {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"IMLoginInfo"];
}


- (void)clearLoginInfoFromUserDefaults {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"IMLoginInfo"]];
    if (userInfo && userInfo[@"password"]) {
        [userInfo removeObjectForKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"IMLoginInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)refreshLoginInfoFromUserDefaultsWithAccount:(NSString *)email password:(NSString *)password host:(NSString *)host port:(int)port {
    NSDictionary *userInfo = @{@"account": email, @"password": password, @"host": host, @"port": [NSNumber numberWithInt:port]};
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"IMLoginInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppRosterDidPopulate:(XMPPRosterSqlStorage *)sender
{
//	NSArray *array = [_client allFirstLetterAndUserInRoster];
//	NSLog(@"%@", array);

}


- (void)imClient:(IMBaseClient *)client stateChanged:(IMClientState)state
{
	NSLog(@"=========%d========", state);
}

- (void)imClient:(IMBaseClient *)client didLogin:(BOOL)suc withError:(NSError *)error {
    if (!suc) {

        [self loginFailedWithError:error withErrorString:nil];
        
    } else {
        [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessFromLoginVCNote object:nil];

    }
    
}

- (void)imClient:(IMBaseClient *)client didRecvMsg:(IMMsg *)msg
{
//	NSLog(@"=====recv:%@", msg);
}

- (void)imChatSessionDidChanged:(IMChatSessionManager *)mgr sessions:(NSArray *)sessions unreadNum:(NSUInteger)unreadNum
{
//	NSLog(@"============================================\n%@===========%d===========\n", sessions, unreadNum);
}

- (NSString *)apiString {
    
    NSString *timeStamp = TIMESTAMP_STRING_SINCE_1970;
    timeStamp = [NSString stringWithFormat:@"%@-%@", timeStamp, [timeStamp sha1Hash]];
    NSString *deviceUID = [NSString stringWithFormat:@"%@-%@", self.deviceUID, [self.deviceUID sha1Hash]];
    NSString *apiString = [NSString stringWithFormat:@"&device=%@&ver=%@&deviceuuid=%@&timesign=%@", self.device, self.version, deviceUID, timeStamp];
    if (self.userAccount) {
        NSString *userId = [NSString stringWithFormat:@"%@-%@", self.userAccount, [self.userAccount sha1Hash]];
        return [apiString stringByAppendingFormat:@"&user=%@", userId];
    } else {
        return apiString;
    }
    
}

- (void)loginFailedWithError:(NSError*)error withErrorString:(NSString*)errorString {
    
    [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
    
    self.userAccount = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailedFromLoginVCNote object:errorString];
    
    UINavigationController *navController =  (UINavigationController*)self.window.rootViewController;
    if ([[navController.childViewControllers objectAtIndex:0] isMemberOfClass:[LoginViewController class]]) {
        return;
    }
    
    __block typeof(self) weakSelf = self;
    RIButtonItem *okBtn = [RIButtonItem itemWithLabel:@"确定"];
    okBtn.action = ^(){
        [weakSelf clearLoginInfoFromUserDefaults];
        [weakSelf gotoLoginViewController];
        
    };
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"登录失败" message:errorString cancelButtonItem:okBtn otherButtonItems:nil];
    
    [alertView show];
    [alertView release];
}

- (void)imClient:(IMBaseClient *)client conflictWithError:(NSError *)error
{
	__block typeof(self) weakSelf = self;
	RIButtonItem *okBtn = [RIButtonItem itemWithLabel:@"确定"];
	okBtn.action = ^(){
		[weakSelf clearLoginInfoFromUserDefaults];
        [weakSelf gotoLoginViewController];
		
	};
	
//	RIButtonItem *cancelBtn = [RIButtonItem itemWithLabel:@"取消"];
	UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"此帐号在其他机器上登录" cancelButtonItem:okBtn otherButtonItems:nil];
	
	[alertView show];
	[alertView release];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
