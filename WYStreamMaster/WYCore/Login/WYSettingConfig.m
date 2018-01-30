//
//  WYSettingConfig.m
//  WYTelevision
//
//  Created by Leejun on 16/8/25.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYSettingConfig.h"

@interface WYSettingConfig (){
    
    NSTimer *_waitLoginTimer;
    int _waitLoginSecond;
    
    NSTimer *_waitRegisterTimer;
    int _waitRegisterSecond;
    
}

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation WYSettingConfig

+(WYSettingConfig *)staticInstance
{
    static WYSettingConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)logout {
    if (_waitLoginTimer) {
        [_waitLoginTimer invalidate];
        _waitLoginTimer = nil;
    }
    if (_waitRegisterTimer) {
        [_waitRegisterTimer invalidate];
        _waitRegisterTimer = nil;
    }
}


-(void)addLoginTimer{
    if(_waitLoginTimer){
        [_waitLoginTimer invalidate];
        _waitLoginTimer = nil;
    }
    
    _waitLoginTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitLoginTimerInterval:) userInfo:nil repeats:YES];
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    _waitLoginSecond = 60;
    [self waitLoginTimerInterval:_waitLoginTimer];
}
-(void)removeLoginTimer{
    if(_waitLoginTimer){
        [_waitLoginTimer invalidate];
        _waitLoginTimer = nil;
        [self setBackgroundTaskInvalid];
    }
    _waitLoginSecond = 0;
    if ([_settingDelegater respondsToSelector:@selector(waitLoginTimer:waitSecond:)]) {
        [_settingDelegater waitLoginTimer:nil waitSecond:_waitLoginSecond];
    }
}
-(int)getLoginSecond{
    int second = _waitLoginSecond;
    if (second <= 0) {
        second = 0;
    }
    return second;
}
- (void)waitLoginTimerInterval:(NSTimer *)aTimer{
//    WYLog(@"a Timer with WYSettingConfig waitLoginTimerInterval = %d",_waitLoginSecond);
    if (_waitLoginSecond <= 0) {
        [aTimer invalidate];
        _waitLoginTimer = nil;
        [self setBackgroundTaskInvalid];
    }
    _waitLoginSecond--;
    if ([_settingDelegater respondsToSelector:@selector(waitLoginTimer:waitSecond:)]) {
        [_settingDelegater waitLoginTimer:nil waitSecond:_waitLoginSecond];
    }
}


-(void)addRegisterTimer{
    if(_waitRegisterTimer){
        [_waitRegisterTimer invalidate];
        _waitRegisterTimer = nil;
    }
    
    _waitRegisterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitRegisterTimerInterval:) userInfo:nil repeats:YES];
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    _waitRegisterSecond = 60;
    [self waitRegisterTimerInterval:_waitRegisterTimer];
}
-(void)removeRegisterTimer{
    if(_waitRegisterTimer){
        [_waitRegisterTimer invalidate];
        _waitRegisterTimer = nil;
        [self setBackgroundTaskInvalid];
    }
    _waitRegisterSecond = 0;
    if ([_settingDelegater respondsToSelector:@selector(waitRegisterTimer:waitSecond:)]) {
        [_settingDelegater waitRegisterTimer:nil waitSecond:_waitRegisterSecond];
    }
}
-(int)getRegisterSecond{
    int second = _waitRegisterSecond;
    if (second <= 0) {
        second = 0;
    }
    return second;
}
- (void)waitRegisterTimerInterval:(NSTimer *)aTimer{
//    WYLog(@"a Timer with WYSettingConfig waitRegisterTimerInterval = %d",_waitRegisterSecond);
    if (_waitRegisterSecond <= 0) {
        [aTimer invalidate];
        _waitRegisterTimer = nil;
        [self setBackgroundTaskInvalid];
    }
    _waitRegisterSecond--;
    if ([_settingDelegater respondsToSelector:@selector(waitRegisterTimer:waitSecond:)]) {
        [_settingDelegater waitRegisterTimer:nil waitSecond:_waitRegisterSecond];
    }
}

- (void)setBackgroundTaskInvalid{
    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
    _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

@end
