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
#define kClassifyHeaderHeight (kScreenWidth * 210 / 375 + 44)
static NSString *const kCommunityCollectionCell = @"YTCommunityCollectionCell";
static NSString *const kSpaceHeaderView = @"WYSpaceHeaderView";

@interface WYSpaceViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) WYSpaceHeaderView *headerView;

@end

@implementation WYSpaceViewController
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人空间";
    [self setupView];
    [self getSpaceRequest];
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

    
    self.collectionView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kCommunityCollectionCell bundle:nil] forCellWithReuseIdentifier:kCommunityCollectionCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kSpaceHeaderView bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSpaceHeaderView];

    YTClassifyBBSDetailModel *model = [[YTClassifyBBSDetailModel alloc] init];
    model.content = @"橙卡，橙卡，橙卡";
    model.create_date = @"2017-09-19 08:51:34";
    model.images = [NSMutableArray arrayWithObjects:@"update", @"update", @"update", @"update", @"update", nil];
    model.comment = @"100";
    model.upvote = @"100";
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

#pragma mark - event
#pragma mark - Action
- (void)rightButtonClicked:(id)sender
{
//    UIButton *rightButton = (UIButton *)sender;
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
    
    //    [self uploadWithImageData:imageData uploadType:self.uploadImageType];
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
    self.headerView.backgroundColor = [UIColor whiteColor];
    [self.headerView updateHeaderViewWithData:nil];
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
    WYSpaceDetailViewController *spaceDetailVC = [[WYSpaceDetailViewController alloc] init];
    [self.navigationController pushViewController:spaceDetailVC animated:YES];
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
