//
//  WYHelpViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/26.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYHelpViewController.h"

@interface WYHelpViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation WYHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.tableview.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableview];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"YTMineNewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.mineHomeHeaderView = [[NSBundle mainBundle] loadNibNamed:@"YTMineHomeHeaderView" owner:self options:nil].lastObject;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH + 57)];
    headerView.backgroundColor = [UIColor clearColor];
    self.mineHomeHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH + 57);
    self.mineHomeHeaderView.delegate = self;
    [headerView addSubview:self.mineHomeHeaderView];
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20.f)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    self.tableView.rowHeight = 50.f;
    
    WS(weakSelf)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).and.offset(0);
    }];
    
}

- (void)setupData
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
