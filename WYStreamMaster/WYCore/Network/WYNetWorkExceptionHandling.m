//
//  WYNetWorkExceptionHandling.m
//  WYTelevision
//
//  Created by zurich on 16/9/10.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYNetWorkExceptionHandling.h"
#import "WYLoginManager.h"
#import "WYNavigationController.h"
#import "WYSuperViewController.h"

@implementation WYNetWorkExceptionHandling

+ (BOOL)judgeReuqestStatus:(WYRequestType )type
{
    switch (type) {
        case WYRequestTypeSuccess:
    
            break;
        case WYRequestTypeTokenInvalid:
        case WYRequestTypeNotLogin:
            [WYNetWorkExceptionHandling reLogin];
            
            break;
        default:
            
            break;
    }
    return YES;
}

+ (void)reLogin
{
    if(![WYLoginManager sharedManager].isShowLogin)
    {
       __block WYSuperViewController *currentController = [WYNetWorkExceptionHandling getCurrentVC];
        [[WYLoginManager sharedManager] showLoginViewControllerFromViewController:currentController showCancelButton:YES success:^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUINotificationKey object:nil];
//            [currentController refreshViewWithObject:nil];
        } failure:^(NSString *errorMessage) {
            
        } cancel:^{
            
        }];
    }
}

+ (WYSuperViewController *)getCurrentVC
{
    WYSuperViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UITabBarController class]]) {
        NSInteger index = ((UITabBarController *)nextResponder).selectedIndex;
        WYNavigationController *nav = [(UITabBarController *)nextResponder viewControllers][index];
        nextResponder = [nav.viewControllers lastObject];
    } else if ([nextResponder isKindOfClass:[UINavigationController class]])
    {
        id currentViewController = [((UINavigationController *)nextResponder) viewControllers].lastObject;
        if ([currentViewController isKindOfClass:[UIViewController class]]) {
            nextResponder = currentViewController;
        }
    }
    if ([nextResponder isKindOfClass:[WYSuperViewController class]])
    {
        
        //如果没有登录而且在关注页面调起接口的时候，先暂时不弹登录
//        if ([nextResponder isKindOfClass:[YTAttentionViewController class]]) {
//            YTAttentionViewController *attentionVC = (YTAttentionViewController *)nextResponder;
//            NSInteger count = attentionVC.showLoginCount;
//            if (count == 1) {
//                return nextResponder;
//            } else {
//                return nil;
//            }
//        } else {
//            if (![[WYLoginManager sharedManager] hasAccoutLoggedin] && ([nextResponder isKindOfClass:[YTHomeViewController class]] || [nextResponder isKindOfClass:[YTAttentionViewController class]])) {
//                return nil;
//            }
//            if ([nextResponder isKindOfClass:[YTHomeViewController class]] || [nextResponder isKindOfClass:[YTAttentionViewController class]]) {
//                return nil;
//            }
//
//        }
    }
    
    
    result = nextResponder;
    
    return result;
}


@end
