//
//  Forgot password Forgot password WYForgotPasswordViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/25.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYForgotPasswordViewController.h"

@interface WYForgotPasswordViewController ()

@end

@implementation WYForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    // Do any additional setup after loading the view from its nib.
}

#pragma mark - event
- (IBAction)backLogin:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

@end
