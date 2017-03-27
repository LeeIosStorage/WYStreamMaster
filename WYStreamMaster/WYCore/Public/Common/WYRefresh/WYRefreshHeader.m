//
//  WYRefreshHeader.m
//  WYTelevision
//
//  Created by Jyh on 16/9/11.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYRefreshHeader.h"


NSString *const WYRefreshHeaderIdleText = @"下拉可以刷新    ";
NSString *const WYRefreshHeaderPullingText = @"松开立即刷新    ";
NSString *const WYRefreshHeaderRefreshingText = @"正在刷新数据中";

@implementation WYRefreshHeader

- (void)prepare
{
    [super prepare];
    
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=9; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_00%zd", i]];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages forState:MJRefreshStateIdle];
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
    // 隐藏时间Label
    self.lastUpdatedTimeLabel.hidden = YES;
    self.stateLabel.textColor = [UIColor colorWithHexString:@"FEFFFF"];
    
    // 初始化文字
    [self setTitle:WYRefreshHeaderIdleText forState:MJRefreshStateIdle];
    [self setTitle:WYRefreshHeaderPullingText forState:MJRefreshStatePulling];
    [self setTitle:WYRefreshHeaderRefreshingText forState:MJRefreshStateRefreshing];
}
@end
