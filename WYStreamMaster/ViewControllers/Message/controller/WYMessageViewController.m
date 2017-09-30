//
//  WYMessageViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/26.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYMessageViewController.h"
#import "WYMessageTableViewCell.h"
@interface WYMessageViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation WYMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - setup
- (void)setupView
{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableview registerNib:[UINib nibWithNibName:@"WYMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void)setupData
{
    self.messageArray = [NSMutableArray array];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 95) / 2.0, 15, 95, 30)];
    headerLabel.text = @"2017.5.18";
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    headerLabel.backgroundColor = [UIColor colorWithHexString:@"c8c8c8"];
    [headerLabel setTextColor:[UIColor colorWithHexString:@"ffffff"]];
    headerLabel.font = [UIFont systemFontOfSize:12.0];
    headerLabel.layer.cornerRadius = 15.0;
    headerLabel.layer.masksToBounds = YES;
    [headerView addSubview:headerLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cell";
    WYMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
