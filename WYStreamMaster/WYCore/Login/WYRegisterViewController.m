//
//  WYRegisterViewController.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/5/3.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYRegisterViewController.h"

@interface WYRegisterViewController ()

@end

@implementation WYRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupSubview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Server

#pragma mark -
#pragma mark - Private Methods
- (void)setupSubview{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightButton.backgroundColor = [UIColor yellowColor];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton setImage:[UIImage imageNamed:@"wy_login_close_icon"] forState:UIControlStateNormal];
    self.rightButton = rightButton;
    
}

#pragma mark -
#pragma mark - Button Clicked
- (void)rightButtonClicked:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark - Getters and Setters

@end
