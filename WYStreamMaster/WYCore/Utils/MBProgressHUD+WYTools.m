//
//  MBProgressHUD+WYTools.m
//  WYTelevision
//
//  Created by Leejun on 16/8/29.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "MBProgressHUD+WYTools.h"

#define bezelView_bg_color [UIColor clearColor]//colorWithHexString:@"323A43"

@implementation MBProgressHUD (WYTools)

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view isBottom:(BOOL)isBottom
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [MBProgressHUD hideHUDForView:view];
    
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabel.text = text;
    hud.contentColor = [UIColor whiteColor];
    hud.detailsLabel.font = [UIFont systemFontOfSize:14];
    
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = bezelView_bg_color;
    //高斯模糊
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [hud.bezelView addSubview:effectView];
        [hud.bezelView insertSubview:effectView atIndex:0];
        effectView.frame = hud.bezelView.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    hud.animationType = MBProgressHUDAnimationZoomOut;
    
    if (icon) {
        // 设置图片
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
        // 再设置模式
        hud.mode = MBProgressHUDModeCustomView;
    }else{
        hud.mode = MBProgressHUDModeText;
    }
    if (isBottom) {
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        hud.margin = 10;
        hud.detailsLabel.font = [UIFont systemFontOfSize:14];
    }
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    NSInteger length = text.length;
    NSTimeInterval delay = length*0.04 + 1.5;
    
    [hud hideAnimated:YES afterDelay:delay];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"common_error_icon" view:view isBottom:NO];
}

#pragma mark 显示成功信息
+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"common_success_icon" view:view isBottom:NO];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.contentColor = [UIColor whiteColor];
    hud.label.font = [UIFont systemFontOfSize:14];
    
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = bezelView_bg_color;
    //高斯模糊
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [hud.bezelView addSubview:effectView];
        [hud.bezelView insertSubview:effectView atIndex:0];
        effectView.frame = hud.bezelView.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    //hud.dimBackground = YES;
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

+ (void)showAlertMessage:(NSString *)message toView:(UIView *)view
{
    [self show:message icon:nil view:view isBottom:NO];
}

#pragma mark - 底部提示
+ (void)showBottomMessage:(NSString *)message toView:(UIView *)view{
    
    [self show:message icon:nil view:view isBottom:YES];
}

@end
