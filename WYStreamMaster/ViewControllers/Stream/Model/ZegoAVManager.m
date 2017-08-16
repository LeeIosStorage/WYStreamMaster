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

@interface ZegoHelper ()

@end

@implementation ZegoHelper

+ (ZegoLiveRoomApi *)api{
    
    if (g_ZegoApi == nil) {
        
        [ZegoLiveRoomApi setUseTestEnv:YES];
//        [ZegoLiveRoomApi prepareReplayLiveCapture];
//        [ZegoLiveRoomApi enableExternalRender:[self usingExternalRender]];
        
#ifdef DEBUG
        [ZegoLiveRoomApi setVerbose:YES];
#endif
//        
//        [self setupVideoCaptureDevice];
//        [self setupVideoFilter];
        
        [ZegoLiveRoomApi setUserID:[WYLoginUserManager userID] userName:[WYLoginUserManager nickname]];//[WYLoginUserManager nickname]
        
//        [ZegoHelper setUsingExternalCapture];
        
        uint32_t appID = 1196318866;//
        if (appID > 0) {    // 手动输入为空的情况下容错
            NSData *appSign = [self getZegoAppSign];
            if (appSign) {
                g_ZegoApi = [[ZegoLiveRoomApi alloc] initWithAppID:appID appSignature:appSign];
            }
        }
        
        [ZegoLiveRoomApi requireHardwareDecoder:YES];
        [ZegoLiveRoomApi requireHardwareEncoder:YES];
        
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
    CGSize videoSize = CGSizeMake(720, 1280);
    config.videoEncodeResolution = CGSizeMake(videoSize.width,videoSize.height);
    config.videoCaptureResolution = config.videoEncodeResolution;
    [[ZegoHelper api] setAVConfig:config];
    [[ZegoHelper api] enableBeautifying:ZEGO_BEAUTIFY_POLISH | ZEGO_BEAUTIFY_WHITEN];
    [[ZegoHelper api] setFrontCam:YES];
    [[ZegoHelper api] enableRateControl:YES];//开启码率控制
    
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
            
            bool b = [[ZegoHelper api] startPublishing:streamID title:liveTitle flag:ZEGOAPI_SINGLE_ANCHOR];
            if (b){
                WYLog(@"%@",[NSString stringWithFormat:NSLocalizedString(@"开始直播，流ID:%@", nil),streamID]);
            }
        }
        else
        {
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间失败. error: %d", nil), errorCode];
            WYLog(@"%@",logString);
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

@end
