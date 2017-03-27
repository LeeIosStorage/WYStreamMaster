//
//  YTGiftAttachment.m
//  WYTelevision
//
//  Created by zurich on 2016/9/23.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTGiftAttachment.h"


@interface YTGiftAttachment ()

@end

@implementation YTGiftAttachment

- (NSString *)encodeAttachment
{
    NSDictionary *dic = @{CMType : @(CustomMessageTypeGift),
                          CMData : @{@"giftID" : self.giftID,@"giftName" : self.giftName,@"giftNum":self.giftNum,@"senderName" : self.senderName,@"senderID":self.senderID,@"giftShowImage":self.giftShowImage},
                          };
    NSError *error = nil;
    NSString *content = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    if (data) {
        content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return content;
}

@end
