//
//  CommentSubmitViewController.m
//  WangYu
//
//  Created by miqu on 16/8/11.
//  Copyright © 2016年 KID. All rights reserved.
//

#import "CommentSubmitViewController.h"
#import "WYCustomActionSheet.h"
#import "WYLoginManager.h"
#import "MBProgressHUD+WYTools.h"
#import "UIImage+ProportionalFill.h"

@interface CommentSubmitViewController ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    int _maxReplyTextLength;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UILabel *textCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeHoldLabel;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSString *imageString;

@end

@implementation CommentSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _commentTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    
    self.contentView.layer.masksToBounds = YES;
//    self.contentView.layer.cornerRadius = 4;
//    self.contentView.layer.borderWidth = 0.5;
//    self.contentView.layer.borderColor = [WYStyleSheet defaultStyleSheet].contentLabelColor.CGColor;
    [self.contentView setLayerShadow:[UIColor colorWithHexString:@"e6e6e6"] offset:CGSizeMake(0, 0) radius:5.f];
    self.contentView.layer.shadowOpacity = .8f;
    
    [self setTitle:@"发布动态"];
    _maxReplyTextLength = 150;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.textCountLabel.text];

    [attributedString addAttribute:NSForegroundColorAttributeName value:[WYStyleSheet defaultStyleSheet].titleLabelSelectedColor range:NSMakeRange(5, 3)];

    self.textCountLabel.attributedText = attributedString;
    
    self.commentTextView.delegate = self;
    [self textViewDidChange:self.commentTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightButtonClicked:(id)sender{
    [self submitAction:nil];
}

- (IBAction)addImageAction:(id)sender {
    [self.commentTextView resignFirstResponder];
    WYCustomActionSheet *sheet = [[WYCustomActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
        if (2 == buttonIndex) {
            return;
        }
        
        [self doActionSheetClickedButtonAtIndex:buttonIndex];
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"从手机相册选择", @"拍一张(视频)"]];
    [sheet showInView:self.view];
}

- (void)submitAction:(id)sender{
    
    [self.commentTextView resignFirstResponder];
    [self commitComment];
}


#pragma mark - 评论的
- (void)commitComment{
    NSString *content = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.imageString.length == 0 && content.length == 0) {
        [MBProgressHUD showBottomMessage:@"说点什么吧~~" toView:self.view];
        return;
    }
    NSMutableArray *imgs = nil;
    if (self.imageString.length > 0) {
        imgs = [NSMutableArray array];
        [imgs addObject:self.imageString];
    }
    [MBProgressHUD showMessage:@"发布中..." toView:self.view];
    WS(weakSelf);
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"publish_blog"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [params setObject:content forKey:@"content"];
    if (imgs && imgs.count > 0) {
        NSString * imgsString;
        imgsString = [WYCommonUtils stringSplitWithCommaForIds:imgs];
        [params setObject:imgsString forKey:@"img"];
    }
    [self.networkManager POST:requestUrl needCache:YES parameters:params responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        WYLog(@"dataObject = %@",dataObject);
        [MBProgressHUD hideHUDForView:weakSelf.view];
        if (requestType == WYRequestTypeSuccess) {
            [MBProgressHUD showSuccess:@"发布成功" toView:weakSelf.view];
//            NSDictionary *dic = dataObject;
//            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(submitRequestSucceedWithCommentInfo:)]) {
//                [weakSelf.delegate submitRequestSucceedWithCommentInfo:commentInfo];
//            }
            [weakSelf performSelector:@selector(popLastViewCtroller) withObject:nil afterDelay:1.0];
        }else{
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view];
        [MBProgressHUD showError:@"请求失败" toView:weakSelf.view];
    }];
}

- (void)popLastViewCtroller{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.commentTextView) {
        if (textView.text.length == 0) {
            self.placeHoldLabel.hidden = NO;
        } else {
            self.placeHoldLabel.hidden = YES;
        }
        NSUInteger remainNumber =  _maxReplyTextLength - textView.text.length;
        NSInteger legth;
        if (remainNumber > 99) {
            legth = 3;
        } else if (remainNumber > 9){
            legth = 2;
        } else {
            legth = 1;
        }
        self.textCountLabel.text = [NSString stringWithFormat:@"还可以输入%ld字",(unsigned long)remainNumber];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.textCountLabel.text];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[WYStyleSheet defaultStyleSheet].titleLabelSelectedColor range:NSMakeRange(5, legth)];
        self.textCountLabel.attributedText = attributedString;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""] && range.length > 0) {
        return YES;
    } else {
        if (textView.text.length - range.length + text.length > _maxReplyTextLength) {
            return NO;
        } else {
            return YES;
        }
    }
}


-(void)doActionSheetClickedButtonAtIndex:(NSInteger)buttonIndex{
    
//    if (0 == buttonIndex) {
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        WSAssetPickerController *assetPickerController = [[WSAssetPickerController alloc] initWithAssetsLibrary:library];
//        assetPickerController.delegate = self;
//        assetPickerController.selectionLimit = 1;
//        assetPickerController.allowsEditing = YES;
//        [self presentViewController:assetPickerController animated:YES completion:NULL];
//        return;
//    }
    
    if (1 == buttonIndex ) {
        
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker.navigationBar setBarTintColor:[WYStyleSheet defaultStyleSheet].themeColor];
    [picker.navigationBar setTranslucent:NO];
    NSArray* mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];

    picker.mediaTypes = mediaTypes;
    picker.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[WYStyleSheet defaultStyleSheet].navTitleFont,NSFontAttributeName,nil];
    
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (buttonIndex == 1) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self.navigationController presentViewController:picker animated:YES completion:NULL];
}

#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    {
        UIImage* imageAfterScale = image;
        if (image.size.width != image.size.height) {
            CGSize cropSize = image.size;
            cropSize.height = MIN(image.size.width, image.size.height);
            cropSize.width = MIN(image.size.width, image.size.height);
            imageAfterScale = [image imageCroppedToFitSize:cropSize];
        }
        NSData* imageData = UIImageJPEGRepresentation(imageAfterScale, WY_IMAGE_COMPRESSION_QUALITY);
        [self uploadImageWithData:imageData];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString  *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    {
        UIImage* imageAfterScale = image;
        if (image.size.width != image.size.height) {
            CGSize cropSize = image.size;
            cropSize.height = MIN(image.size.width, image.size.height);
            cropSize.width = MIN(image.size.width, image.size.height);
            imageAfterScale = [image imageCroppedToFitSize:cropSize];
        }
        NSData* imageData = UIImageJPEGRepresentation(imageAfterScale, WY_IMAGE_COMPRESSION_QUALITY);
        [self uploadImageWithData:imageData];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)uploadImageWithData:(NSData *)imageData{
    
    [MBProgressHUD showSuccess:@"正在上传..." toView:self.view];
    WS(weakSelf);
//    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"upload_image"];
    NSString *requestUrl = @"http://122.224.221.203:8090/event-platform-admin/file/ios_image?";
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"bizImgPath"];
    [paramsDic setObject:@"1" forKey:@"saveType"];

    [self.networkManager POST:requestUrl formFileName:@"pic" fileName:@"pic" fileData:imageData mimeType:@"video/MOV" parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        STRONGSELF
        [MBProgressHUD hideHUDForView:strongSelf.view];
        if (requestType == WYRequestTypeSuccess) {
            [strongSelf.addImageButton setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            NSDictionary *updateImageUrl = dataObject;
            if (updateImageUrl) {
                strongSelf.imageString = updateImageUrl[@"path"];
            }
            [MBProgressHUD showSuccess:@"上传成功"];
            
        }else{
            [MBProgressHUD showError:message];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view];
        [MBProgressHUD showError:@"图片上传失败"];
    }];
}

@end
