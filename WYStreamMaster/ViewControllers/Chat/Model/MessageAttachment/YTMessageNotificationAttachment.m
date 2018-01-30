//
//  YTMessageNotificationAttachment.m
//  WYTelevision
//
//  Created by zurich on 2016/9/24.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTMessageNotificationAttachment.h"


@implementation YTMessageNotificationAttachment

- (NSString *)encodeAttachment
{
    NSDictionary *dic = @{CMType : @(CustomMessageTypeLocalNotification),
                          CMData : @{@"text" : self.notificationMessage,@"extra" : self.localExtraString},
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
