//
//  WYSpaceViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/29.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYSpaceViewController.h"
#import "WYSpaceHeaderView.h"
#import <MJRefresh.h>
#import "YTCommunityCollectionCell.h"
#import "YTClassifyBBSDetailModel.h"
#define kClassifyHeaderHeight (kScreenWidth * 210 / 375 + 44)
static NSString *const kCommunityCollectionCell = @"YTCommunityCollectionCell";

@interface WYSpaceViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) WYSpaceHeaderView *headerView;

@end

@implementation WYSpaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - setup
- (void)setupView
{
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_offset(175);
    }];
    
    self.collectionView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kCommunityCollectionCell bundle:nil] forCellWithReuseIdentifier:kCommunityCollectionCell];
    YTClassifyBBSDetailModel *model = [[YTClassifyBBSDetailModel alloc] init];
    model.content = @"橙卡，橙卡，橙卡";
    model.createDate = @"2017-09-19 08:51:34";
    model.gameName = @"炉石传说";
    model.imgs = @"";
    model.postsID = @"1802";
    [self.dataSource addObject:model];
    [self.dataSource addObject:model];
    [self.dataSource addObject:model];
    [self.dataSource addObject:model];

    WEAKSELF
    [self addRefreshHeaderWithBlock:^{
        weakSelf.startIndexPage = 1;
        
//        [weakSelf requestClassifyBBSListWithGameId:weakSelf.gameID page:weakSelf.startIndexPage pageSize:DATA_LOAD_PAGESIZE_COUNT result:^(YTClassifyBBSListModel *model) {
//            if (model) {
//                [weakSelf handleBBSListData:model];
//            }
//        }];
    }];
    
    [self addRefreshFooterWithBlock:^{
//        [weakSelf requestClassifyBBSListWithGameId:weakSelf.gameID page:weakSelf.startIndexPage pageSize:DATA_LOAD_PAGESIZE_COUNT result:^(YTClassifyBBSListModel *model) {
//            if (model) {
//                [weakSelf handleBBSListData:model];
//            }
//        }];
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.width.bottom.equalTo(weakSelf.view);
    }];
}

#pragma - mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YTClassifyBBSDetailModel *model = (YTClassifyBBSDetailModel *)self.dataSource[indexPath.row];
    CGFloat itemHeight = [YTCommunityCollectionCell heightWithEntity:model];
    return CGSizeMake(kScreenWidth - 12*2, itemHeight);
//    return CGSizeMake(kScreenWidth - 12*2, 40);

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(5, 12, 12, 12);
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader] ) {
//        
//        YTClassifyBaseCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kYTClassifyBaseCollectionReusableView forIndexPath:indexPath];
//        
//        return header;
//    }
//    return nil;
//}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize headerSize = CGSizeMake(SCREEN_WIDTH, kClassifyHeaderHeight);
    return headerSize;
}


#pragma mark
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YTCommunityCollectionCell *communityCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommunityCollectionCell forIndexPath:indexPath];
    if (indexPath.row < [self.dataSource count]) {
        
        [communityCell updateCommunifyCellWithData:(YTClassifyBBSDetailModel *)self.dataSource[indexPath.row]];
    }
    
    return communityCell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

#pragma mark
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YTClassifyBBSDetailModel *model = (YTClassifyBBSDetailModel *)self.dataSource[indexPath.row];
//    if (model.bbsType == YTBBSTypeVideo) {
//        WYNewVideoDetailViewController *vc = [[WYNewVideoDetailViewController alloc] init];
//        vc.videoId = model.videoID;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    } else {
//        YTTopicDetailViewController *vc = [[YTTopicDetailViewController alloc] init];
//        vc.topicId = model.postsID;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
}


#pragma mark - Getters
- (WYSpaceHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = (WYSpaceHeaderView *)[[NSBundle mainBundle] loadNibNamed:@"WYSpaceHeaderView" owner:self options:nil].lastObject;

    }
    
    return _headerView;
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
