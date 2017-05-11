//
//  WYRegisterViewController.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/5/3.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYRegisterViewController.h"
#import "UIButton+YTLoginButton.h"
#import "UIButton+WebCache.h"
#import "WYCustomActionSheet.h"
#import "WYImagePickerController.h"
#import "UIImage+ProportionalFill.h"
#import "NSString+Value.h"

typedef NS_ENUM(NSInteger, UploadImageType){
    UploadImageTypeAvatar = 0,   //avatar
    UploadImageTypeSugao ,
    UploadImageTypeMakeup ,
    UploadImageTypeArts ,
};

@interface WYRegisterViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>
{
    UIImage *_avatarImage;
    NSString *_avatarUrlStr;
    
    UIImage *_sugaoImage;
    NSString *_sugaoUrlStr;
    
    UIImage *_makeupImage;
    NSString *_makeupUrlStr;
    
    UIImage *_artsImage;
    NSString *_artsUrlStr;
}

@property (nonatomic, assign) UploadImageType uploadImageType;

@property (nonatomic, weak) IBOutlet UITableView *tabelView;

@property (nonatomic, weak) IBOutlet UIView *registerContainerView;
@property (nonatomic, weak) IBOutlet UIButton *usrAvatarButton;
@property (nonatomic, weak) IBOutlet UILabel *avatarTipLabel;

@property (nonatomic, weak) IBOutlet UIView *accountContainerView;
@property (nonatomic, weak) IBOutlet UITextField *accountTextField;
@property (nonatomic, weak) IBOutlet UIView *emailContainerView;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

@property (nonatomic, weak) IBOutlet UILabel *uploadImageTipLabel;
@property (nonatomic, weak) IBOutlet UIButton *usrSugaoButton;
@property (nonatomic, weak) IBOutlet UILabel *sugaoTipLabel;
@property (nonatomic, weak) IBOutlet UIButton *usrMakeupButton;
@property (nonatomic, weak) IBOutlet UILabel *makeupTipLabel;
@property (nonatomic, weak) IBOutlet UIButton *usrArtsButton;
@property (nonatomic, weak) IBOutlet UILabel *artsTipLabel;

@property (nonatomic, weak) IBOutlet UIView *agentContainerView;
@property (nonatomic, weak) IBOutlet UITextField *agentTextField;

@property (nonatomic, weak) IBOutlet UILabel *registerRemindLabel;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;

@end

@implementation WYRegisterViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupSubview];
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self.view addGestureRecognizer:gestureRecongnizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self textFieldResignFirstResponder];
}

- (void)checkTextChaneg:(NSNotification *)notif
{
//    UITextField *textField = notif.object;
    [self loginButtonEnabled];
}

#pragma mark -
#pragma mark - Server
- (void)userRegisterRequest{
    
    NSString *accountText = [_accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailText = [_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *agentText = [_agentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![emailText isValidateEmail]) {
        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_validate_email_tip"]];
        return;
    }
    
    [MBProgressHUD showMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_info_submit_ing"]];
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"apply_anchor"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    
    [paramsDic setObject:accountText forKey:@"nick_name"];
    [paramsDic setObject:emailText forKey:@"email"];
    [paramsDic setObject:_avatarUrlStr forKey:@"head_icon"];
    [paramsDic setObject:_sugaoUrlStr forKey:@"low_pic"];
    [paramsDic setObject:_makeupUrlStr forKey:@"mid_pic"];
    [paramsDic setObject:_artsUrlStr forKey:@"hig_pic"];
    if (agentText.length > 0) {
        [paramsDic setObject:agentText forKey:@"channel_code"];
    }
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
            [MBProgressHUD showSuccess:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_succeed_tip"] toView:weakSelf.view];
            
            [weakSelf performSelector:@selector(rightButtonClicked:) withObject:nil afterDelay:1.0];
        }else{
            
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
    
}

- (void)uploadWithImageData:(NSData *)imageData uploadType:(UploadImageType)uploadType
{
    [MBProgressHUD showMessage:@"正在上传..."];
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"uploadfile"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
//    [paramsDic setObject:imageData forKey:@"pic"];
    WS(weakSelf);
    [self.networkManager POST:requestUrl formFileName:@"pic" fileName:@"img.jpg" fileData:imageData mimeType:@"image/jpeg" parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        
        [MBProgressHUD hideHUD];
        if (requestType == WYRequestTypeSuccess) {
            
            NSString *urlStr = nil;
            if ([dataObject isKindOfClass:[NSArray class]]) {
                NSArray *array = dataObject;
                if (array.count > 0) {
                    id pathObject = [array objectAtIndex:0];
                    if ([pathObject isKindOfClass:[NSDictionary class]]) {
                        urlStr = [pathObject objectForKey:@"path"];
                    }
                }
            }else if ([dataObject isKindOfClass:[NSString class]]){
                urlStr = dataObject;
            }
            
            if (uploadType == UploadImageTypeAvatar) {
                _avatarUrlStr = urlStr;
            }else if (uploadType == UploadImageTypeSugao){
                _sugaoUrlStr = urlStr;
            }else if (uploadType == UploadImageTypeMakeup){
                _makeupUrlStr = urlStr;
            }else if (uploadType == UploadImageTypeArts){
                _artsUrlStr = urlStr;
            }
            [weakSelf refreshHeadViewShow];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_photo_upload_errer_tip"]];
    }];
}

#pragma mark -
#pragma mark - Private Methods
- (void)setupSubview{
    
    _avatarImage = [UIImage imageNamed:@"wy_register_avatar_icon"];
    _avatarUrlStr = nil;
    _sugaoImage = [UIImage imageNamed:@"wy_register_avatar_1_icon"];
    _sugaoUrlStr = nil;
    _makeupImage = [UIImage imageNamed:@"wy_register_avatar_2_icon"];
    _makeupUrlStr = nil;
    _artsImage = [UIImage imageNamed:@"wy_register_avatar_3_icon"];
    _artsUrlStr = nil;
    
    _avatarTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_upload_avatar_tip"];
    _sugaoTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_upload_sugaor_tip"];
    _makeupTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_upload_makeup_tip"];
    _artsTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_upload_arts_tip"];
    _uploadImageTipLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_upload_images_tip"];
    _registerRemindLabel.text = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_remind_tip"];
    
    [self setTitle:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register"]];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightButton.backgroundColor = [UIColor yellowColor];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton setImage:[UIImage imageNamed:@"wy_login_close_icon"] forState:UIControlStateNormal];
    self.rightButton = rightButton;
    
    NSString *placeholder = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_account_placeholder"];
    self.accountTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[WYStyleSheet currentStyleSheet].subheadLabelFont color:UIColorHex(0xcacaca)];
    
    placeholder = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_email_placeholder"];
    self.emailTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[WYStyleSheet currentStyleSheet].subheadLabelFont color:UIColorHex(0xcacaca)];
    
    placeholder = [WYCommonUtils acquireCurrentLocalizedText:@"wy_register_agent_placeholder"];
    self.agentTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[WYStyleSheet currentStyleSheet].subheadLabelFont color:UIColorHex(0xcacaca)];
    
    
    self.accountContainerView.layer.cornerRadius = 3.0;
    self.accountContainerView.layer.masksToBounds = YES;
    
    self.emailContainerView.layer.cornerRadius = 3.0;
    self.emailContainerView.layer.masksToBounds = YES;
    
    self.agentContainerView.layer.cornerRadius = 3.0;
    self.agentContainerView.layer.masksToBounds = YES;
    
    self.registerButton.layer.cornerRadius = 3.0;
    self.registerButton.layer.masksToBounds = YES;
    self.registerButton.canClicked = NO;
    [self.registerButton setTitle:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register"] forState:UIControlStateNormal];
    
    
    [self refreshHeadViewShow];
}

- (void)textFieldResignFirstResponder{
    [self.accountTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.agentTextField resignFirstResponder];
}

- (void)refreshHeadViewShow{
    
    [self.usrAvatarButton setBackgroundImage:_avatarImage forState:UIControlStateNormal];
    [self.usrSugaoButton setBackgroundImage:_sugaoImage forState:UIControlStateNormal];
    [self.usrMakeupButton setBackgroundImage:_makeupImage forState:UIControlStateNormal];
    [self.usrArtsButton setBackgroundImage:_artsImage forState:UIControlStateNormal];
    
    if (_avatarUrlStr.length > 0) {
        [self.usrAvatarButton sd_setBackgroundImageWithURL:[NSURL URLWithString:_avatarUrlStr] forState:UIControlStateNormal placeholderImage:nil];
    }
    if (_sugaoUrlStr.length > 0) {
        [self.usrSugaoButton sd_setBackgroundImageWithURL:[NSURL URLWithString:_sugaoUrlStr] forState:UIControlStateNormal placeholderImage:nil];
    }
    if (_makeupUrlStr.length > 0) {
        [self.usrMakeupButton sd_setBackgroundImageWithURL:[NSURL URLWithString:_makeupUrlStr] forState:UIControlStateNormal placeholderImage:nil];
    }
    if (_artsUrlStr.length > 0) {
        [self.usrArtsButton sd_setBackgroundImageWithURL:[NSURL URLWithString:_artsUrlStr] forState:UIControlStateNormal placeholderImage:nil];
    }
    
    [self loginButtonEnabled];
    
    self.tabelView.tableHeaderView = self.registerContainerView;
    [self.tabelView reloadData];
}

- (BOOL)loginButtonEnabled{
    
    NSString *accountText = [_accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailText = [_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (accountText.length > 0 && emailText.length > 0 && _avatarUrlStr != nil && _sugaoUrlStr != nil && _makeupUrlStr != nil && _artsUrlStr != nil) {
        self.registerButton.canClicked = YES;
    }else{
        self.registerButton.canClicked = NO;
    }
    
    return YES;
}

- (void)chooseAvatar
{
    [self.view endEditing:YES];
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
//            [MBProgressHUD showError:@"请检查是否有相机"];
            return;
        }
    }
    imagePickerController.sourceType = sourceType;
    
    [imagePickerController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [imagePickerController.navigationBar setShadowImage:[UIImage new]];
    CGRect rect = imagePickerController.navigationBar.frame;
    UIImageView *navbgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, rect.size.width, 72)];
    navbgImageView.image = [UIImage imageNamed:@"wy_navbar_bg"];
    [imagePickerController.navigationBar addSubview:navbgImageView];
    
    [imagePickerController.navigationBar setTranslucent:NO];
    imagePickerController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[WYStyleSheet defaultStyleSheet].navTitleFont,NSFontAttributeName,nil];
    
    if (_uploadImageType == UploadImageTypeAvatar) {
        imagePickerController.allowsEditing = YES;
    }else{
        imagePickerController.allowsEditing = NO;
    }
    imagePickerController.delegate = self;
    imagePickerController.navigationController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Button Clicked
- (void)rightButtonClicked:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)avatarUploadAction:(id)sender{
    [self textFieldResignFirstResponder];
    //头像
    _uploadImageType = UploadImageTypeAvatar;
    [self chooseAvatar];
}
- (IBAction)sugaoUploadAction:(id)sender{
    [self textFieldResignFirstResponder];
    //素颜
    _uploadImageType = UploadImageTypeSugao;
    [self chooseAvatar];
}
- (IBAction)makeupUploadAction:(id)sender{
    [self textFieldResignFirstResponder];
    //上妆
    _uploadImageType = UploadImageTypeMakeup;
    [self chooseAvatar];
}
- (IBAction)artsUploadAction:(id)sender{
    [self textFieldResignFirstResponder];
    //艺术
    _uploadImageType = UploadImageTypeArts;
    [self chooseAvatar];
}

- (IBAction)doRegister:(id)sender
{
    [self textFieldResignFirstResponder];
    [self userRegisterRequest];
}

#pragma mark -
#pragma mark - Getters and Setters


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.registerButton.canClicked = NO;
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
    NSString *oldString = [textField.text copy];
    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    
    [self loginButtonEnabled];
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    
    if (!string.length && range.length > 0) {
        return YES;
    }
    
    
    if (textField == _accountTextField && textField.markedTextRange == nil) {
        if (newString.length > 10 && textField.text.length >= 10) {
            return NO;
        }
    }else if (textField == _emailTextField && textField.markedTextRange == nil){
        if (newString.length > 20 && textField.text.length >= 20) {
            return NO;
        }
    }else if (textField == _agentTextField && textField.markedTextRange == nil){
        if (newString.length > 16 && textField.text.length >= 16) {
            return NO;
        }
    }
    return YES;
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
    
    NSData *imageData = UIImageJPEGRepresentation(imageAfterScale, WY_IMAGE_COMPRESSION_QUALITY);
    if (self.uploadImageType == UploadImageTypeAvatar) {
        _avatarImage = imageAfterScale;
    }else if (self.uploadImageType == UploadImageTypeSugao){
        _sugaoImage = imageAfterScale;
    }else if (self.uploadImageType == UploadImageTypeMakeup){
        _makeupImage = imageAfterScale;
    }else if (self.uploadImageType == UploadImageTypeArts){
        _artsImage = imageAfterScale;
    }
    [self refreshHeadViewShow];
    
    [self uploadWithImageData:imageData uploadType:self.uploadImageType];
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
//    if (image.size.width != image.size.height) {
//        CGSize cropSize = image.size;
////        cropSize.height = MIN(image.size.width, image.size.height);
////        cropSize.width = MIN(image.size.width, image.size.height);
//        imageAfterScale = [image imageCroppedToFitSize:cropSize];
//    }
    
    NSData *imageData = UIImageJPEGRepresentation(imageAfterScale, compressionQuality);
    if (imageData.length > 400*1024) {
        UIImage *newImage = [UIImage imageWithData:imageData];
        imageAfterScale = newImage;
        imageData = UIImageJPEGRepresentation(newImage, compressionQuality);
    }
    if (self.uploadImageType == UploadImageTypeAvatar) {
        _avatarImage = imageAfterScale;
    }else if (self.uploadImageType == UploadImageTypeSugao){
        _sugaoImage = imageAfterScale;
    }else if (self.uploadImageType == UploadImageTypeMakeup){
        _makeupImage = imageAfterScale;
    }else if (self.uploadImageType == UploadImageTypeArts){
        _artsImage = imageAfterScale;
    }
    [self refreshHeadViewShow];
    
    [self uploadWithImageData:imageData uploadType:self.uploadImageType];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.tabelView) {
        [self textFieldResignFirstResponder];
    }
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

@end
