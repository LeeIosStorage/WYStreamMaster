//
//  YTCustomMessageDefines.h
//  WYTelevision
//
//  Created by zurich on 2016/9/23.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#ifndef YTCustomMessageDefines_h
#define YTCustomMessageDefines_h
typedef NS_ENUM(NSInteger,YTCustomMessageType){
    CustomMessageTypeGift  = 1, //礼物
    CustomMessageTypeLocalNotification,//房间消息
    CustomMessageTypeBetRank,//押注排行 服务器下发
    CustomMessageTypeGameResult,//游戏结果 服务器下发
};

#define CMType  @"type"
#define CMData  @"data"

#endif /* YTCustomMessageDefines_h */
