//
//  WYServerNoticeAttachment.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/4/8.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTCustomMessageDefines.h"

#define WYServerNoticeAttachment_Notification @"WYServerNoticeAttachment_Notification"

@interface WYServerNoticeAttachment : NSObject <NIMCustomAttachment>

@property (nonatomic, assign) YTCustomMessageType customMessageType;

@property (nonatomic, assign) NSInteger onlineNum;//在线人数

@property (nonatomic, assign) NSInteger gameStatus;//游戏状态

@property (nonatomic, strong) id contentData;//押注排行或者游戏结果

@end
