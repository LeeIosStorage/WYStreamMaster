//
//  WYTabBarController.m
//  WYRecordMaster
//
//  Created by zurich on 16/8/17.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYTabBarController.h"

@interface WYTabBarController ()

@end

@implementation WYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedIndex = 0;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- 禁止横竖屏切换（把控制权交给上层VC处理）
// 是否支持自动旋转屏
- (BOOL)shouldAutorotate
{
    return self.selectedViewController.shouldAutorotate;
}

// viewController支持哪些转屏方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.selectedViewController.supportedInterfaceOrientations;
}
// viewController优先支持方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.selectedViewController.preferredInterfaceOrientationForPresentation;
}

@end
