//
//  WYSpaceViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/29.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYSpaceViewController.h"
#import "WYSpaceHeaderView.h"
@interface WYSpaceViewController ()
@property (strong, nonatomic) WYSpaceHeaderView *headerView;
@end

@implementation WYSpaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_offset(175);
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Getters
- (WYSpaceHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = (WYSpaceHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"WYSpaceHeaderView" owner:self options:nil].lastObject;
    }
    
    return _headerView;
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
