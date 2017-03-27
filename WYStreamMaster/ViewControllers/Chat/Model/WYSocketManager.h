//
//  WYSocketManager.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/17.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketRocket.h"

@interface WYSocketManager : NSObject

@property (strong, nonatomic, readonly) SRWebSocket *webSocket;

+ (WYSocketManager *)sharedInstance;
- (void)initSocketURL:(NSURL *)url;

//发送消息
- (void)sendData:(id)data;

@end
