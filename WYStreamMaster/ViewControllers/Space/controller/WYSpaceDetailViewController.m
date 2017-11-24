//
//  WYSpaceDetailViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/10.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYSpaceDetailViewController.h"
#import <MJRefresh.h>
#import "YTCommunityDetailCollectionCell.h"
#import "YTClassifyBBSDetailModel.h"
#import "WYCustomActionSheet.h"
#import "WYImagePickerController.h"
#import "UIImage+ProportionalFill.h"
#import "UINavigationBar+Awesome.h"

#define kClassifyHeaderHeight (kScreenWidth * 210 / 375 + 44)
static NSString *const kCommunityDetailCollectionCell = @"YTCommunityDetailCollectionCell";
static NSString *const kSpaceHeaderView = @"WYSpaceHeaderView";

@interface WYSpaceDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation WYSpaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"评论详情";
    [self setupView];
    [self getSpaceRequest];
}

#pragma mark - setup
- (void)setupView
{
    self.collectionView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kCommunityDetailCollectionCell bundle:nil] forCellWithReuseIdentifier:kCommunityDetailCollectionCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kSpaceHeaderView bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSpaceHeaderView];
    
    YTClassifyBBSDetailModel *model = [[YTClassifyBBSDetailModel alloc] init];
    model.content = @"橙卡，橙卡，橙卡";
    model.identity = @"100";
    model.create_date = @"2017-09-19 08:51:34";
    model.images = [NSMutableArray arrayWithObjects:@"update", @"update", @"update", @"update", @"update", nil];
    model.comment = @"100";
    model.identity = @"100";
    model.praiseNumber = @"100";
        [self.dataSource addObject:model];
        [self.dataSource addObject:model];
    //    [self.dataSource addObject:model];
    //    [self.dataSource addObject:model];
    
    WEAKSELF
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.width.bottom.equalTo(weakSelf.view);
    }];
}

#pragma mark -
#pragma mark - Server
- (void)getSpaceRequest{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"user_blogs"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:@"1" forKey:@"cur_page"];
    [paramsDic setObject:@"20" forKey:@"page_size"];
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:nil responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        if (requestType == WYRequestTypeSuccess) {
            NSArray *dataArr = [NSArray modelArrayWithClass:[YTClassifyBBSDetailModel class] json:dataObject[@"list"]];
            [weakSelf.dataSource addObjectsFromArray:dataArr];
            
            [weakSelf.collectionView reloadData];
        } else {
            
        }
        
    } failure:^(id responseObject, NSError *error) {
        
    }];
}

#pragma - mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YTClassifyBBSDetailModel *model;
    if (self.dataSource.count > 0) {
        model = (YTClassifyBBSDetailModel *)self.dataSource[indexPath.row];
        if ([model.images count] > 0) {
            model.bbsType = YTBBSTypeGraphic;
        } else if ([model.videos count] != 0) {
            model.bbsType = YTBBSTypeVideo;
        } else {
            model.bbsType = YTBBSTypeText;
        }
    }
    CGFloat itemHeight = [YTCommunityDetailCollectionCell heightWithEntity:model];
    return CGSizeMake(kScreenWidth - 12*2, itemHeight);
    
}
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//
//    return UIEdgeInsetsMake(5, 12, 12, 12);
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize headerSize = CGSizeMake(SCREEN_WIDTH, 0.1);
    return headerSize;
}


#pragma mark
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.dataSource count] == 0) {
        return 1;
    } else {
        return [self.dataSource count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YTCommunityDetailCollectionCell *communityCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommunityDetailCollectionCell forIndexPath:indexPath];
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
