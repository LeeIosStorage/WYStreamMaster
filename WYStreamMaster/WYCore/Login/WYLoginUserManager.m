//
//  WYLoginUserManager.m
//  WYRecordMaster
//
//  Created by zurich on 16/8/18.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYLoginUserManager.h"
#import "WYLoginManager.h"

//static NSString* IMG_URL = @"http://img.wangyuhudong.com";

static NSString *const kUserInfoUserID = @"kUserInfoUserID";
static NSString *const kUserInfoNickname = @"kUserInfoNickname";
static NSString *const kUserInfoAvatar = @"kUserInfoAvatar";
static NSString *const kUserInfoUserName = @"kUserInfoUserName";

static NSString *const kUserAccount = @"kUserAccount";
static NSString *const kUserPassword = @"kUserPassword";
static NSString *const KUserSexKey = @"sex";
static NSString *const kUserInfoAuthToken = @"kUserInfoAuthToken";
static NSString *const kUserTelephone = @"kUserTelephone";
static NSString *const kUserFans = @"kUserFans";
static NSString *const kUserRoomId = @"kUserRoomId";

static NSString *const kAnchorPushUrl = @"kAnchorPushUrl";
static NSString *const kRoomNameTitle = @"kRoomNameTitle";
static NSString *const kRoomNoticeTitle = @"kRoomNoticeTitle";
static NSString *const kGameCategory = @"kGameCategory";
static NSString *const kGameCategoryID = @"kGameCategoryID";

static NSString *const kOrintationType = @"kOrintationType";
static NSString *const kVideoQuality = @"kVideoQuality";
static NSString *const kLiveGameType = @"kLiveGameType";

static NSString *const kYuerCoin = @"kYuerCoin";
static NSString *const kSpacePhoto = @"kSpacePhoto";
static NSString *const kLiveDuration = @"kLiveDuration";
static NSString *const kRememberPassword = @"kRememberPassword";
static NSString *const kIsFirstEnterApplication = @"kIsFirstEnterApplication";
@implementation WYLoginUserManager


+ (NSString *)account
{
    return [self objectFromUserDefaultsKey:kUserAccount];
}
+ (void)setAccount:(NSString *)account
{
    [self saveToUserDefaultsObject:account forKey:kUserAccount];
}

+ (NSString *)versions {
    return [self objectFromUserDefaultsKey:@"versions"];
}

+ (void)setVersions:(NSString *)versions {
    
    [self saveToUserDefaultsObject:versions forKey:@"versions"];
}

+ (NSString *)userID {
    return [self objectFromUserDefaultsKey:kUserInfoUserID];
}

+ (void)setUserID:(NSString *)userID {
    [self saveToUserDefaultsObject:userID forKey:kUserInfoUserID];
}

+ (NSString *)password
{
    return [self objectFromUserDefaultsKey:kUserPassword];
}
+ (void)setPassword:(NSString *)password
{
    [self saveToUserDefaultsObject:password forKey:kUserPassword];
}

+ (NSString *)sex{
    return [self objectFromKeyChainKey:KUserSexKey];
}

+ (void)setSex:(NSString *)sex{
    [self saveToKeyChainObject:sex forKey:KUserSexKey];
}


+ (NSString *)nickname {
    return [self objectFromKeyChainKey:kUserInfoNickname];
}

+ (void)setNickname:(NSString *)nickname{
    [self saveToKeyChainObject:nickname forKey:kUserInfoNickname];
}

+ (NSString *)username{
    return [self objectFromKeyChainKey:kUserInfoUserName];
}
+ (void)setUsername:(NSString *)username{
    [self saveToKeyChainObject:username forKey:kUserInfoUserName];
}

+ (NSString *)avatar
{
   return  [self objectFromKeyChainKey:kUserInfoAvatar];
}

+ (void)setAvatar:(NSString *)avatar {
    NSString *urlAvatar = avatar;
    [self saveToUserDefaultsObject:urlAvatar forKey:kUserInfoAvatar];
}

+ (NSString *)telephone
{
    return [self objectFromKeyChainKey:kUserTelephone];
}

+ (void)setTelephone:(NSString *)telephone
{
    [self saveToUserDefaultsObject:telephone forKey:kUserTelephone];
}

+ (NSString *)fans
{
    return [self objectFromUserDefaultsKey:kUserFans];
}
+ (void)setFans:(NSString *)fans
{
    [self saveToUserDefaultsObject:fans forKey:kUserFans];
}

+ (NSString *)roomId
{
    return [self objectFromUserDefaultsKey:kUserRoomId];
}

+ (void)setRoomId:(NSString *)roomId
{
    [self saveToUserDefaultsObject:roomId forKey:kUserRoomId];
}

+ (NSString *)chatRoomId
{
    return [self objectFromUserDefaultsKey:@"chatRoomId"];
}

+ (void)setChatRoomId:(NSString *)chatRoomId
{
    [self saveToUserDefaultsObject:chatRoomId forKey:@"chatRoomId"];
}

+ (BOOL )localNotificationToClose
{
    return [[self objectFromUserDefaultsKey:@"localNotification"] boolValue];
}

+ (void)setLocalNotificationToClose:(BOOL)localNotificationToClose
{
    [self saveToUserDefaultsObject:[NSNumber numberWithBool:localNotificationToClose] forKey:@"localNotification"];
}

+ (NSString *)anchorPushUrl{
    return [self objectFromUserDefaultsKey:kAnchorPushUrl];
}
+ (void)setAnchorPushUrl:(NSString *)anchorPushUrl{
    [self saveToUserDefaultsObject:anchorPushUrl forKey:kAnchorPushUrl];
}

+ (NSString *)roomNameTitle
{
    return [self objectFromUserDefaultsKey:kRoomNameTitle];
}

+ (void)setRoomNameTitle:(NSString *)roomNameTitle
{
    [self saveToUserDefaultsObject:roomNameTitle forKey:kRoomNameTitle];
}

+ (NSString *)roomNoticeTitle{
    return [self objectFromUserDefaultsKey:kRoomNoticeTitle];
}
+ (void)setRoomNoticeTitle:(NSString *)roomNoticeTitle{
    [self saveToUserDefaultsObject:roomNoticeTitle forKey:kRoomNoticeTitle];
}

+ (NSString *)gameCategory
{
    return [self objectFromUserDefaultsKey:kGameCategory];
}

+ (void)setGameCategory:(NSString *)gameCategory
{
    [self saveToUserDefaultsObject:gameCategory forKey:kGameCategory];
}

+ (NSString *)gameCategoryId
{
    return [self objectFromUserDefaultsKey:kGameCategoryID];
}

+ (void)setGameCategoryId:(NSString *)gameCategoryId
{
    [self saveToUserDefaultsObject:gameCategoryId forKey:kGameCategoryID];
}

+ (NSString *)nimAccountID
{
    return [WYLoginUserManager userID];
}

+ (NSString *)yuerCoin
{
    return [self objectFromUserDefaultsKey:kYuerCoin];
}
+ (void)setYuerCoin:(NSString *)yuerCoin
{
    [self saveToUserDefaultsObject:yuerCoin forKey:kYuerCoin];
}
// 鱼饵
// 空间照片
+ (NSString *)spacePhoto
{
    return [self objectFromUserDefaultsKey:kSpacePhoto];
}
+ (void)setSpacePhoto:(NSString *)spacePhoto
{
    [self saveToUserDefaultsObject:spacePhoto forKey:kSpacePhoto];
}
// 直播时长
+ (NSString *)liveDuration
{
    return [self objectFromUserDefaultsKey:kLiveDuration];
}

+ (void)setLiveDuration:(NSString *)liveDuration
{
    [self saveToUserDefaultsObject:liveDuration forKey:kLiveDuration];
}

// 是否记住密码
+ (NSString *)rememberPassword
{
    return [self objectFromUserDefaultsKey:kRememberPassword];
}

+ (void)setRememberPassword:(NSString *)rememberPassword;
{
    [self saveToUserDefaultsObject:rememberPassword forKey:kRememberPassword];
}

// 是否第一次进入程序
+ (void)setIsFirstEnterApplication:(NSString *)isFirstEnterApplication;
{
    [self saveToUserDefaultsObject:isFirstEnterApplication forKey:kIsFirstEnterApplication];
}

// 是否第一次进入程序
+ (NSString *)isFirstEnterApplication
{
    return [self objectFromUserDefaultsKey:kIsFirstEnterApplication];
}



#pragma mark - User Setting

+ (RMOrintationType)orintationType
{
    if (![self objectFromUserDefaultsKey:kOrintationType]) {
        return RMLandscapeScreenType;
    }
    return [[self objectFromUserDefaultsKey:kOrintationType] integerValue];
}
+ (void)setRMOrintationType:(RMOrintationType)orintationType
{
    [self saveToUserDefaultsObject:[NSNumber numberWithInteger:orintationType] forKey:kOrintationType];
}

+ (VideoQuality)videoQuality
{
    if (![self objectFromUserDefaultsKey:kVideoQuality]) {
        return VideoQualityStandardDefinition;
    }
    return [[self objectFromUserDefaultsKey:kVideoQuality] integerValue];

}
+ (void)setVideoQuality:(VideoQuality)videoQuality
{
    [self saveToUserDefaultsObject:[NSNumber numberWithInteger:videoQuality] forKey:kVideoQuality];
}


+ (LiveGameType)liveGameType
{
    if (![self objectFromUserDefaultsKey:kLiveGameType]) {
        return LiveGameTypeNormal;
    }
    return [[self objectFromUserDefaultsKey:kLiveGameType] integerValue];
    
}
+ (void)setLiveGameType:(LiveGameType)liveGameType
{
    [self saveToUserDefaultsObject:[NSNumber numberWithInteger:liveGameType] forKey:kLiveGameType];
}

#pragma mark -  token info

+ (NSString *)authToken {
    return [self objectFromKeyChainKey:kUserInfoAuthToken];
}
+ (void)setAuthToken:(NSString *)authToken {
    [self saveToKeyChainObject:authToken forKey:kUserInfoAuthToken];
}

+ (id)objectFromUserDefaultsKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)saveToUserDefaultsObject:(id)object forKey:(NSString *)key {
    if (object && ![object isKindOfClass:[NSNull class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Common Method

+ (void)saveToKeyChainObject:(id)object forKey:(NSString *)key {
    
    if (object && ![object isKindOfClass:[NSNull class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)objectFromKeyChainKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)updateUserDataWithLoginModel:(WYLoginModel *)loginModel
{
    [WYLoginManager sharedManager].loginModel = loginModel;
//    [WYLoginUserManager setAccount:loginModel.mobile];
    [WYLoginUserManager setUsername:loginModel.username];
//    if (loginModel.icon) {
//        loginModel.icon = [NSString stringWithFormat:@"%@!small",loginModel.icon];
//    }
    [WYLoginUserManager setAvatar:loginModel.icon];
    [WYLoginUserManager setAuthToken:loginModel.token];
    [WYLoginUserManager setUserID:loginModel.userID];
    [WYLoginUserManager setTelephone:loginModel.mobile];
    [WYLoginUserManager setFans:loginModel.fans];
    [WYLoginUserManager setRoomId:loginModel.roomNumber];
    [WYLoginUserManager setSex:loginModel.sex];
    [WYLoginUserManager setNickname:loginModel.nickname];
    [WYLoginUserManager setChatRoomId:loginModel.chatRoomId];
    
    
    [WYLoginUserManager setAnchorPushUrl:loginModel.stream_id];
    [WYLoginUserManager setRoomNameTitle:loginModel.anchorTitle];
    [WYLoginUserManager setRoomNoticeTitle:loginModel.anchorDescription];
}

+ (BOOL)hasLogged
{
    return [WYLoginUserManager userID] != nil;
}

+ (void)clearInfo
{
    [WYLoginUserManager setAccount:nil];
    [WYLoginUserManager setUsername:nil];
    [WYLoginUserManager setAvatar:nil];
    [WYLoginUserManager setAuthToken:nil];
    [WYLoginUserManager setUserID:nil];
    [WYLoginUserManager setTelephone:nil];
    [WYLoginUserManager setRoomId:nil];
    [WYLoginUserManager setFans:nil];
    [WYLoginUserManager setSex:nil];
    [WYLoginUserManager setChatRoomId:nil];
    [WYLoginUserManager setLocalNotificationToClose:NO];
    [WYLoginUserManager setAnchorPushUrl:nil];
    
//    [WYLoginUserManager setliveId:nil];
//    [WYLoginUserManager setNickname:nil];
}


@end
