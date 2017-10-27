//
//  ZegoAVManager.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/8/8.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "ZegoAVManager.h"
//#import <ZegoLiveRoom/ZegoLiveRoomApi-AudioIO.h>

static ZegoLiveRoomApi *g_ZegoApi = nil;

static __strong id<ZegoVideoCaptureFactory> g_factory = NULL;

@interface ZegoHelper () <ZegoRoomDelegate>

@end

@implementation ZegoHelper

+ (ZegoLiveRoomApi *)api{
    
    if (g_ZegoApi == nil) {

        [ZegoLiveRoomApi setUseTestEnv:false];
//        [ZegoLiveRoomApi prepareReplayLiveCapture];
        
#ifdef DEBUG
        [ZegoLiveRoomApi setVerbose:YES];
#endif
//        
//        [self setupVideoCaptureDevice];
//        [self setupVideoFilter];
        
        [ZegoLiveRoomApi setUserID:[WYLoginUserManager userID] userName:[WYLoginUserManager nickname]];//[WYLoginUserManager nickname]
        
//        [ZegoHelper setUsingExternalCapture];
        
        uint32_t appID = 1196318866;//
        if (appID > 0) {    //  手动输入为空的情况下容错
            NSData *appSign = [self getZegoAppSign];
            if (appSign) {
                g_ZegoApi = [[ZegoLiveRoomApi alloc] initWithAppID:appID appSignature:appSign];
            }
        }
        
//        [ZegoLiveRoomApi requireHardwareDecoder:YES];
//        [ZegoLiveRoomApi requireHardwareEncoder:YES];
        
        [g_ZegoApi enableTrafficControl:YES properties:ZEGOAPI_TRAFFIC_FPS | ZEGOAPI_TRAFFIC_RESOLUTION];
    }
    
    return g_ZegoApi;
    
}


+ (NSData *)getZegoAppSign
{
    Byte signkey[] = {0x0e,0x5d,0x53,0x13,0x4e,0xf0,0x86,0xa4,0x66,0x43,0x13,0xab,0xd2,0x32,0x98,0xd0,0x34,0x49,0x78,0xdd,0x22,0xe8,0xa8,0xe2,0x85,0x6d,0x26,0x9c,0x3d,0x04,0x71,0x96};
    return [NSData dataWithBytes:signkey length:32];
}

+ (void)setAnchorConfig:(UIView *)publishView{

    ZegoAVConfig *config = [ZegoAVConfig presetConfigOf:ZegoAVConfigPreset_High];
    CGSize videoSize = CGSizeMake(360, 640);
    config.videoEncodeResolution = CGSizeMake(videoSize.width,videoSize.height);
    config.videoCaptureResolution = config.videoEncodeResolution;
    config.fps = 15;
    config.bitrate = 650000;
    //fps 15
    //bitrate 800000
    
    [[ZegoHelper api] setAVConfig:config];
    [[ZegoHelper api] enableBeautifying:ZEGO_BEAUTIFY_POLISH | ZEGO_BEAUTIFY_WHITEN | ZEGO_BEAUTIFY_SKINWHITEN];
    [[ZegoHelper api] setPolishStep:2.0];
    [[ZegoHelper api] setPolishFactor:4.0];
    [[ZegoHelper api] setWhitenFactor:0.5];
    
    [[ZegoHelper api] setFrontCam:YES];
//    [[ZegoHelper api] enableRateControl:YES];//开启码率控制
    
//    [[ZegoHelper api] enableCamera:NO];
//    [[ZegoHelper api] enableCaptureMirror:YES];
//    [[ZegoHelper api] enablePreviewMirror:NO];
    
    [[ZegoHelper api] setPreviewView:publishView];
    [[ZegoHelper api] setPreviewViewMode:ZegoVideoViewModeScaleAspectFill];
    [[ZegoHelper api] startPreview];
    [ZegoHelper loginChatRoom];
}

+ (void)loginChatRoom
{
    NSString *roomID = [NSString stringWithFormat:@"roomId:%@", [WYLoginUserManager roomId]];
//    unsigned long currentTime = (unsigned long)[[NSDate date] timeIntervalSince1970];
    NSString *streamID = [NSString stringWithFormat:@"%@", [WYLoginUserManager anchorPushUrl]];
    NSString *liveTitle = [WYLoginUserManager nickname];
    
    [[ZegoHelper api] loginRoom:roomID role:ZEGO_ANCHOR  withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
        
        NSLog(@"%s, error: %d", __func__, errorCode);
        if (errorCode == 0)
        {
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间成功. roomId %@", nil), roomID];
            WYLog(@"%@",logString);
            
            bool b = [[ZegoHelper api] startPublishing:streamID title:liveTitle flag:ZEGOAPI_JOIN_PUBLISH];
            if (b){
                WYLog(@"%@",[NSString stringWithFormat:NSLocalizedString(@"开始直播，流ID:%@", nil),streamID]);
            }
        }
        else
        {
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间失败. error: %d", nil), errorCode];
            WYLog(@"logStringlogString%@",logString);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WYNotificationWSDisConnect object:nil];
        }
    }];
}

+ (void)setUsingExternalCapture
{
    if (g_factory == nil)
        g_factory = [[VideoCaptureFactoryDemo alloc] init];
    [ZegoLiveRoomApi setVideoCaptureFactory:g_factory];
}

+ (VideoCaptureFactoryDemo *)getVideoCaptureFactory
{
    return g_factory;
}

- (void)audioSessionWasInterrupted:(NSNotification *)notification
{
    NSLog(@"%s: %@", __func__, notification);
    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        // 暂停音频设备
        [[ZegoHelper api] pauseModule:ZEGOAPI_MODULE_AUDIO];
    }
    else if(AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        // 恢复音频设备
        [[ZegoHelper api] resumeModule:ZEGOAPI_MODULE_AUDIO];
    }
}

@end
