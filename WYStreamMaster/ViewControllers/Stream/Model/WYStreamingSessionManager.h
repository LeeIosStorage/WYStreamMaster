//
//  WYStreamingSessionManager.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/13.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>

@protocol WYStreamingSessionManagerDelegate;

@interface WYStreamingSessionManager : NSObject

@property (strong, nonatomic) NSDictionary *plStreamConfig;

@property (nonatomic, assign) id<WYStreamingSessionManagerDelegate> delegate;

- (instancetype)initWithStreamURL:(NSURL *)streamURL;
- (PLMediaStreamingSession *)streamingSession;

- (void)startStream;
- (void)stopStream;
- (void)destroyStream;

@end

@protocol WYStreamingSessionManagerDelegate <NSObject>

/**
 推流状态变化回调
 
 @param manager 录制视频管理器
 @param state 七牛流状态
 */
- (void)streamingManager:(WYStreamingSessionManager *)manager pushStreamStatusChanged:(PLStreamState)state;

@end
