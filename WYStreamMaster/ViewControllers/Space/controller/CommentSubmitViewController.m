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
#import <AFNetworking/AFNetworking.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVAsset.h>

#define VIDEOCACHEPATH [NSTemporaryDirectory() stringByAppendingPathComponent:@"videoCache"]

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
@property (nonatomic, strong) NSString *videoString;
@property (nonatomic, strong) UIImage *videoImage;

@end

@implementation CommentSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _commentTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.contentView.layer.masksToBounds = YES;
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
    if (self.imageString.length == 0 && content.length == 0 && self.videoString.length == 0) {
        [MBProgressHUD showBottomMessage:@"说点什么吧~~" toView:self.view];
        return;
    }
//    NSMutableString *addString = [NSMutableString string];
    NSMutableArray *imgs = nil;
    if (self.imageString.length > 0) {
        imgs = [NSMutableArray array];
        [imgs addObject:self.imageString];
    }
    //    NSString *requestUrl = @"http://172.16.10.107/blog/api/publish_blog.do?";
    [MBProgressHUD showMessage:@"发布中..." toView:self.view];
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"publish_blog"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [params setObject:content forKey:@"content"];

    if (imgs && imgs.count > 0) {
        NSString * imgsString;
        imgsString = [WYCommonUtils stringSplitWithCommaForIds:imgs];
        [params setObject:[NSString stringWithFormat:@"%@", imgsString] forKey:@"images"];
    }
    if (self.videoString && self.videoString.length > 0) {
        [params setObject:self.videoString forKey:@"videos"];
    }
    WEAKSELF
    [self.networkManager POST:requestUrl needCache:YES parameters:params responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        WYLog(@"dataObject = %@",dataObject);
        [MBProgressHUD hideHUDForView:weakSelf.view];
        if (requestType == WYRequestTypeSuccess) {
            [MBProgressHUD showSuccess:@"发布成功" toView:weakSelf.view];
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
    //获取用户选择或拍摄的是照片还是视频
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
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
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {

        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSURL *newVideoUrl ; //一般.mp4
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]] ;//这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
        [self convertVideoQuailtyWithInputURL:sourceURL outputURL:newVideoUrl completeHandler:nil];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//以当前时间合成视频名称
- (NSString *)getVideoNameBaseCurrentTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".MOV"];
}

//将视频保存到缓存路径中
- (void)saveVideoFromPath:(NSString *)videoPath toCachePath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:VIDEOCACHEPATH]) {
        
        NSLog(@"路径不存在, 创建路径");
        [fileManager createDirectoryAtPath:VIDEOCACHEPATH
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    } else {
        
        NSLog(@"路径存在");
    }
    
    NSError *error;
    [fileManager copyItemAtPath:videoPath toPath:path error:&error];
    if (error) {
        
        NSLog(@"文件保存到缓存失败");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - upload
- (void)uploadImageWithData:(NSData *)imageData{
    [MBProgressHUD showSuccess:@"正在上传..." toView:self.view];
    WS(weakSelf);
//    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"upload_image"];
    NSString *requestUrl = @"http://122.224.221.203:8090/event-platform-admin/file/ios_image?";
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"bizImgPath"];
    [paramsDic setObject:@"1" forKey:@"saveType"];

    [self.networkManager POST:requestUrl formFileName:@"pic" fileName:@"image.jpg" fileData:imageData mimeType:@"image/jpeg" parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        STRONGSELF
        [MBProgressHUD hideHUDForView:strongSelf.view];
        if (requestType == WYRequestTypeSuccess) {
            [strongSelf.addImageButton setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            [weakSelf changeOld:strongSelf.addImageButton];
            NSDictionary *updateImageUrl = dataObject;
            if (updateImageUrl) {
                if (strongSelf.imageString.length == 0) {
                    strongSelf.imageString = updateImageUrl[@"path"];
                } else {
                    strongSelf.imageString = [NSString stringWithFormat:@"%@,%@", strongSelf.imageString, updateImageUrl[@"path"]];
                }
            }
            [MBProgressHUD showSuccess:@"上传成功" toView:strongSelf.view];
        }else{
            [MBProgressHUD showError:message];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view];
        [MBProgressHUD showError:@"图片上传失败"];
    }];
}
// 上传视频
- (void)uploadVideoWithData:(NSData *)videoData{
    WS(weakSelf);
    //    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"upload_image"];
    NSString *requestUrl = @"http://122.224.221.203:8090/event-platform-admin/file/ios_image?";
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"bizImgPath"];
    [paramsDic setObject:@"1" forKey:@"saveType"];
    
    [self.networkManager POST:requestUrl formFileName:@"video" fileName:@"aa.MOV" fileData:videoData mimeType:@"video/mpeg" parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        STRONGSELF
        [MBProgressHUD hideHUDForView:strongSelf.view];
        if (requestType == WYRequestTypeSuccess) {
            NSDictionary *updateImageUrl = dataObject;
            if (updateImageUrl) {
                strongSelf.videoString = updateImageUrl[@"path"];
                UIImage *videoImage = [weakSelf thumbnailImageForVideo:[NSURL URLWithString:updateImageUrl[@"path"]] atTime:0];
                [strongSelf.addImageButton setImage:videoImage forState:UIControlStateNormal];
            }
            [MBProgressHUD showSuccess:@"上传成功" toView:strongSelf.view];
        }else{
            [MBProgressHUD showError:message];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view];
        [MBProgressHUD showError:@"视频上传失败"];
    }];
}
- (void)convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                              outputURL:(NSURL*)outputURL
                        completeHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    //  NSLog(resultPath);
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
                 [self alertUploadVideo:outputURL];
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
         
     }];
}

-(void)alertUploadVideo:(NSURL*)URL{
    NSData *data = [NSData dataWithContentsOfURL:URL];
    [self uploadVideoWithData:data];
}
#pragma mark -
#pragma mark - Getters and Setters
- (void)changeOld:(UIButton *)btn
{
    if (btn.tag == 9) {
        return;
    }
    NSInteger tag = btn.tag;
    UIButton *newButton = [self.view viewWithTag:tag + 1];
    newButton.hidden = NO;
    self.addImageButton = newButton;
}

- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

@end
