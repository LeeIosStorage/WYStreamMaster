//
//  UIButton+YTLoginButton.m
//  WYTelevision
//
//  Created by zurich on 2016/12/15.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "UIButton+YTLoginButton.h"

@implementation UIButton (YTLoginButton)
@dynamic canClicked;

- (void)setCanClicked:(BOOL)canClicked
{
    if (canClicked) {
        [self buttonCanClickedStatus];
    } else {
        [self buttonNormalStatus];
    }
}

- (void)buttonNormalStatus
{
    self.backgroundColor = [UIColor colorWithHexString:@"9d9d9d"];
    self.userInteractionEnabled = NO;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)buttonCanClickedStatus
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor colorWithHexString:@"ff7e00"];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


@end
