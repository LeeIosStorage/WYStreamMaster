//
//  WYBaseTableViewController.m
//  EQPeopleCongress
//
//  Created by Jyh on 2017/4/16.
//  Copyright © 2017年 Zurich. All rights reserved.
//

#import "WYBaseTableViewController.h"

#import "WYRefreshHeader.h"
#import "WYRefreshFooter.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <AFNetworkReachabilityManager.h>

@interface WYBaseTableViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate
>
@end

@implementation WYBaseTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.startIndexPage = 1;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutSubviews {
    self.tableView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length],
                                                    0,
                                                    0,
                                                    0);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutSubviews];
}

#pragma mark
#pragma mark - Public Method

- (void)addRefreshHeader
{
    self.tableView.mj_header = [WYRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
}
- (void)addRefreshFooter
{
    self.tableView.mj_footer = [WYRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

- (void)addRefreshHeaderWithBlock:(WYRefreshComponentRefreshingHeaderBlock)refreshBlock
{
    self.refreshingHeaderBlock = refreshBlock;
    WEAKSELF
    self.tableView.mj_header = [WYRefreshHeader headerWithRefreshingBlock:^{
        if (weakSelf.refreshingHeaderBlock) {
            weakSelf.refreshingHeaderBlock();
        }
    }];
}

- (void)addRefreshFooterWithBlock:(WYRefreshComponentRefreshingFooterBlock)refreshBlock
{
    self.refreshingFooterBlock = refreshBlock;
    WEAKSELF
    self.tableView.mj_footer = [WYRefreshFooter footerWithRefreshingBlock:^{
        if (weakSelf.refreshingFooterBlock) {
            weakSelf.refreshingFooterBlock();
        }
    }];
}

- (void)loadNewData
{
    
}

- (void)loadMoreData
{
    
}

- (void)beginRefreshHeader
{
    [self.tableView.mj_header beginRefreshing];
}

- (void)beginRefreshFooter
{
    [self.tableView.mj_footer beginRefreshing];
}

- (void)endRefreshHeader
{
    [self.tableView.mj_header endRefreshing];
}
- (void)endRefreshFooter
{
    [self.tableView.mj_footer endRefreshing];
}

- (void)hideRefreshFooter
{
    [self.tableView.mj_footer setHidden:YES];
}

- (void)showRefreshFooter
{
    [self.tableView.mj_footer setHidden:NO];
}
- (BOOL)isRefreshing
{
    return [self.tableView.mj_header isRefreshing] || [self.tableView.mj_footer isRefreshing];
}

- (void)reloadEmptyDataSet
{
    [self.tableView reloadEmptyDataSet];
}

#pragma mark -
#pragma mark  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // in subClass
    return nil;
}

#pragma mark
#pragma mark - DZNEmptyDataSetSource

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"common_empty_icon"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    if (!self.emptyText) {
        self.emptyText = @"什么都没有";
    }
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        self.emptyText = @"网络连接失败";
    }
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName: [WYStyleSheet currentStyleSheet].titleLabelColor};
    
    return [[NSAttributedString alloc] initWithString:self.emptyText attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [WYStyleSheet currentStyleSheet].themeBackgroundColor;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
        return -roundf(self.tableView.frame.size.height/6);
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark
#pragma mark - Getters and Setters

- (UITableView *)tableView
{
    if (!_tableView) {
        CGRect tableViewFrame = self.view.bounds;
        tableViewFrame.size.height -= (self.navigationController.viewControllers.count > 1 ? 64 : (CGRectGetHeight(self.tabBarController.tabBar.bounds)));
        
        _tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
//        _tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
//        _tableView.backgroundColor = [UIColor whiteColor];
    }
    
    return _tableView;
}


- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _dataSource;
}


@end
