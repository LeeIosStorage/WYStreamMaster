//
//  YTBaseTableViewController.h
//  WYTelevision
//
//  Created by Jyh on 2016/12/28.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//  Tableview的基类

#import "WYSuperViewController.h"

typedef void (^WYRefreshComponentRefreshingHeaderBlock)();
typedef void (^WYRefreshComponentRefreshingFooterBlock)();

@interface YTBaseTableViewController : WYSuperViewController

/**
 *  显示数据的CollectionView控件
 */
@property (strong, nonatomic) UITableView *tableView;

/**
 *  大量数据的数据源
 */
@property (strong, nonatomic) NSMutableArray *dataSource;

/**
 *  开始请求的页码数 默认从1开始
 */
@property (assign, nonatomic) int startIndexPage;

/**
 空页面的title
 */
@property (copy, nonatomic) NSString *emptyText;

/** 进入刷新状态的回调 */
@property (copy, nonatomic) WYRefreshComponentRefreshingHeaderBlock refreshingHeaderBlock;
@property (copy, nonatomic) WYRefreshComponentRefreshingFooterBlock refreshingFooterBlock;

#pragma mark - Public Method

/**
 *  添加下拉刷新，上拉加载更多页面
 */
- (void)addRefreshHeader;
- (void)addRefreshHeaderWithBlock:(WYRefreshComponentRefreshingHeaderBlock)refreshBlock;
- (void)addRefreshFooter;
- (void)addRefreshFooterWithBlock:(WYRefreshComponentRefreshingFooterBlock)refreshBlock;

/**
 *  下拉上拉刷新数据
 */
- (void)loadNewData;
- (void)loadMoreData;

/**
 *  开始上拉下拉刷新
 */
- (void)beginRefreshHeader;
- (void)beginRefreshFooter;

/**
 *  停止上拉下拉刷新
 */
- (void)endRefreshHeader;
- (void)endRefreshFooter;

/**
 *  隐藏或显示上拉加载数据
 */
- (void)hideRefreshFooter;
- (void)showRefreshFooter;

/**
 *  正在刷新数据
 */
- (BOOL)isRefreshing;

/**
 *  重新加载空白页
 */
- (void)reloadEmptyDataSet;

@end
