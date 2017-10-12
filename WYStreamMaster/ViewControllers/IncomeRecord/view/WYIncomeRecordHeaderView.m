//
//  YTClassifyBottomView.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYIncomeRecordHeaderView.h"

@interface WYIncomeRecordHeaderView ()

@end

@implementation WYIncomeRecordHeaderView

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
