//
//  RMSuperViewController.m
//  WYRecordMaster
//
//  Created by zurich on 16/8/19.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "RMSuperViewController.h"

@interface RMSuperViewController ()

@end

@implementation RMSuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [WYStyleSheet defaultStyleSheet].themeBackgroundColor;
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
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

#pragma mark
#pragma mark - Public Method

- (UIBarButtonItem *)leftBarButtonItem
{
    if (!self.backImage) {
        self.backImage = [UIImage imageNamed:@"common_back"];
    }
    UIImage *backButtonImage = self.backImage;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backBarButtonItem;
}


- (void)doBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark - 旋转屏幕相关 子类可重写（把控制权交给子类VC处理）

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark -
#pragma mark - StausBar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
