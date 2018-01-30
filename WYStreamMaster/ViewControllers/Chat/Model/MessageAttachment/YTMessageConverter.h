//
//  YTMessageConverter.h
//  WYTelevision
//
//  Created by zurich on 2016/9/23.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YTGiftAttachment;
@class YTMessageNotificationAttachment;

@interface YTMessageConverter : NSObject

+ (NIMMessage *)messageWithText:(NSString *)text;

+ (NIMMessage *)messageWithGiftAttachment:(YTGiftAttachment *)attachment;

+ (NIMMessage *)messageWithNotificationText:(YTMessageNotificationAttachment *)attachment;

@end
