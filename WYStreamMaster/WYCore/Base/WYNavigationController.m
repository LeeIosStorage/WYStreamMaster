//
//  WYNavigationController.m
//  WYRecordMaster
//
//  Created by Jyh on 2016/10/19.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYNavigationController.h"
#import "RMSuperViewController.h"
#import "UINavigationBar+Awesome.h"
#import "WYSuperViewController.h"

@interface WYNavigationController ()
<
UINavigationControllerDelegate
>

@end

@implementation WYNavigationController

- (UIStatusBarStyle )preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.navigationBar setBarTintColor:[WYStyleSheet defaultStyleSheet].themeColor];
//    [self.navigationBar setTranslucent:NO];
    
    
    self.delegate = self;
}


#pragma mark
#pragma mark - Super Methods

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    //[super pushViewController:viewController animated:animated];
//    UIBarButtonItem *leftBarButton = nil;
//
////    [viewController.navigationController.navigationBar lt_setBackgroundColor:[WYStyleSheet defaultStyleSheet].themeColor];
////    [viewController.navigationController.navigationBar setBackgroundColor:[WYStyleSheet defaultStyleSheet].themeColor];
////        [self.navigationController.navigationBar setBarTintColor:[WYStyleSheet defaultStyleSheet].themeColor];
////        [self.navigationController.navigationBar setTranslucent:NO];
////    [self.navigationBar lt_reset];
//    [self.navigationBar lt_setBackgroundColor:[WYStyleSheet defaultStyleSheet].themeColor];
//    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[WYStyleSheet defaultStyleSheet].navTitleFont,NSFontAttributeName,nil];
////    if ([viewController isKindOfClass:[WYSuperViewController class]]) {
////        WYSuperViewController *controller = (WYSuperViewController *)viewController;
////        leftBarButton = [controller leftBarButtonItem];
////        
////        if (controller.rightBarButtonItem) {
////            self.navigationItem.rightBarButtonItem = controller.rightBarButtonItem;
////        }
////    }
////    self.navigationItem.leftBarButtonItem = leftBarButton;
//    
//    [self.navigationController pushViewController:viewController animated:animated];
//}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
//    if (isRootVC) {
//        viewController.navigationItem.leftBarButtonItem = nil;
//    }
//}

#pragma mark
#pragma mark - 旋转屏幕相关（把控制权交给上层VC处理）
- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
