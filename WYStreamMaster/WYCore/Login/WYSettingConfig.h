//
//  WYSettingConfig.h
//  WYTelevision
//
//  Created by Leejun on 16/8/25.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingConfigChangeD;

@interface WYSettingConfig : NSObject

@property (nonatomic, weak)id<SettingConfigChangeD> settingDelegater;

+(WYSettingConfig *)staticInstance;

- (void)logout;


//登录时验证码倒计时
-(void)addLoginTimer;
-(void)removeLoginTimer;
-(int)getLoginSecond;

//注册
-(void)addRegisterTimer;
-(void)removeRegisterTimer;
-(int)getRegisterSecond;

@end

@protocol SettingConfigChangeD <NSObject>
@optional
//验证码登录
- (void)waitLoginTimer:(NSTimer *)aTimer waitSecond:(int)waitSecond;
- (void)waitRegisterTimer:(NSTimer *)aTimer waitSecond:(int)waitSecond;

@end
