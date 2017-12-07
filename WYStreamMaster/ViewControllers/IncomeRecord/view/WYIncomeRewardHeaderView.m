//
//  YTClassifyBottomView.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYIncomeRewardHeaderView.h"

@interface WYIncomeRewardHeaderView ()

@end

@implementation WYIncomeRewardHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (IBAction)clickCurrencyButton:(UIButton *)sender {
    for (UIView* subView in self.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            if (button.tag == sender.tag) {
                [self selectedCurrencyButton:sender];
                if ([self.delegate respondsToSelector:@selector(clickCurrencyButtonDelegate:)]) {
                    [self.delegate clickCurrencyButtonDelegate:sender.titleLabel.text];
                }
            } else {
                [self normalCurrencyButton:button];
            }
        }
    }
}

-(void)normalCurrencyButton:(UIButton *)button
{
    button.backgroundColor = [UIColor whiteColor];
}

-(void)selectedCurrencyButton:(UIButton *)button
{
    button.backgroundColor = [UIColor colorWithHexString:@"ffcc00"];
    
}

@end
