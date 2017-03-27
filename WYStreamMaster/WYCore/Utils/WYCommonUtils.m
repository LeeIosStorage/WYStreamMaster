//
//  WYCommonUtils.m
//  WYRecordMaster
//
//  Created by Leejun on 16/9/14.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYCommonUtils.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>

@implementation WYCommonUtils

+ (CGSize)sizeWithAttributedText:(NSString *)text lineSpacing:(CGFloat)lineSpacing font:(UIFont *)font width:(float)width{
    
    NSUInteger length = [text length];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = lineSpacing;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    [attrString addAttributes:attributes range:NSMakeRange(0, length)];
    //NSStringDrawingUsesFontLeading 不需要这个属性
    CGSize textSize = [attrString boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine| NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return textSize;
}

+ (NSAttributedString *)getAttributedStringWithString:(NSString*)string lineSpacing:(CGFloat)lineSpacing alignment:(NSTextAlignment)alignment{
    NSUInteger length = [string length];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = lineSpacing;
    style.alignment = alignment;
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, length)];
    return attrString;
}

+ (NSMutableAttributedString *)stringToColorAndFontAttributeString:(NSString *)text range:(NSRange)range font:(UIFont *)font color:(UIColor *)color{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:text];
    if (color) {
        [attStr addAttribute:NSForegroundColorAttributeName
                       value:color
                       range:range];
    }
    if (font) {
        [attStr addAttribute:NSFontAttributeName
                       value:font
                       range:range];
    }
    if (color && font) {
        NSDictionary *attributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:color};
        [attStr addAttributes:attributes range:range];
    }
    return attStr;
}


+ (void)shakeAnimationForView:(UIView *) view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    
    CGPoint x = CGPointMake(position.x + 8, position.y);
    CGPoint y = CGPointMake(position.x - 8, position.y);
    
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    
    // 设置自动反转
    [animation setAutoreverses:YES];
    
    [animation setDuration:.06];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
    
}

+(void)showAlertWithMsg:(NSString *)msg
{
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:nil message:msg];
    [alertView bk_setCancelButtonWithTitle:@"知道啦" handler:^{
        
    }];
    
    [alertView show];
}

// 加载图片
+ (void)setImageWithURL:(NSURL *)url setImageView:(UIImageView *)imageView placeholderImage:(NSString *)placeholderImage{
    if (![url isEqual:[NSNull null]]) {
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:placeholderImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image && cacheType == SDImageCacheTypeNone) {
                imageView.alpha = 0.0;
                [UIView transitionWithView:imageView
                                  duration:1.0
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [imageView setImage:image];
                                    imageView.alpha = 1.0;
                                } completion:NULL];
            }
        }];
    }else{
        [imageView sd_setImageWithURL:nil];
        [imageView setImage:[UIImage imageNamed:placeholderImage]];
    }
}

+ (BOOL)checkMicrophonePermissionStatus
{
    // 请求音频的授权状态
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
            // 已授权
        case AVAuthorizationStatusAuthorized:
            return YES;
            break;
            // 未授权
        case AVAuthorizationStatusNotDetermined:
            // 拒绝授权
        case AVAuthorizationStatusDenied:
            // 设备受限，一般在家长模式下设备会受限
        case AVAuthorizationStatusRestricted:
        default:
            return NO;
            break;
    }
}

+ (void)requsetMicrophonePermission
{
    // 请求麦克风权限
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (available) {
                //completionHandler
            }
            else {
            }
        }];
    }
    [AVCaptureDevice class];
}

+ (void)requsetCameraMediaPermission{
    
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        
    }];
}

+ (BOOL)userCaptureIsAuthorization
{
    BOOL isAuthor = NO;
    
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus status = (NSInteger)[[AVCaptureDevice class] performSelector:@selector(authorizationStatusForMediaType:) withObject: AVMediaTypeVideo];
        if (AVAuthorizationStatusAuthorized == status) {
            isAuthor = YES;
        }
    }
    
    return isAuthor;
}

+(BOOL)userCameraIsUsable{
    BOOL isUsable = YES;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] < 1) {
        isUsable = NO;
    }
    return isUsable;
}

@end
