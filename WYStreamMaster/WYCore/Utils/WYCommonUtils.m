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

#define DAY_SECOND 60*60*24

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
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.legend8888.com%@", [url absoluteString]]];
    }
    if (!placeholderImage) {
        placeholderImage = @"wy_common_placehoder_image";
    }
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

+ (NSString *)planMaxNumberToString:(NSString *)str{
    NSString *maxStr = @"0";
    if (!str) {
        return maxStr;
    }
    if ([str integerValue] > 10000) {
        maxStr = [NSString stringWithFormat:@"%.2fW",(float)[str integerValue]/10000.f];
    } else {
        maxStr = str;
    }
    
    return maxStr;
}

#pragma mark -
#pragma mark - 时间处理
static NSDateFormatter * s_dateFormatterOFUS = nil;
static bool dateFormatterOFUSInvalid ;
+ (NSDate*)dateFromUSDateString:(NSString*)string{
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    @synchronized(self) {
        if (s_dateFormatterOFUS == nil || dateFormatterOFUSInvalid) {
            s_dateFormatterOFUS = [[NSDateFormatter alloc] init];
            [s_dateFormatterOFUS setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//EEE MMM d HH:mm:ss zzzz yyyy
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [s_dateFormatterOFUS setLocale:usLocale];
            dateFormatterOFUSInvalid = NO;
        }
    }
    
    NSDateFormatter* dateFormatter = s_dateFormatterOFUS;
    NSDate* date = nil;
    @synchronized(dateFormatter){
        @try {
            date = [dateFormatter dateFromString:string];
        }
        @catch (NSException *exception) {
            //异常了以后处理有些问题,有可能会crash
            dateFormatterOFUSInvalid = YES;
        }
    }
    return date;
}

+ (NSString*)dateHourToMinuteDiscriptionFromDate:(NSDate*)date{
    NSString *_timestamp = nil;
    if (date == nil) {
        return @"";
    }
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents *comps = [calender components:unitFlags fromDate:date];
    
    _timestamp = [NSString stringWithFormat:@"%02d:%02d",(int)comps.hour, (int)comps.minute];
    
    return _timestamp;
}

+ (NSString*)dateDiscriptionFromNowBk:(NSDate*)date{
    NSString *_timestamp = nil;
    NSDate* nowDate = [NSDate date];
    if (date == nil) {
        return @"";
    }
    int distance = [nowDate timeIntervalSinceDate:date];
    if (distance < 0) distance = 0;
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents *comps = [calender components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calender components:unitFlags fromDate:nowDate];
    
    if (distance >= 0) {
        if (distance < 60) {
            _timestamp = [NSString stringWithFormat:@"%@", @"刚刚"];
        } else if (distance < 60*60) {
            _timestamp = [NSString stringWithFormat:@"%d%@", distance/60, @"分钟前"];
        }else if (distance < DAY_SECOND) {
            if (comps.day == compsNow.day)
            {
                _timestamp = [NSString stringWithFormat:@"今天 %02d:%02d", (int)comps.hour,(int)comps.minute];
            }
            else
                _timestamp = [NSString stringWithFormat:@"昨天 %02d:%02d", (int)comps.hour,(int)comps.minute];
        }
        else {
            compsNow.hour = compsNow.minute = compsNow.second = 0;
            NSDate *startOfToday = [calender dateFromComponents:compsNow];
            distance = [startOfToday timeIntervalSinceDate:date];
            if (distance <= DAY_SECOND) {
                _timestamp = [NSString stringWithFormat:@"昨天 %02d:%02d", (int)comps.hour,(int)comps.minute];
            }
            else{
                if (comps.year == compsNow.year){
                    _timestamp = [NSString stringWithFormat:@"%d月%d日 %02d:%02d", (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
                } else {
                    _timestamp = [NSString stringWithFormat:@"%04d年%02d月%02d日 %02d:%02d", (int)comps.year, (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
                }
            }
        }
    }else{
        _timestamp = [NSString stringWithFormat:@"%04d年%02d月%02d日 %02d:%02d", (int)comps.year, (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
    }
    
    return _timestamp;
}


#pragma mark - 
#pragma mark - 系统权限判断
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

/**
 *  获取当前显示视图的控制器
 */
+ (WYSuperViewController *)getCurrentVC
{
    WYSuperViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[WYNavigationController class]]) {
//        NSInteger index = ((UITabBarController *)nextResponder).selectedIndex;
//        WYNavigationController *nav = [(WYNavigationController *)nextResponder viewControllers][index];
        WYNavigationController *nav = (WYNavigationController *)nextResponder;
        nextResponder = [nav.viewControllers lastObject];
    }
    result = nextResponder;
    return result;
}

+ (void)playSystemSoundVibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (NSString *)acquireCurrentLocalizedText:(NSString *)text{
    NSString *localizedText = NSLocalizedString(text, nil);
    return localizedText;
}

+ (NSString *)showServerErrorLocalizedText{
    return [WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"];
}

+ (NSString *)getPreferredLanguage
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    return preferredLang;
    
}

@end
