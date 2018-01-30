//
//  YTBaseTableViewController.m
//  WYTelevision
//
//  Created by Jyh on 2016/12/28.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTBaseTableViewController.h"
#import "WYRefreshHeader.h"
#import "WYRefreshFooter.h"
//#import <MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface YTBaseTableViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate
>

@end

@implementation YTBaseTableViewController

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
    //    NSString *text = @"直播被怪兽抓走了，我们正在全力营救！";
    if (!self.emptyText) {
        self.emptyText = @"直播被怪兽抓走了，我们正在全力营救！";
    }
    
//    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
//        // 无网络
//        self.emptyText = @"网络不给力，请检查网络再试试";
//        [self hideRefreshFooter];
//    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
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
    return 34;
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
        
        _tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
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
