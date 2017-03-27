//
//  RMPushUtils.h
//  WYRecordMaster
//
//  Created by Jyh on 2016/11/8.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMPushUtils : NSObject

/**
 自定义本地推送
 iOS最多允许最近本地通知数量是64个，超过限制的本地通知将被iOS忽略
 
 @param fireDate 本地推送触发时间
 @param alertBody 本地推送显示内容
 @param badge 角标数字，如果不需要传-1
 @param alertAction 弹框的按钮显示的内容（IOS 8默认为"打开",其他默认为"启动"）
 @param notificationKey 本地推送标识符
 @param userInfo 自定义参数字典
 @param soundName 自定义通知声音，设置为nil为默认声音
 @return 返回自定义的本地推送对象
 */
+ (UILocalNotification *)setLocalNotification:(NSDate *)fireDate
                                    alertBody:(NSString *)alertBody
                                        badge:(int)badge
                                  alertAction:(NSString *)alertAction
                                identifierKey:(NSString *)notificationKey
                                     userInfo:(NSDictionary *)userInfo
                                    soundName:(NSString *)soundName;


/**
 取消通知

 @param key 通知的key
 */
+ (void)cancelLocalNotificationWithKey:(NSString *)key;

@end
