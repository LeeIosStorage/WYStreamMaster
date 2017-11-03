//
//  WYLiveSetViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYLiveSetViewController.h"
#import "WYCustomActionSheet.h"
#import "UINavigationBar+Awesome.h"
#import "WYImagePickerController.h"
#import "UIImage+ProportionalFill.h"
typedef NS_ENUM(NSInteger, LiveUploadImageType){
    UploadImageTypeAvatar = 0,   //avatar
    UploadImageTypeAnchorCover,
};

@interface WYLiveSetViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>
@property (nonatomic, assign) LiveUploadImageType uploadImageType;

@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIView *tableviewHeaderView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIImageView *liveCoverImageView;
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;

@end

@implementation WYLiveSetViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"直播设置";
    [self setupView];
}
#pragma mark - setup
- (void)setupView
{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview reloadData];
    self.headerImageView.userInteractionEnabled = YES;
    self.liveCoverImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureHeaderImageView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHeaderImageView)];
    [self.headerImageView addGestureRecognizer:tapGestureHeaderImageView];
    
    UITapGestureRecognizer *tapGestureCoverView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureLiveCoverView)];
    [self.liveCoverImageView addGestureRecognizer:tapGestureCoverView];
}
#pragma mark - event
- (void)tapGestureHeaderImageView
{
    self.uploadImageType = UploadImageTypeAvatar;
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

- (void)tapGestureLiveCoverView
{
    self.uploadImageType = UploadImageTypeAnchorCover;
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
- (IBAction)submitButtonAction:(UIButton *)sender {
    
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
    if (self.uploadImageType == UploadImageTypeAvatar) {
        self.headerImageView.image = [UIImage imageWithData:imageData];
    }else if (self.uploadImageType == UploadImageTypeAnchorCover){
        self.liveCoverImageView.image = [UIImage imageWithData:imageData];
    }
    
//    [self uploadWithImageData:imageData uploadType:self.uploadImageType];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 568;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    UIView *headerView = [[UIView alloc] init];
//    headerView.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 95) / 2.0, 15, 95, 30)];
//    headerLabel.text = @"2017.5.18";
//    [headerLabel setTextAlignment:NSTextAlignmentCenter];
//    headerLabel.backgroundColor = [UIColor colorWithHexString:@"c8c8c8"];
//    [headerLabel setTextColor:[UIColor colorWithHexString:@"ffffff"]];
//    headerLabel.font = [UIFont systemFontOfSize:12.0];
//    headerLabel.layer.cornerRadius = 15.0;
//    headerLabel.layer.masksToBounds = YES;
//    [headerView addSubview:headerLabel];
    return self.tableviewHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"placeholder-name";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        //        cell = [cells objectAtIndex:0];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
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
