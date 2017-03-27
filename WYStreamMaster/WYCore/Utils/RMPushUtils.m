//
//  RMPushUtils.m
//  WYRecordMaster
//
//  Created by Jyh on 2016/11/8.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "RMPushUtils.h"

@interface RMPushUtils ()


@end

@implementation RMPushUtils

+ (UILocalNotification *)setLocalNotification:(NSDate *)fireDate
                                    alertBody:(NSString *)alertBody
                                        badge:(int)badge
                                  alertAction:(NSString *)alertAction
                                identifierKey:(NSString *)notificationKey
                                     userInfo:(NSDictionary *)userInfo
                                    soundName:(NSString *)soundName
{
    // 初始化本地通知
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    // 通知触发时间
    localNotification.fireDate = fireDate ? fireDate : nil;
    // 触发后，弹出警告框中显示的内容
    localNotification.alertBody = alertBody;
    // 需要在App icon上显示的未读通知数（设置为1时，多个通知未读，系统会自动加1，如果不需要显示未读数，这里可以设置0）
    localNotification.applicationIconBadgeNumber = badge > 0 ? badge : 0;
    // 触发时的声音（这里选择的系统默认声音）
    //设置通知动作按钮的标题
    localNotification.alertAction = alertAction;
    // 设置通知的key
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:alertBody forKey:notificationKey];
    localNotification.userInfo = userDict;
    //设置提醒的声音，可以自己添加声音文件，默认为系统提示声
    localNotification.soundName = soundName ? soundName :UILocalNotificationDefaultSoundName;
    localNotification.userInfo = userInfo;
    // 触发频率（repeatInterval是一个枚举值，可以选择每分、每小时、每天、每年等）
    localNotification.repeatInterval = 0;
    
    return localNotification;
}


+ (void)cancelLocalNotificationWithKey:(NSString *)key
{
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    if (localNotifications) {
        for (UILocalNotification *notification in localNotifications) {
            NSDictionary *userInfo = notification.userInfo;
            if (userInfo) {
                // 根据设置通知参数时指定的key来获取通知参数
                NSString *info = userInfo[key];
                // 如果找到需要取消的通知，则取消
                if ([info isEqualToString:key]) {
                    if (notification) {
                        [[UIApplication sharedApplication] cancelLocalNotification:notification];
                    }
                    break;
                }
            }
        }
    }
}
@end
