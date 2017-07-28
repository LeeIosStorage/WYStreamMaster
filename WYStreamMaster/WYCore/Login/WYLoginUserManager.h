//
//  WYLoginUserManager.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYLoginModel.h"

/**
 *  用户身份类型
 */
typedef NS_ENUM(NSInteger, CPLoginUserType){
    /**
     *  none
     */
    WYLoginUserTypeNone = -1,
    /**
     *  游客
     */
    WYLoginUserTypeGuest = 0,
    /**
     *  手机
     */
    WYLoginUserTypeMobile,
    /**
     *  QQ
     */
    WYLoginUserTypeQQ,
    /**
     *  微博
     */
    WYLoginUserTypeWeibo,
    /**
     *  微信
     */
    WYLoginUserTypeWeixin,
};


@interface WYLoginUserManager : NSObject

#pragma mark - User Base info

+ (NSString *)userID;
+ (void)setUserID:(NSString *)userID;

+ (NSString *)nickname;
+ (void)setNickname:(NSString *)nickname;

+ (NSString *)username;
+ (void)setUsername:(NSString *)username;

+ (NSString *)avatar;
+ (void)setAvatar:(NSString *)avatar;

+ (NSString *)account;
+ (void)setAccount:(NSString *)account;

+ (NSString *)password;
+ (void)setPassword:(NSString *)password;
// 0 男 1 女
+ (NSString *)sex;
+ (void)setSex:(NSString *)sex;

+ (NSString *)telephone;
+ (void)setTelephone:(NSString *)telephone;

+ (NSString *)fans;
+ (void)setFans:(NSString *)fans;

//房间号
+ (NSString *)roomId;
+ (void)setRoomId:(NSString *)roomId;

+ (NSString *)versions;
+ (void)setVersions:(NSString *)versions;


+ (NSString *)anchorPushUrl;
+ (void)setAnchorPushUrl:(NSString *)anchorPushUrl;

+ (NSString *)roomNameTitle;
+ (void)setRoomNameTitle:(NSString *)roomNameTitle;

+ (NSString *)roomNoticeTitle;
+ (void)setRoomNoticeTitle:(NSString *)roomNoticeTitle;

+ (NSString *)gameCategory;
+ (void)setGameCategory:(NSString *)gameCategory;

+ (NSString *)gameCategoryId;
+ (void)setGameCategoryId:(NSString *)gameCategoryId;

// 用户资料
// 鱼币
+ (NSString *)yuerCoin;
+ (void)setYuerCoin:(NSString *)yuerCoin;
// 鱼饵
+ (NSString *)yuerBait;
+ (void)setYuerBait:(NSString *)yuerBait;
// 直播时长
+ (NSString *)liveDuration;
+ (void)setLiveDuration:(NSString *)liveDuration;

//云信用户登录ID
+ (NSString *)nimAccountID;

//聊天室ID
+ (NSString *)chatRoomId;
+ (void)setChatRoomId:(NSString *)chatRoomId;

+ (BOOL )localNotificationToClose;
+ (void)setLocalNotificationToClose:(BOOL)localNotificationToClose;

#pragma mark - User Setting


/**
 录制屏幕方向，默认为横屏

 @return 屏幕方向
 */
+ (RMOrintationType)orintationType;
+ (void)setRMOrintationType:(RMOrintationType)orintationType;

/**
 视频清晰度 (标清，高清，超清三种)，默认是标清
 
 @return 视频清晰度
 */
+ (VideoQuality)videoQuality;
+ (void)setVideoQuality:(VideoQuality)videoQuality;

//直播的游戏类型
+ (LiveGameType)liveGameType;
+ (void)setLiveGameType:(LiveGameType)liveGameType;

#pragma mark -  token info
/**
 *  用户登录后授权令牌
 *
 *  @return token
 */
+ (NSString *)authToken;
+ (void)setAuthToken:(NSString *)authToken;

/**
 *  刷新用户数据
 */
+ (void)updateUserDataWithLoginModel:(WYLoginModel *)loginModel;

#pragma mark - 公用方法

/**
 *  已登录状态判断
 *
 *  @return
 */
+ (BOOL)hasLogged;

/**
 *  清除登录信息
 */
+ (void)clearInfo;

@end
