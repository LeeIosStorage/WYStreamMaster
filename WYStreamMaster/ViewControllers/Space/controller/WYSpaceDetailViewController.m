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
#import "WYSpaceDetailModel.h"
#import "YTInteractMessageTableViewCell.h"
#import "WYSpaceDetailBottomView.h"
#define kClassifyHeaderHeight (kScreenWidth * 210 / 375 + 44)
static NSString *const kCommunityDetailCollectionCell = @"YTCommunityDetailCollectionCell";
static NSString *const kSpaceHeaderView = @"WYSpaceHeaderView";
static NSString *const kInteractMessageTableViewCell = @"YTInteractMessageTableViewCell";

@interface WYSpaceDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) YTClassifyBBSDetailModel *spaceModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WYSpaceDetailBottomView *spaceDetailBottomView;
@property (nonatomic, copy) NSString *parent_id;

@end

@implementation WYSpaceDetailViewController
- (instancetype)init:(YTClassifyBBSDetailModel *)spaceListModel
{
    self = [super init];
    if (self) {
        self.startIndexPage = 1;
        self.spaceModel = spaceListModel;
    }
    return self;
}

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.collectionView addGestureRecognizer:tap];
    
    self.collectionView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kCommunityDetailCollectionCell bundle:nil] forCellWithReuseIdentifier:kCommunityDetailCollectionCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kSpaceHeaderView bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSpaceHeaderView];
    
    WYSpaceDetailModel *model = [[WYSpaceDetailModel alloc] init];
    WYSpaceDetailModel *model1 = [[WYSpaceDetailModel alloc] init];
    model.content = @"橙卡，橙卡，橙卡";
    model.commentId = @"100";
    model.create_date = @"2017-09-19 08:51:34";
    model.parent_id = @"200";
    model.user_code = @"100";
    model.parent_user_code = @"200";
    model.nickname = @"小飞侠";
    model.parent_nickname = @"奥特曼";
    model.content = @"我是一只小蜜蜂，飞到花丛中我是一只小蜜蜂，飞到花丛中";
    
    model1.content = @"橙卡，橙卡，橙卡";
    model1.commentId = @"100";
    model1.create_date = @"2017-09-19 08:51:34";
    model1.user_code = @"100";
    model1.parent_user_code = @"200";
    model1.nickname = @"小飞侠";
    model1.parent_nickname = @"奥特曼";
    model1.content = @"我是一只小蜜蜂，飞到花丛中";

//    [self.dataSource addObject:model];
//    [self.dataSource addObject:model];
//    [self.dataSource addObject:model1];
//    [self.dataSource addObject:model1];
    
    WEAKSELF
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(10);
        make.left.right.width.bottom.equalTo(weakSelf.view);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:kInteractMessageTableViewCell bundle:nil] forCellReuseIdentifier:kInteractMessageTableViewCell];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    CGFloat itemHeight;
    if (self.spaceModel.bbsType == YTBBSTypeText) {
        itemHeight = 138;
    } else if (self.spaceModel.bbsType == YTBBSTypeGraphic) {
        itemHeight = 100.0*kScreenWidth / 375.0 + 168;
    } else if (self.spaceModel.bbsType == YTBBSTypeVideo) {
        itemHeight = 190;
    }
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.bottom.equalTo(@-60);
        make.top.mas_offset(itemHeight);
    }];
    
    self.spaceDetailBottomView = [[[NSBundle mainBundle] loadNibNamed:@"WYSpaceDetailBottomView" owner:self options:nil] objectAtIndex:0];
    self.spaceDetailBottomView.spaceDetailTextField.delegate = self;
    [self.spaceDetailBottomView.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.spaceDetailBottomView];
    [self.spaceDetailBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_offset(50);
    }];
}
#pragma mark - event
- (void)sendButtonAction:(UIButton *)sender
{
    [self publishComment:self.parent_id];
}

- (void)viewTapped
{
    [self.spaceDetailBottomView.spaceDetailTextField resignFirstResponder];
}
#pragma mark -
#pragma mark - Server
- (void)getSpaceRequest{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"get_blog_comments"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:self.spaceModel.identity forKey:@"blog_id"];
    [paramsDic setObject:[NSString stringWithFormat:@"%zd", self.startIndexPage] forKey:@"cur_page"];
    [paramsDic setObject:@"100" forKey:@"page_size"];
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        if (requestType == WYRequestTypeSuccess) {
            NSArray *dataArr = [NSArray modelArrayWithClass:[WYSpaceDetailModel class] json:dataObject[@"list"]];
            [weakSelf.dataSource addObjectsFromArray:dataArr];
            [weakSelf.tableView reloadData];
        } else {
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

- (void)publishComment:(NSString *)parent_id{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"publish_comment"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:self.spaceModel.identity forKey:@"blog_id"];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:self.spaceDetailBottomView.spaceDetailTextField.text forKey:@"content"];
    if ([parent_id length] != 0) {
        [paramsDic setObject:parent_id forKey:@"parent_id"];
    }
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        if (requestType == WYRequestTypeSuccess) {
            weakSelf.dataSource = [NSMutableArray array];
            [weakSelf getSpaceRequest];
            weakSelf.spaceDetailBottomView.spaceDetailTextField.text = @"";
        } else {
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return YES;
}
#pragma - mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YTClassifyBBSDetailModel *model = self.spaceModel;
//    if (self.dataSource.count > 0) {
//        model = (YTClassifyBBSDetailModel *)self.dataSource[indexPath.row];
//        if ([model.images count] > 0) {
//            model.bbsType = YTBBSTypeGraphic;
//        } else if ([model.videos count] != 0) {
//            model.bbsType = YTBBSTypeVideo;
//        } else {
//            model.bbsType = YTBBSTypeText;
//        }
//    }
//    WYSpaceDetailModel *spaceModel = self.dataSource[indexPath.row];
//    itemHeight +=  [spaceModel getCellHeigt] + 74;
    CGFloat itemHeight = [YTCommunityDetailCollectionCell heightWithEntity:model];
    return CGSizeMake(kScreenWidth - 12 * 2, itemHeight);
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
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YTCommunityDetailCollectionCell *communityCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommunityDetailCollectionCell forIndexPath:indexPath];
    [communityCell updateCommunifyCellWithData:self.spaceModel];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    WYSpaceDetailModel *model = self.dataSource[indexPath.row];
    return  [model getCellHeigt] + 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YTInteractMessageTableViewCell";
    YTInteractMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    WYSpaceDetailModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYSpaceDetailModel *model = self.dataSource[indexPath.row];
    self.parent_id = model.parent_id;
    [self.spaceDetailBottomView.spaceDetailTextField becomeFirstResponder];
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
