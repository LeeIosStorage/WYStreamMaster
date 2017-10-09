//
//  WYBaseCollectionController.m
//  WangYu
//
//  Created by Jyh on 16/8/4.
//  Copyright © 2016年 KID. All rights reserved.
//

#import "WYBaseCollectionController.h"

#import <MJRefresh.h>

@interface WYBaseCollectionController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate
>

@end

@implementation WYBaseCollectionController

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

    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Public Method

- (void)addRefreshHeader
{
    self.collectionView.mj_header = [WYRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
}
- (void)addRefreshFooter
{
    self.collectionView.mj_footer = [WYRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

- (void)addRefreshHeaderWithBlock:(WYRefreshComponentRefreshingHeaderBlock)refreshBlock
{
    
    self.refreshingHeaderBlock = refreshBlock;
    WEAKSELF
    self.collectionView.mj_header = [WYRefreshHeader headerWithRefreshingBlock:^{
        if (weakSelf.refreshingHeaderBlock) {
            weakSelf.refreshingHeaderBlock();
        }
    }];
}

- (void)addRefreshFooterWithBlock:(WYRefreshComponentRefreshingFooterBlock)refreshBlock
{
    self.refreshingFooterBlock = refreshBlock;
    WEAKSELF
    
    self.collectionView.mj_footer = [WYRefreshFooter footerWithRefreshingBlock:^{
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
    [self.collectionView.mj_header beginRefreshing];
}

- (void)beginRefreshFooter
{
    [self.collectionView.mj_footer beginRefreshing];
}

- (void)endRefreshHeader
{
    [self.collectionView.mj_header endRefreshing];
}
- (void)endRefreshFooter
{
    [self.collectionView.mj_footer endRefreshing];
}

- (void)hideRefreshFooter
{
    [self.collectionView.mj_footer setHidden:YES];
}

- (void)showRefreshFooter
{
    [self.collectionView.mj_footer setHidden:NO];
}
- (BOOL)isRefreshing
{
    return [self.collectionView.mj_header isRefreshing] || [self.collectionView.mj_footer isRefreshing];
}

- (void)reloadEmptyDataSet
{
    [self.collectionView reloadEmptyDataSet];
}

#pragma mark
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
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
        self.emptyText = @"";
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [WYStyleSheet currentStyleSheet].titleLabelColor};
    
    return [[NSAttributedString alloc] initWithString:self.emptyText attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [WYStyleSheet currentStyleSheet].themeColor;
    
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
//    return -roundf(self.collectionView.frame.size.height/6);
    return 0;
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

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        CGRect collectionViewFrame = self.view.bounds;
        collectionViewFrame.size.height -= (self.navigationController.viewControllers.count > 1 ? 64 : (CGRectGetHeight(self.tabBarController.tabBar.bounds)));
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
    }
    
    return _collectionView;
}


- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _dataSource;
}


@end
