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
#import "WYCustomActionSheet.h"
#import "WYImagePickerController.h"
#import "UIImage+ProportionalFill.h"
#import "UINavigationBar+Awesome.h"
#import "WYSpaceDetailViewController.h"
#import "WYIssueTalkAboutViewController.h"
#import "WYLoginManager.h"

#define kClassifyHeaderHeight (kScreenWidth * 210 / 375 + 44)
static NSString *const kCommunityCollectionCell = @"YTCommunityCollectionCell";
static NSString *const kSpaceHeaderView = @"WYSpaceHeaderView";

@interface WYSpaceViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WYSpaceImageViewDelegate>
@property (strong, nonatomic) WYSpaceHeaderView *headerView;
@property (assign, nonatomic) NSInteger startIndexPage;

@end

@implementation WYSpaceViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.collectionView.userInteractionEnabled = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]};
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.startIndexPage = 1;
        [self getSpaceRequest];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startIndexPage = 1;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.title = @"个人空间";
    [self setupView];
//    [self getSpaceRequest];
    //导航栏透明
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics: UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - setup
- (void)setupView
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"add_space"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [self setRightButton:rightButton];
    [self.navigationController.navigationBar setValue:@0 forKeyPath:@"backgroundView.alpha"];
    
    self.collectionView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kCommunityCollectionCell bundle:nil] forCellWithReuseIdentifier:kCommunityCollectionCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kSpaceHeaderView bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSpaceHeaderView];

    WEAKSELF
    [self.view addSubview:self.collectionView];
    [self addRefreshHeaderWithBlock:^{
        weakSelf.startIndexPage = 1;
        [weakSelf getSpaceRequest];
    }];
    
//    [self addRefreshFooterWithBlock:^{
//        [weakSelf getSpaceRequest];
//    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.width.bottom.equalTo(weakSelf.view);
    }];
}

- (UIBarButtonItem *)leftBarButtonItem
{
    if (!self.backImage) {
        self.backImage = [UIImage imageNamed:@"common_white_back"];
    }
    UIImage *backButtonImage = self.backImage;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backBarButtonItem;
}

#pragma mark
#pragma mark - Super Methods

- (void)onLoadingViewButtonClick
{
    [self hideLoadingView];
    [self loadingAction];
}

- (void)loadingAction
{
   
}

#pragma mark -
#pragma mark - Server
- (void)getSpaceRequest{
    if (self.startIndexPage == 1) {
        [self.dataSource removeAllObjects];
    }
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"user_blogs"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
//    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:[NSString stringWithFormat:@"%zd", self.startIndexPage] forKey:@"cur_page"];
    [paramsDic setObject:@"1000" forKey:@"page_size"];
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:nil responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer beginRefreshing];
        if (requestType == WYRequestTypeSuccess) {
            NSArray *dataArr = [NSArray modelArrayWithClass:[YTClassifyBBSDetailModel class] json:dataObject[@"list"]];
            [weakSelf.dataSource addObjectsFromArray:dataArr];
            [weakSelf.collectionView reloadData];
            if (dataArr.count < 10) {
                [weakSelf.collectionView.mj_footer setHidden:YES];
                [weakSelf showRefreshFooter];
            } else {
                [weakSelf hideRefreshFooter];
                weakSelf.startIndexPage ++;
//                [weakSelf getSpaceRequest];
//                [weakSelf.collectionView.mj_footer setHidden:NO];
            }
        } else {
            
        }
        weakSelf.collectionView.userInteractionEnabled = YES;
    } failure:^(id responseObject, NSError *error) {
        weakSelf.collectionView.userInteractionEnabled = YES;
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer beginRefreshing];
    }];
}

- (void)changeSpacePhoto:(NSString *)spacePhoto{
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"change_spacePhoto"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:spacePhoto forKey:@"zone_img"];
    WS(weakSelf)
    
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer beginRefreshing];
        if (requestType == WYRequestTypeSuccess) {
            [weakSelf.headerView.spaceHeaderImageView setImageWithURL:[NSURL URLWithString:spacePhoto] placeholder:[UIImage imageNamed:@"space_background"]];
            [WYLoginManager sharedManager].loginModel.zone_img = spacePhoto;
        } else {
            NSLog(@"aaaa");
        }
    } failure:^(id responseObject, NSError *error) {
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer beginRefreshing];
    }];
}
// 删除说说
- (void)deleteTalkAbout:(NSInteger)row{
    YTClassifyBBSDetailModel *model = (YTClassifyBBSDetailModel *)self.dataSource[row];

    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"blog_delete"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:model.identity forKey:@"id"];
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer beginRefreshing];
        if (requestType == WYRequestTypeSuccess) {
            [MBProgressHUD showError:@"删除成功" toView:weakSelf.view];
            [self.dataSource removeObjectAtIndex:row];
            [self.collectionView reloadData];
        } else {
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer beginRefreshing];
    }];
}

- (void)uploadWithImageData:(NSData *)imageData
{
    [MBProgressHUD showMessage:@"正在上传..."];
    //    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"upload_image"];
    
    NSString *requestUrl = @"http://172.16.2.180:8090/event-platform-admin/file/ios_image?";
    
    //        NSString *requestUrl = @"http://www.legend8888.com/files/api/uploadfile.do?";
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"bizImgPath"];
    [paramsDic setObject:@"1" forKey:@"saveType"];
    
    WS(weakSelf);
    [self.networkManager POST:requestUrl formFileName:@"pic" fileName:@"img.jpg" fileData:imageData mimeType:@"image/jpeg" parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        [MBProgressHUD hideHUD];
        if (requestType == WYRequestTypeSuccess) {
            [MBProgressHUD showSuccess:@"上传成功" toView:weakSelf.view];
            NSString *urlStr = nil;
            if ([dataObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = dataObject;
                urlStr = [dict objectForKey:@"path"];
            } else if ([dataObject isKindOfClass:[NSString class]]){
                urlStr = dataObject;
            }
            [weakSelf changeSpacePhoto:urlStr];
        } else {
            NSLog(@"");
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_photo_upload_errer_tip"] toView:weakSelf.view];
    }];
}


#pragma mark - event
- (void)rightButtonClicked:(id)sender
{
    WYIssueTalkAboutViewController *issueTalkAboutVC = [[WYIssueTalkAboutViewController alloc] init];
    issueTalkAboutVC.submitType = 7;
//    submitVc.delegate = self;
    
    UIButton *customRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customRightButton setTitle:@"发布" forState:UIControlStateNormal];
    [customRightButton setTitleColor:[WYStyleSheet currentStyleSheet].normalButtonColor forState:UIControlStateNormal];
    [customRightButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    customRightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    issueTalkAboutVC.rightButton = customRightButton;
    
    [self.navigationController pushViewController:issueTalkAboutVC animated:YES];
}
// 删除说说
- (void)deleteButtonAction:(UIButton *)sender
{
    [self deleteTalkAbout:sender.tag];
}

- (void)showImageBroswerWithSourceType:(UIImagePickerControllerSourceType )sourceType
{
    WYImagePickerController *imagePickerController = [[WYImagePickerController alloc] init];
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return;
        }
    }
    imagePickerController.sourceType = sourceType;
    [imagePickerController.navigationBar lt_setBackgroundImage:[UIImage imageNamed:@"wy_navbar_bg"]];
    [imagePickerController.navigationBar setTranslucent:NO];
    imagePickerController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[WYStyleSheet defaultStyleSheet].navTitleFont,NSFontAttributeName,nil];
    imagePickerController.delegate = self;
    imagePickerController.navigationController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
#pragma mark - WYSpaceImageViewDelegate
- (void)spaceHeaderImageViewTapped
{
    WEAKSELF
    WYCustomActionSheet *actionSheet = [[WYCustomActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
        NSLog(@"%ld",(long)buttonIndex);
        if (buttonIndex == 1) {
            [weakSelf showImageBroswerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        } else if (buttonIndex == 0){
            [weakSelf showImageBroswerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
    } cancelButtonTitle:[WYCommonUtils acquireCurrentLocalizedText:@"wy_cancel"] destructiveButtonTitle:nil otherButtonTitles:@[[WYCommonUtils acquireCurrentLocalizedText:@"wy_take_photos"],[WYCommonUtils acquireCurrentLocalizedText:@"wy_photo_library"]]];
    [actionSheet showInView:self.view];
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    UIImage* imageAfterScale = image;
    if (image.size.width != image.size.height) {
        CGSize cropSize = image.size;
        cropSize.height = MIN(image.size.width, image.size.height);
        cropSize.width = MIN(image.size.width, image.size.height);
        imageAfterScale = [image imageCroppedToFitSize:cropSize];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString  *,id> *)info {
    
    CGFloat compressionQuality = WY_IMAGE_COMPRESSION_QUALITY;
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        compressionQuality = 0.1;
    }
    UIImage* imageAfterScale = image;
    NSData *imageData = UIImageJPEGRepresentation(imageAfterScale, compressionQuality);
    if (imageData.length > 400*1024) {
        UIImage *newImage = [UIImage imageWithData:imageData];
        imageAfterScale = newImage;
        imageData = UIImageJPEGRepresentation(newImage, compressionQuality);
    }
    [self uploadWithImageData:imageData];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
    CGFloat itemHeight = [YTCommunityCollectionCell heightWithEntity:model];
    return CGSizeMake(kScreenWidth - 12*2, itemHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(5, 12, 12, 12);
}

// 创建头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSpaceHeaderView forIndexPath:indexPath];
    self.headerView.delegate = self;
    self.headerView.backgroundColor = [UIColor whiteColor];
    [self.headerView updateHeaderViewWithData:nil];
    
    [self.headerView.spaceHeaderImageView setImageWithURL:[NSURL URLWithString:[WYLoginManager sharedManager].loginModel.zone_img] placeholder:[UIImage imageNamed:@"space_background"]];
    return self.headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize headerSize = CGSizeMake(SCREEN_WIDTH, 175);
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
    YTCommunityCollectionCell *communityCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommunityCollectionCell forIndexPath:indexPath];
    if (indexPath.row < [self.dataSource count]) {
        [communityCell updateCommunifyCellWithData:(YTClassifyBBSDetailModel *)self.dataSource[indexPath.row]];
        communityCell.deleteButton.tag = indexPath.row;
        [communityCell.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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
    WYSpaceDetailViewController *spaceDetailVC = [[WYSpaceDetailViewController alloc] init:model];
    [self.navigationController pushViewController:spaceDetailVC animated:YES];
//    if (model.bbsType == YTBBSTypeVideo) {
//        WYNewVideoDetailViewController *vc = [[WYNewVideoDetailViewController alloc] init];
//        vc.videoId = model.videoID;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    } else {
 //
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
