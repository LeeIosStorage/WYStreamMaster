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
UIImagePickerControllerDelegate,
UITextFieldDelegate>
{
    UIImage *_avatarImage;
    NSString *_avatarUrlStr;
    
    UIImage *_anchorCoverImage;
    NSString *_anchorCoverStr;
}
@property (nonatomic, assign) LiveUploadImageType uploadImageType;
@property (nonatomic, strong) NSMutableArray *areaListArray;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIView *tableviewHeaderView;
// 提交按钮
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
// 直播封面
@property (strong, nonatomic) IBOutlet UIImageView *liveCoverImageView;
// 头像
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
// 所在地
@property (strong, nonatomic) IBOutlet UITextField *agentTextField;
// 房间名称
@property (strong, nonatomic) IBOutlet UITextField *roomNameField;
// 昵称
@property (strong, nonatomic) IBOutlet UITextField *nicknameField;

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
    [self getAreaRequest];
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
    self.agentTextField.delegate = self;
    
    UITapGestureRecognizer *tapGestureView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureView)];
    [self.view addGestureRecognizer:tapGestureView];
}
#pragma mark -
#pragma mark - Server
- (void)getAreaRequest{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"queryCountry"];
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:nil responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        
        if (requestType == WYRequestTypeSuccess) {
            
            weakSelf.areaListArray = [NSMutableArray array];
            if ([dataObject isKindOfClass:[NSArray class]]) {
                weakSelf.areaListArray = dataObject;
            }
            
        }else{
        }
        
    } failure:^(id responseObject, NSError *error) {
        //        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

- (void)uploadWithImageData:(NSData *)imageData uploadType:(LiveUploadImageType)uploadType
{
    WEAKSELF
    [MBProgressHUD showMessage:@"正在上传..."];
//    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"uploadfile"];
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"upload_image"];
    //        NSString *requestUrl = @"http://www.legend8888.com/files/api/uploadfile.do?";
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"bizImgPath"];
    [self.networkManager POST:requestUrl formFileName:@"pic" fileName:@"img.jpg" fileData:imageData mimeType:@"image/jpeg" parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        
        [MBProgressHUD hideHUD];
        if (requestType == WYRequestTypeSuccess) {
            [MBProgressHUD showSuccess:@"上传成功" toView:weakSelf.view];
            NSString *urlStr = nil;
            if ([dataObject isKindOfClass:[NSArray class]]) {
                NSArray *array = dataObject;
                if (array.count > 0) {
                    id pathObject = [array objectAtIndex:0];
                    if ([pathObject isKindOfClass:[NSDictionary class]]) {
                        urlStr = [pathObject objectForKey:@"path"];
                    }
                }
            } else if ([dataObject isKindOfClass:[NSString class]]){
                urlStr = dataObject;
            }
            
            if (uploadType == UploadImageTypeAvatar) {
                _avatarUrlStr = urlStr;
            }else if (uploadType == UploadImageTypeAnchorCover){
                _anchorCoverStr = urlStr;
            }
        } else {
            NSLog(@"");
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_photo_upload_errer_tip"] toView:weakSelf.view];
    }];
}


- (void)liveSetRequest
{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"live_set"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    if ([_avatarUrlStr length] > 0) {
        [paramsDic setObject:_avatarUrlStr forKey:@"head_icon"];
    } else {
        [paramsDic setObject:@"1.jpg" forKey:@"head_icon"];
    }
    if ([_anchorCoverStr length] > 0) {
        [paramsDic setObject:_anchorCoverStr forKey:@"anchor_show_H5"];
        [paramsDic setObject:_anchorCoverStr forKey:@"anchor_show_PC"];
    } else {
        [paramsDic setObject:@"2.jpg" forKey:@"anchor_show_H5"];
        [paramsDic setObject:@"3.jpg" forKey:@"anchor_show_PC"];
    }
    [paramsDic setObject:self.roomNameField.text forKey:@"room_name"];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:self.nicknameField.text forKey:@"nick_name"];
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        if (requestType == WYRequestTypeSuccess) {
//            [YTToast showSuccess:@"设置成功"];

//            [MBProgressHUD showSuccess:@"设置成功" toView:weakSelf.view];
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

#pragma mark - event
- (void)tapGestureHeaderImageView
{
    [self tapGestureView];
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
    [self tapGestureView];
    
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
    [self liveSetRequest];
}

- (void)tapGestureView
{
    [self.roomNameField resignFirstResponder];
    [self.nicknameField resignFirstResponder];
    [self.agentTextField resignFirstResponder];
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

- (void)showSelectAreaView{
    WEAKSELF
    NSMutableArray *otherButtonTitles = [NSMutableArray array];
    
    for (NSDictionary *dic in self.areaListArray) {
        NSString *areaName = [dic stringObjectForKey:@"Chain_name"];
        if ([[WYCommonUtils getPreferredLanguage] containsString:@"en"]) {
            areaName = [dic stringObjectForKey:@"English_name"];
        }
        [otherButtonTitles addObject:areaName];
    }
    WYCustomActionSheet *actionSheet = [[WYCustomActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex >= otherButtonTitles.count) {
            return;
        }
        NSDictionary *dic = [weakSelf.areaListArray objectAtIndex:buttonIndex];
        weakSelf.agentTextField.text = [dic stringObjectForKey:@"Chain_name"];
        if ([[WYCommonUtils getPreferredLanguage] rangeOfString:@"en"].location !=NSNotFound) {
            weakSelf.agentTextField.text = [dic stringObjectForKey:@"English_name"];
        }
//        weakSelf.areaCode = [dic stringObjectForKey:@"short_name"];
        
    } cancelButtonTitle:[WYCommonUtils acquireCurrentLocalizedText:@"wy_cancel"] destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles];
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
    if (self.uploadImageType == UploadImageTypeAvatar) {
        _avatarImage = imageAfterScale;
        self.headerImageView.image = [UIImage imageWithData:imageData];
    }else if (self.uploadImageType == UploadImageTypeAnchorCover){
        _anchorCoverImage = imageAfterScale;
        self.liveCoverImageView.image = [UIImage imageWithData:imageData];
    } else if (self.uploadImageType == UploadImageTypeAnchorCover){
        _anchorCoverImage = imageAfterScale;
        self.liveCoverImageView.image = [UIImage imageWithData:imageData];
    } else if (self.uploadImageType == UploadImageTypeAnchorCover){
        _anchorCoverImage = imageAfterScale;
        self.liveCoverImageView.image = [UIImage imageWithData:imageData];
    }
    
    [self uploadWithImageData:imageData uploadType:self.uploadImageType];
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
#pragma mark - 
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.agentTextField) {
        [self showSelectAreaView];
        return NO;
    }
    return YES;
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
