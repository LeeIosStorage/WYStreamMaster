//
//  WYLiveSetViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYAnchorApplyViewController.h"
#import "WYCustomActionSheet.h"
#import "UINavigationBar+Awesome.h"
#import "WYImagePickerController.h"
#import "UIImage+ProportionalFill.h"
#import "WYLoginManager.h"
typedef NS_ENUM(NSInteger, LiveUploadImageType){
    UploadImageTypeAvatar = 0,   //avatar
    UploadImageTypeAnchorNormal,
    UploadImageTypeAnchorMakeup,
    UploadImageTypeAnchorArt,
};

@interface WYAnchorApplyViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UITextFieldDelegate>
{
    UIImage *_avatarImage;
    NSString *_avatarUrlStr;
    
    UIImage *_normalImage;
    NSString *_normalImageStr;
    
    UIImage *_artImage;
    NSString *_artImageStr;
    
    UIImage *_makeupImage;
    NSString *_makeupImageStr;
    
}
@property (nonatomic, assign) LiveUploadImageType uploadImageType;
@property (nonatomic, strong) NSMutableArray *areaListArray;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIView *tableviewHeaderView;
// 提交按钮
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

// 头像
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
// 所在地
@property (strong, nonatomic) IBOutlet UITextField *agentTextField;
// 房间名称
@property (strong, nonatomic) IBOutlet UITextField *roomNameField;
// 昵称
@property (strong, nonatomic) IBOutlet UITextField *nicknameField;
@property (strong, nonatomic) IBOutlet UITextField *InvitationCodeField;
// 素颜照
@property (strong, nonatomic) IBOutlet UIImageView *normalImageView;
// 艺术照
@property (strong, nonatomic) IBOutlet UIImageView *artImageView;
// 化妆照
@property (strong, nonatomic) IBOutlet UIImageView *makeupImageView;

@end

@implementation WYAnchorApplyViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"主播申请";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    [self setupView];
    [self getAreaRequest];
//    [self uploadFileSaveLog:@"test"];
}
#pragma mark - setup
- (void)setupView
{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview reloadData];
    self.headerImageView.userInteractionEnabled = YES;
    self.makeupImageView.userInteractionEnabled = YES;
    self.normalImageView.userInteractionEnabled = YES;
    self.artImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureHeaderImageView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHeaderImageView)];
    [self.headerImageView addGestureRecognizer:tapGestureHeaderImageView];
    
    UITapGestureRecognizer *tapGestureNormalImageView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureNormalImageView)];
    [self.normalImageView addGestureRecognizer:tapGestureNormalImageView];

    
    UITapGestureRecognizer *tapGestureArtImageView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureArtImageView)];
    [self.artImageView addGestureRecognizer:tapGestureArtImageView];
    
    UITapGestureRecognizer *tapGestureMakeImageView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureMakeImageView)];
    [self.makeupImageView addGestureRecognizer:tapGestureMakeImageView];
    
    self.agentTextField.delegate = self;
    UITapGestureRecognizer *tapGestureView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureView)];
    [self.view addGestureRecognizer:tapGestureView];
    
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = [UIColor clearColor];
    self.nicknameField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.agentTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.roomNameField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.InvitationCodeField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.nicknameField.leftViewMode = UITextFieldViewModeAlways;
    self.agentTextField.leftViewMode = UITextFieldViewModeAlways;
    self.roomNameField.leftViewMode = UITextFieldViewModeAlways;
    self.InvitationCodeField.leftViewMode = UITextFieldViewModeAlways;
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

- (void)liveSetRequest
{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"applyAnchor"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    if ([_avatarUrlStr length] > 0) {
        [paramsDic setObject:_avatarUrlStr forKey:@"head_icon"];
    } else {
        [paramsDic setObject:@"1.jpg" forKey:@"head_icon"];
    }
    if ([_normalImageStr length] > 0) {
        [paramsDic setObject:_normalImageStr forKey:@"anchor_show_PC"];
    } else {
        [paramsDic setObject:@"1.jpg" forKey:@"anchor_show_PC"];
    }
    if ([_makeupImageStr length] > 0) {
        [paramsDic setObject:_makeupImageStr forKey:@"mid_pic"];
    } else {
        [paramsDic setObject:@"1.jpg" forKey:@"mid_pic"];
    }
    if ([_artImageStr length] > 0) {
        [paramsDic setObject:_artImageStr forKey:@"hig_pic"];
    } else {
        [paramsDic setObject:@"1.jpg" forKey:@"hig_pic"];
    }
    [paramsDic setObject:self.agentTextField.text forKey:@"anchor_country"];
//    [paramsDic setObject:@"15600119570@163.com" forKey:@"email"];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:self.nicknameField.text forKey:@"nick_name"];

    //    [paramsDic setObject:_avatarUrlStr forKey:@"head_icon"];
    //    [paramsDic setObject:_sugaoUrlStr forKey:@"low_pic"];
    //    [paramsDic setObject:_makeupUrlStr forKey:@"mid_pic"];
    //    [paramsDic setObject:_artsUrlStr forKey:@"hig_pic"];
    //    if (self.areaCode.length > 0) {
    //        [paramsDic setObject:self.areaCode forKey:@"anchor_country"];//channel_code
    //    }
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
//            [YTToast showSuccess:@"申请成功，请等待审核"];
            [WYLoginManager sharedManager].loginModel.audit_statu = @"1";
            [MBProgressHUD showSuccess:@"申请成功，请等待审核" toView:weakSelf.view];
            [weakSelf performSelector:@selector(popLastViewCtroller) withObject:nil afterDelay:1.0];
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

- (void)uploadWithImageData:(NSData *)imageData uploadType:(LiveUploadImageType)uploadType
{
    [MBProgressHUD showMessage:@"正在上传..."];
//    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"upload_image"];

    NSString *requestUrl = @"http://http://172.16.2.180:8090/event-platform-admin/file/ios_image?";

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
            
            if (uploadType == UploadImageTypeAvatar) {
                _avatarUrlStr = urlStr;
            } else if (uploadType == UploadImageTypeAnchorNormal){
                _normalImageStr = urlStr;
            } else if (uploadType == UploadImageTypeAnchorMakeup){
                _makeupImageStr = urlStr;
            } else if (uploadType == UploadImageTypeAnchorArt){
                _artImageStr = urlStr;
            }
        } else {
            NSLog(@"");
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_photo_upload_errer_tip"] toView:weakSelf.view];
    }];
}

// 上传日志
- (void)uploadFileSaveLog:(NSString *)fileLog
{
    NSString *currentTimes = @"2017.11.20 12:30";
    NSString *fileContent = [NSString stringWithFormat:@"%@%@", fileLog,currentTimes];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileContent]];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSData *fileData = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
    [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
//    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"upload_image"];
    NSString *requestUrl = @"http://172.16.10.234:8090/event-platform-admin/file/ios_image?";
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"bizImgPath"];
    [paramsDic setObject:@"2" forKey:@"saveType"];
    [self.networkManager POST:requestUrl formFileName:@"file" fileName:filePath fileData:fileData mimeType:@"txt" parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        if (requestType == WYRequestTypeSuccess) {
            NSLog(@"");
        } else {
            NSLog(@"");
        }
    } failure:^(id responseObject, NSError *error) {
        NSLog(@"");
    }];
}
#pragma mark - Getters and Setters
- (void)popLastViewCtroller{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)tapGestureNormalImageView
{
    [self tapGestureView];
    self.uploadImageType = UploadImageTypeAnchorNormal;
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

- (void)tapGestureMakeImageView
{
    [self tapGestureView];
    self.uploadImageType = UploadImageTypeAnchorMakeup;
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

- (void)tapGestureArtImageView
{
    [self tapGestureView];
    
    self.uploadImageType = UploadImageTypeAnchorArt;
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
    [self.InvitationCodeField resignFirstResponder];
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
        self.headerImageView.image = [UIImage imageWithData:imageData];
    } else if (self.uploadImageType == UploadImageTypeAnchorNormal){
        self.normalImageView.image = [UIImage imageWithData:imageData];
    } else if (self.uploadImageType == UploadImageTypeAnchorMakeup){
        self.makeupImageView.image = [UIImage imageWithData:imageData];
    } else if (self.uploadImageType == UploadImageTypeAnchorArt){
        self.artImageView.image = [UIImage imageWithData:imageData];
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
    return 620;
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
