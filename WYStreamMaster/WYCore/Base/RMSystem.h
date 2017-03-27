//
//  RMSystem.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/17.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#ifndef RMSystem_h
#define RMSystem_h

typedef NS_ENUM(NSInteger, RMOrintationType) {
    RMLandscapeScreenType = 0,//横屏
    RMPortraitScreenType//竖屏
};

typedef enum : NSUInteger {
    VideoQualityStandardDefinition = 0, // 标清
    VideoQualityHighDefinition,         // 高清
    VideoQualitySuperDefinition,        // 超清
} VideoQuality;

static NSString* IMG_URL = @"http://img.wangyuhudong.com";

#ifdef DEBUG
#   define WYLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else

#   define WYLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif


#define QQ_ID                       @"1105704181"
#define QQ_Key                      @"Si2I5I3L4jCqPMHb"
#define WX_ID                       @"wx734a79f9d8dd2449"
#define WX_Secret                   @"1118254696ab45fe2b3a446724c843a7"
#define SINA_ID                     @"385077331"
#define SINA_Secret                 @"b1d52a84e7a2f8674565b9a7d8d7754f"
#define Sina_RedirectURL            @"http://yuertv.wangyuhudong.com"

#define WY_IMAGE_COMPRESSION_QUALITY 0.4
#define MAX_WX_IMAGE_SIZE 32*1024

// 腾讯Bugly
#define kBuglyAppID  @"e078b6715c"
// 网易云信Key
#define kNIMAppKey  @"93c2730be068bfa8557eca30c56287bb"
// 蒲公英APPID
#define kPGYAppId   @"f00dc3824232bd993b458464b95c15df"
// 友盟AppKey
#define kUMAppKey   @"5847eddb310c9356ce001746"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

//用于block获取弱引用
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define WEAKSELF  __weak __typeof(&*self)weakSelf = self;

#define SCREEN_WIDTH (CGRectGetWidth([UIScreen mainScreen].bounds))
#define SCREEN_HEIGHT (CGRectGetHeight([UIScreen mainScreen].bounds))

#define SCREEN_WIDTH (CGRectGetWidth([UIScreen mainScreen].bounds))
#define SCREEN_HEIGHT (CGRectGetHeight([UIScreen mainScreen].bounds))

#define kNetworkHostCacheKey @"kNetworkHostCacheKey"

#define kRoomChatViewCustomWidth  95 //15为.left

#endif /* RMSystem_h */
