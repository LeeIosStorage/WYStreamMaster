//
//  YTCustomAttachmentDecoder.m
//  WYTelevision
//
//  Created by zurich on 2016/9/23.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTCustomAttachmentDecoder.h"
#import "YTCustomMessageDefines.h"
#import "YTGiftAttachment.h"

@implementation YTCustomAttachmentDecoder

- (nullable id<NIMCustomAttachment>)decodeAttachment:(nullable NSString *)content
{
    id <NIMCustomAttachment> attachment = nil;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            NSInteger type = [[dict objectForKey:CMType] integerValue];
            NSDictionary *data = [dict objectForKey:CMData];
            switch (type) {
                case CustomMessageTypeGift:
                    attachment = [[YTGiftAttachment alloc] init];
                    ((YTGiftAttachment *)attachment).giftNum = data[@"giftNum"];
                    ((YTGiftAttachment *)attachment).giftID = data[@"giftID"];
                    ((YTGiftAttachment *)attachment).giftName = data[@"giftName"];
                    ((YTGiftAttachment *)attachment).senderID = data[@"senderID"];
                    ((YTGiftAttachment *)attachment).senderName = data[@"senderName"];
                    ((YTGiftAttachment *)attachment).giftShowImage = data[@"giftShowImage"];
                    
                    break;
                case CustomMessageTypeLocalNotification :
                    //不向外发送，所以不处理
                    break;
                default:
                    break;
            }
        }
    }
    return attachment;
}


@end
