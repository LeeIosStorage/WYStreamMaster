//
//  UIButton+YTCodeVerify.m
//  WYTelevision
//
//  Created by zurich on 2016/12/15.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#define CodeVerify_Time 60

#import "UIButton+YTCodeVerify.h"


@implementation UIButton (YTCodeVerify)
@dynamic startCodeVerigyTime;

- (void)setStartCodeVerigyTime:(BOOL)startCodeVerigyTime
{
    if (startCodeVerigyTime) {
        [self startWithTime:CodeVerify_Time title:@"重新发送" countDownTitle:@"s" mainColor:[UIColor colorWithHexString:@"FF3566"] countColor:[UIColor colorWithHexString:@"7A92AD"]];
    } else {
        
    }
}


- (void)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color {
    
    __weak typeof(self) weakSelf = self;
    //倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        //倒计时结束，关闭
        if (timeOut <= 0) {
          
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.backgroundColor = [UIColor colorWithHexString:@"FF3566"];
                [weakSelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [weakSelf setTitle:title forState:UIControlStateNormal];
                weakSelf.userInteractionEnabled = YES;
                
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                int allTime = (int)timeLine + 1;
                int seconds = timeOut % allTime;
                NSString *timeStr = [NSString stringWithFormat:@"%d", seconds];
                [weakSelf setTitle:[NSString stringWithFormat:@"%@%@",timeStr,subTitle] forState:UIControlStateNormal];
                weakSelf.userInteractionEnabled = NO;
                timeOut--;
            });
            
        }
    });
    dispatch_resume(_timer);
}

@end
