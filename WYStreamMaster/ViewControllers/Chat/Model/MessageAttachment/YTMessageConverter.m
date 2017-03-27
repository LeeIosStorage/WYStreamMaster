//
//  YTMessageConverter.m
//  WYTelevision
//
//  Created by zurich on 2016/9/23.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTMessageConverter.h"
#import "YTGiftAttachment.h"
#import "WYLoginUserManager.h"
#import "YTMessageNotificationAttachment.h"


@implementation YTMessageConverter

+ (NIMMessage *)messageWithText:(NSString *)text
{
    NIMMessage *textMessage = [[NIMMessage alloc] init];
    textMessage.text = text;
    return textMessage;
}

+ (NIMMessage *)messageWithGiftAttachment:(YTGiftAttachment *)attachment
{
    NIMMessage *message = [[NIMMessage alloc] init];
    NIMCustomObject *customObject = [[NIMCustomObject alloc] init];
    customObject.attachment = attachment;
    message.messageObject = customObject;
    return message;
}

+ (NIMMessage *)messageWithNotificationText:(YTMessageNotificationAttachment *)attachment
{
    NIMMessage *message = [[NIMMessage alloc] init];
    NIMCustomObject *customObject = [[NIMCustomObject alloc] init];
    customObject.attachment = attachment;
    message.messageObject = customObject;
    return message;
}


@end
