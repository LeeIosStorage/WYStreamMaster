//
//  WYHomePageViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYHomePageViewController.h"
#import "WYLiveSetViewController.h"
#import "WYHelpViewController.h"
#import "WYMessageViewController.h"
#import "WYIncomeRecordViewController.h"
#import "WYSpaceViewController.h"
@interface WYHomePageViewController ()
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *profitRecordButton;
@property (strong, nonatomic) IBOutlet UIButton *helpCenterButton;
@property (strong, nonatomic) IBOutlet UIButton *liveSetButton;
@property (strong, nonatomic) IBOutlet UIButton *mySpaceButton;

@end

@implementation WYHomePageViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - event
- (IBAction)clickMessageButton:(UIButton *)sender {
    WYMessageViewController *messageVC = [[WYMessageViewController alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (IBAction)clickStartLiveButton:(UIButton *)sender {
}
- (IBAction)clickLiveSetButton:(UIButton *)sender {
    WYLiveSetViewController *liveSetVC = [[WYLiveSetViewController alloc] init];
    [self.navigationController pushViewController:liveSetVC animated:YES];
}
- (IBAction)clickProfitRecordButton:(id)sender {
    WYIncomeRecordViewController *incomeRecordVC = [[WYIncomeRecordViewController alloc] init];
    [self.navigationController pushViewController:incomeRecordVC animated:YES];
}
- (IBAction)clickHelpCenterButton:(id)sender {
    WYHelpViewController *helpCenterVC = [[WYHelpViewController alloc] init];
    [self.navigationController pushViewController:helpCenterVC animated:YES];
}
- (IBAction)clickSpaceButton:(UIButton *)sender {
    WYSpaceViewController *spaceVC = [[WYSpaceViewController alloc] init];
    [self.navigationController pushViewController:spaceVC animated:YES];
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
