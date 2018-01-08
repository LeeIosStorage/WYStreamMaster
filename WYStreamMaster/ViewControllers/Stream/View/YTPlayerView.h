//
//  YTPlayerView.h
//  RainbowLive
//
//  Created by Jyh on 2017/5/22.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLPlayerKit/PLPlayerKit.h>

@protocol YTPlayerStatusDelegate <NSObject>

- (void)playerStatus:(PLPlayerStatus )status;

@end


@interface YTPlayerView : UIView

@property (strong, nonatomic) NSURL *playURL;

@property (weak, nonatomic) id <YTPlayerStatusDelegate>delegate;

- (instancetype)initWithWithURL:(NSURL *)url;

- (void)startPlayer;

- (void)play;
- (void)pause;
- (BOOL)isStopped;

@end
