//
//  WYStreamingSessionManager.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/13.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYStreamingSessionManager.h"
#import "WYStreamingConfig.h"

const char *stateNames[] = {
    "Unknow",
    "Connecting",
    "Connected",
    "Disconnecting",
    "Disconnected",
    "AutoReconnecting",
    "Error"
};

@interface WYStreamingSessionManager ()
<
PLMediaStreamingSessionDelegate
>
{
    NSURL *_streamURL;
    PLMediaStreamingSession *_plSession;
}

@end

@implementation WYStreamingSessionManager

- (void)dealloc{
    WYLog(@"%@ dealloc !!!",NSStringFromClass([self class]));
}

- (instancetype)initWithStreamURL:(NSURL *)streamURL;
{
    if (self = [self init]) {
        _streamURL = streamURL;
    }
    return self;
}

- (PLMediaStreamingSession *)streamingSession{
    
    PLStream *stream = nil;
    if(self.plStreamConfig) {
        stream = [PLStream streamWithJSON:self.plStreamConfig];
    }
    [self createStreamingSessionWithSream:stream];
    return _plSession;
}

- (void)startStream{
    if (!_plSession.isStreamingRunning) {
//        if (!_streamURL || !self.plStreamConfig) {
//            [[[UIAlertView alloc] initWithTitle:@"错误" message:@"还没有获取到 streamURL 不能推流哦" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles:nil] show];
//            return;
//        }
        [_plSession startStreamingWithPushURL:_streamURL feedback:^(PLStreamStartStateFeedback feedback) {
            NSString *log = [NSString stringWithFormat:@"session start state %lu",(unsigned long)feedback];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@", log);
                if (PLStreamStartStateSuccess == feedback) {
                    [MBProgressHUD showAlertMessage:@"直播成功" toView:nil];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"错误" message:@"推流失败了" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles:nil] show];
                }
            });
        }];
    }
}

- (void)stopStream{
    [_plSession stopStreaming];
}

- (void)destroyStream{
    [_plSession destroy];
}

#pragma mark -
#pragma mark - Private Methods
- (PLMediaStreamingSession *)createStreamingSessionWithSream:(PLStream *)stream
{
    PLVideoCaptureConfiguration *videoCaptureConfiguration = [[PLVideoCaptureConfiguration alloc]initWithVideoFrameRate:24 sessionPreset:AVCaptureSessionPresetMedium previewMirrorFrontFacing:YES previewMirrorRearFacing:NO streamMirrorFrontFacing:NO streamMirrorRearFacing:NO cameraPosition:AVCaptureDevicePositionFront videoOrientation:AVCaptureVideoOrientationPortrait];
    
    PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
    
    
//    PLVideoStreamingConfiguration *videoStreamConfiguration = [[PLVideoStreamingConfiguration alloc] initWithVideoSize:videoSize expectedSourceVideoFrameRate:24 videoMaxKeyframeInterval:72 averageVideoBitRate:768 * 1024 videoProfileLevel:AVVideoProfileLevelH264HighAutoLevel];
    
    CGSize videoSize = [[WYStreamingConfig sharedConfig] getResolutionWithQuality];
    NSString *videoQuality = kPLVideoStreamingQualityHigh1;// 超清
    if ([[WYStreamingConfig sharedConfig] videoQuality] == VideoQualityStandardDefinition) {
        videoQuality = kPLVideoStreamingQualityLow3;
    } else if ([[WYStreamingConfig sharedConfig] videoQuality] == VideoQualityHighDefinition) {
        videoQuality = kPLVideoStreamingQualityMedium2;
    }
    PLVideoStreamingConfiguration *videoStreamConfiguration = [PLVideoStreamingConfiguration configurationWithVideoQuality:videoQuality];
    videoStreamConfiguration.videoSize = videoSize;
    
    PLAudioStreamingConfiguration *audioSreamConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
    
    
    _plSession = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration
                                                        audioCaptureConfiguration:audioCaptureConfiguration
                                                      videoStreamingConfiguration:videoStreamConfiguration
                                                      audioStreamingConfiguration:audioSreamConfiguration
                                                                           stream:stream];
    _plSession.delegate = self;
    _plSession.autoReconnectEnable = YES;
    [_plSession setBeautifyModeOn:YES];
    [_plSession setBeautify:0.5];
    [_plSession setWhiten:0.5];
//    [_plSession setRedden:1.0];
//    UIImage *waterImage = [UIImage imageNamed:@"logo_logo_icon"];
//    [_plSession setWaterMarkWithImage:waterImage position:CGPointMake(100, 100)];
    
    return _plSession;
}

#pragma mark - 
#pragma mark - PLMediaStreamingSessionDelegate
/// @abstract 流状态已变更的回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStateDidChange:(PLStreamState)state{
    
    NSString *log = [NSString stringWithFormat:@"Stream State:__ %s", stateNames[state]];
    NSLog(@"%@", log);
    
    if (PLStreamStateConnected == state) {
        if ([self.delegate respondsToSelector:@selector(streamingManager:pushStreamStatusChanged:)]) {
            [self.delegate streamingManager:self pushStreamStatusChanged:state];
        }
    }
}

- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didDisconnectWithError:(NSError *)error{
    /// @abstract 因产生了某个 error 而断开时的回调，error 错误码的含义可以查看 PLTypeDefines.h 文件
    /// 断开需重新连接
    
    NSString *log = [NSString stringWithFormat:@"didDisconnectWithError: %@", [error localizedDescription ]];
    NSLog(@"%@", log);
    [MBProgressHUD showAlertMessage:log toView:nil];
}

- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status{
    /// @abstract 当开始推流时，会每间隔 3s 调用该回调方法来反馈该 3s 内的流状态，包括视频帧率、音频帧率、音视频总码率
    ///自定义码率调节
    NSLog(@"~~~~~~~~~streamStatusDidUpdate: %@", status);
}

- (void)mediaStreamingSession:(PLMediaStreamingSession *)session rtcDidFailWithError:(NSError *)error{
    NSString *log = [NSString stringWithFormat:@"rtcDidFailWithError: %@", [error localizedDescription]];
    NSLog(@"%@", log);
}

@end
