//
//  WYLiveSetViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYLiveSetViewController.h"

@interface WYLiveSetViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIView *tableviewHeaderView;

@end

@implementation WYLiveSetViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"直播设置";
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupView];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - setup
- (void)setupView
{
//    [self.tableviewHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@0);
//        make.bottom.equalTo(@64);
//    }];
//    self.tableview.tableHeaderView = self.tableviewHeaderView;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview reloadData];
//    [self.view insertSubview:self.tableview.tableHeaderView atIndex:0];

}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 568;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    UIView *headerView = [[UIView alloc] init];
//    headerView.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 95) / 2.0, 15, 95, 30)];
//    headerLabel.text = @"2017.5.18";
//    [headerLabel setTextAlignment:NSTextAlignmentCenter];
//    headerLabel.backgroundColor = [UIColor colorWithHexString:@"c8c8c8"];
//    [headerLabel setTextColor:[UIColor colorWithHexString:@"ffffff"]];
//    headerLabel.font = [UIFont systemFontOfSize:12.0];
//    headerLabel.layer.cornerRadius = 15.0;
//    headerLabel.layer.masksToBounds = YES;
//    [headerView addSubview:headerLabel];
    return self.tableviewHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"placeholder-name";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        //        cell = [cells objectAtIndex:0];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
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
