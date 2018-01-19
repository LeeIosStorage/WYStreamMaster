//
//  HHCountdowLabel.m
//  HHCountdown
//
//  Created by chh on 2017/7/27.
//  Copyright © 2017年 chh. All rights reserved.
//

#import "HHCountdowLabel.h"
@interface HHCountdowLabel()
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HHCountdowLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.font = [UIFont systemFontOfSize:40];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}
//开始倒计时
- (void)startCount{
    [self initTimer];
}

- (void)initTimer{
    //如果没有设置，则默认为3
    if (self.count == 0){
        self.count = 3;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
}

- (void)countDown{
    CAKeyframeAnimation *anima2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    //字体变化大小
    NSValue *value1 = [NSNumber numberWithFloat:1.2f];
    NSValue *value2 = [NSNumber numberWithFloat:1.1f];
    NSValue *value3 = [NSNumber numberWithFloat:0.9f];
    NSValue *value4 = [NSNumber numberWithFloat:1.0f];
    anima2.values = @[value1,value2,value3,value4];
    anima2.duration = 0.5;
    [self.layer addAnimation:anima2 forKey:@"scalsTime"];
}

@end
