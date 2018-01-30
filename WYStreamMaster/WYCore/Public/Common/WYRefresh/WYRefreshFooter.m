//
//  WYRefreshFooter.m
//  WYTelevision
//
//  Created by Jyh on 16/9/11.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYRefreshFooter.h"

@interface WYRefreshFooter ()

@property (weak, nonatomic) UIActivityIndicatorView *loading;

@end

@implementation WYRefreshFooter



- (void)prepare
{
    [super prepare];

    self.stateLabel.textColor = [UIColor colorWithHexString:@"666666"];
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
}
@end
