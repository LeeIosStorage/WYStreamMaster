//
//  WYRefreshFooter.m
//  WYTelevision
//
//  Created by Jyh on 16/9/11.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYRefreshFooter.h"
NSString *const MJRefreshBackFooterNoMoreDataText = @"已经全部加载完毕";
NSString *const MJRefreshBackFooterRefreshingText = @"正在加载更多的数据...";
NSString *const MJRefreshBackFooterIdleText = @"上拉可以加载更多";
NSString *const MJRefreshBackFooterPullingText = @"松开立即加载更多";

@interface WYRefreshFooter ()

@property (weak, nonatomic) UIActivityIndicatorView *loading;

@end

@implementation WYRefreshFooter



- (void)prepare
{
    [super prepare];

    self.stateLabel.textColor = [UIColor colorWithHexString:@"FEFFFF"];
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
}
@end
