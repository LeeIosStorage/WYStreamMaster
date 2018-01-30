//
//  YTPlayerView.m
//  RainbowLive
//
//  Created by Jyh on 2017/5/22.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTPlayerView.h"

static NSString *status[] = {
    @"PLPlayerStatusUnknow",
    @"PLPlayerStatusPreparing",
    @"PLPlayerStatusReady",
    @"PLPlayerStatusCaching",
    @"PLPlayerStatusPlaying",
    @"PLPlayerStatusPaused",
    @"PLPlayerStatusStopped",
    @"PLPlayerStatusError"
};

@interface YTPlayerView ()
<
PLPlayerDelegate
>

/** 重连次数 */
@property (assign, nonatomic) int reconnectCount;

@property (nonatomic, strong) PLPlayer  *player;

@end

@implementation YTPlayerView

- (void)dealloc
{
    // 设置屏幕不常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        [self setupPlayerView];
    }
    return self;
}

- (instancetype)initWithWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.playURL = url;
        
        [self setupPlayerView];
    }
    return self;
}


- (void)setupPlayerView
{
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 初始化重连次数
    self.reconnectCount = 0;
    
    [self configPlayer];
    
}

- (void)configPlayer
{
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    [option setOptionValue:@10 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    [option setOptionValue:[NSNumber numberWithUnsignedInteger:kPLLogWarning] forKey:PLPlayerOptionKeyLogLevel];
    if (!self.player && self.playURL) {
        self.player = [PLPlayer playerWithURL:self.playURL option:option];
    }
    self.player.delegate = self;
    self.player.delegateQueue = dispatch_get_main_queue();
    // 自动重连
//    self.player.autoReconnectEnable = YES;
    
    if (self.player.status != PLPlayerStatusError) {
        // add player view
        UIView *playerView = self.player.playerView;
        if (!playerView.superview) {
            playerView.contentMode = UIViewContentModeScaleAspectFit;
            playerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
            | UIViewAutoresizingFlexibleTopMargin
            | UIViewAutoresizingFlexibleLeftMargin
            | UIViewAutoresizingFlexibleRightMargin
            | UIViewAutoresizingFlexibleWidth
            | UIViewAutoresizingFlexibleHeight;
            
            [self insertSubview:playerView atIndex:0];
        }
        
        if (playerView) {
            playerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
    }
    
    // 强制让系统调用layoutSubviews 两个方法必须同时写
    [self setNeedsLayout]; //是标记 异步刷新 会调但是慢
    [self layoutIfNeeded]; //加上此代码立刻刷新
    
    [self play];
}

- (void)play
{
    // 设置屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self.player play];
}

- (void)pause
{
    // 设置屏幕不常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.player pause];
}

- (BOOL)isStopped
{
    return (self.player.status == PLPlayerStatusPaused || self.player.status == PLPlayerStatusStopped);
}

#pragma mark
#pragma mark - LayoutSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.player.playerView.frame = self.bounds;
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    // fix iOS7 crash bug
    [self layoutIfNeeded];
}

- (void)startPlayer
{
    [self configPlayer];
}

// 重连机制
- (void)playerTryReconnect:(nullable NSError *)error
{
    if (self.reconnectCount < 2) {
        _reconnectCount ++;
        
        WEAKSELF
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*pow(2, self.reconnectCount) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf play];
        });
    }
}

#pragma mark - <PLPlayerDelegate>

- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    if (PLPlayerStatusCaching == state) {
//        [self.activityIndicatorView startAnimating];
    } else if (PLPlayerStatusPaused == state || PLPlayerStatusError == state){
//        [self.activityIndicatorView stopAnimating];
        // 取消屏幕常亮
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
//    BLYLog(BuglyLogLevelInfo, @"____播放器状态改变 %@", status[state]);
    WYLog( @"____播放器状态改变 %@", status[state]);
//    [(YTLivingViewController *)self.viewController toShowDefualtImage:state];

}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    
    WYLog(@"____播放器状态错误 %@", error);
//    BLYLog(BuglyLogLevelInfo, @"____播放器状态错误 %@", error);
//    [(YTLivingViewController *)self.viewController toShowDefualtImage:PLPlayerStatusPreparing];
//    [self.activityIndicatorView stopAnimating];
    [self playerTryReconnect:error];
}


@end
