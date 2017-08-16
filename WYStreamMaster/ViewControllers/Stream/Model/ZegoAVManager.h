//
//  ZegoAVManager.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/8/8.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import "video_capture_external_demo.h"

@interface ZegoHelper : NSObject

+ (ZegoLiveRoomApi *)api;
+ (VideoCaptureFactoryDemo *)getVideoCaptureFactory;

+ (void)loginChatRoom;

// 设置主播配置
+ (void)setAnchorConfig:(UIView *)publishView;

@end
