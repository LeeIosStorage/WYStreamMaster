//
//  WYCommonUtils.h
//  WYRecordMaster
//
//  Created by Leejun on 16/9/14.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYSuperViewController.h"

@interface WYCommonUtils : NSObject

/**
 *  根据固定的Width 计算 AttributedString 的Size
 *
 *  @param text        文本
 *  @param lineSpacing 行高（对应getAttributedStringWithString:lineSpacing:alignment:）
 *  @param font        自定义字体
 *  @param width       固定的Width
 *
 *  @return text的Size
 */
+ (CGSize)sizeWithAttributedText:(NSString *)text lineSpacing:(CGFloat)lineSpacing font:(UIFont *)font width:(float)width;
/**
 *  NSString转为NSAttributedString
 *
 *  @param string      NSString
 *  @param lineSpacing 行高（对应sizeWithAttributedText:lineSpacing:font:width方法）
 *  @param alignment   NSTextAlignment
 *
 *  @return NSAttributedString
 */
+ (NSAttributedString *)getAttributedStringWithString:(NSString*)string lineSpacing:(CGFloat)lineSpacing alignment:(NSTextAlignment)alignment;

//富文本 颜色 字体
+ (NSMutableAttributedString *)stringToColorAndFontAttributeString:(NSString *)text range:(NSRange)range font:(UIFont *)font color:(UIColor *)color;

+ (void)shakeAnimationForView:(UIView *) view;

+(void)showAlertWithMsg:(NSString *)msg;

+ (void)setImageWithURL:(NSURL *)url setImageView:(UIImageView *)imageView placeholderImage:(NSString *)placeholderImage;

+ (NSString *)planMaxNumberToString:(NSString *)str;

//时间处理
+ (NSDate*)dateFromUSDateString:(NSString*)string;
//20:01
+ (NSString*)dateHourToMinuteDiscriptionFromDate:(NSDate*)date;
//刚刚、几分钟前...
+ (NSString*)dateDiscriptionFromNowBk:(NSDate*)date;

//音频的授权状态
+ (BOOL)checkMicrophonePermissionStatus;
//请求麦克风权限
+ (void)requsetMicrophonePermission;
//相机的授权状态
+ (BOOL)userCaptureIsAuthorization;
//请求相机权限
+ (void)requsetCameraMediaPermission;
//设备是否有摄像头
+(BOOL)userCameraIsUsable;

+ (WYSuperViewController *)getCurrentVC;

//取当前系统语言对应文案
+ (NSString *)acquireCurrentLocalizedText:(NSString *)text;

@end
