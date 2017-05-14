//
//  AppDelegate.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/8.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabViewController.h"
#import "WYLoginManager.h"
#import <PLMediaStreamingKit/PLStreamingKit.h>
#import "WYSocketManager.h"
#import "YTCustomAttachmentDecoder.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.hidden = NO;
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 初始化七牛推流SDK
    [PLStreamingEnv initEnv];
    
    //登录云信
    [[NIMSDK sharedSDK] registerWithAppID:kNIMAppKey cerName:@""];
    // 注册反序列化类
    [NIMCustomObject registerCustomDecoder:[YTCustomAttachmentDecoder new]];
    
    [Bugly startWithAppId:kBuglyAppID];
    
//    [[WYSocketManager sharedInstance] initSocketURL:[NSURL URLWithString:@"wss://echo.websocket.org"]];
    
#ifdef DEBUG
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kNetworkHostCacheKey]) {
        [WYAPIGenerate sharedInstance].netWorkHost = [[NSUserDefaults standardUserDefaults] objectForKey:kNetworkHostCacheKey];
    } else {
        //默认先上环境
        [WYAPIGenerate sharedInstance].netWorkHost = defaultNetworkHost;
    }
#else
    [WYAPIGenerate sharedInstance].netWorkHost = defaultNetworkHost;
#endif
    
    
//    [self initTab];
    [self reLogin];
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -
#pragma mark - Action
- (void)initTab
{
    MainTabViewController *mineVC = [[MainTabViewController alloc] init];
    WYNavigationController *createNav = [[WYNavigationController alloc] initWithRootViewController:mineVC];
    [createNav setNavigationBarHidden:YES];
    
    self.window.rootViewController = createNav;
}

- (void)showLogin
{
    
//    NSArray *languages = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
//    NSString *currentLanguage = languages.firstObject;
//    NSLog(@"模拟器当前语言：%@",currentLanguage);
    
    WS(weakSelf)
    [[WYLoginManager sharedManager] showLoginViewControllerFromWindow:self.window showCancelButton:NO success:^{
        [weakSelf initTab];
    } failure:^(NSString *errorMessage) {
        
    } cancel:^{
        
    }];
}

- (void)reLogin
{
    [self showLogin];
}

@end
