//
//  WYHelpViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/26.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYHelpViewController.h"
#import "WYHelpCell.h"
#import "WYHelpDetailViewController.h"
@interface WYHelpViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *helpDataArray;

@end

@implementation WYHelpViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"帮助中心";
    [self setupView];
    [self setupData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - setup
- (void)setupView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    //    self.tableView.emptyDataSetSource = self;
    //    self.tableView.emptyDataSetDelegate = self;
    
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableview.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableview];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"WYHelpCell" bundle:nil] forCellReuseIdentifier:@"cell"];

    WS(weakSelf)
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).and.offset(0);
    }];
    
}

- (void)setupData
{
    self.helpDataArray = [NSMutableArray array];
    [self.helpDataArray addObjectsFromArray:@[@[
                                              @{},
                                              @{@"title":@"如何成为传奇娱乐主播?"},
                                              @{},
                                              @{@"title":@"直播出现卡顿?"},
                                              @{},
                                              @{@"title":@"直播管理条例?"},
                                              @{},
                                              @{@"title":@"直播手机推荐"},
                                              @{},
                                              @{@"title":@"直播界面介绍"},
                                              ]]];
    
//    [self.helpDataArray addObjectsFromArray:@[@[
//                                              @{},
//                                              @{@"title":@"直播界面介绍"},
//                                              @{},
//                                              @{@"title":@"消息中心介绍"},
//                                              @{},
//                                              @{@"title":@"信息更换流程"},
//                                              ]]];

}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.helpDataArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.helpDataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"常见问题";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 != 0 ) {
        static NSString *cellIndentifier = @"cell";
        WYHelpCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        NSDictionary *dic = self.helpDataArray[indexPath.section][indexPath.row];
        [cell updateCell:dic];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *cellIndentifierx = @"cellx";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifierx];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifierx];
        }
//        cell.backgroundColor = [UIColor clearColor];
        cell.hidden = YES;
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
       
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 != 0) {
        return 45.f;
    } else {
        return 1;
    }
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.helpDataArray[indexPath.section][indexPath.row];
    NSString *titleString = dic[@"title"];
    if ([titleString isEqualToString:@"直播出现卡顿?"]) {
        WYHelpDetailViewController *helpDetailVC = [[WYHelpDetailViewController alloc] initHelpDetailViewController:@"live_problem1" imageHeight:SCREEN_HEIGHT];
        [self.navigationController pushViewController:helpDetailVC animated:YES];
    } else if ([titleString isEqualToString:@"直播管理条例?"]) {
        WYHelpDetailViewController *helpDetailVC = [[WYHelpDetailViewController alloc] initHelpDetailViewController:@"live_problem2" imageHeight:1100];
        [self.navigationController pushViewController:helpDetailVC animated:YES];
    } else if ([titleString isEqualToString:@"直播手机推荐"]) {
        WYHelpDetailViewController *helpDetailVC = [[WYHelpDetailViewController alloc] initHelpDetailViewController:@"live_problem3" imageHeight:SCREEN_HEIGHT];
        [self.navigationController pushViewController:helpDetailVC animated:YES];
    } else if ([titleString isEqualToString:@"如何成为传奇娱乐主播?"]) {
        WYHelpDetailViewController *helpDetailVC = [[WYHelpDetailViewController alloc] initHelpDetailViewController:@"live_problem4" imageHeight:1010];
        [self.navigationController pushViewController:helpDetailVC animated:YES];
    } else if ([titleString isEqualToString:@"直播界面介绍"]) {
        WYHelpDetailViewController *helpDetailVC = [[WYHelpDetailViewController alloc] initHelpDetailViewController:@"live_problem5" imageHeight:SCREEN_HEIGHT];
        [self.navigationController pushViewController:helpDetailVC animated:YES];
    }
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
