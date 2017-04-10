//
//  WYServerNoticeAttachment.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/4/8.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYServerNoticeAttachment.h"

@implementation WYServerNoticeAttachment

- (NSString *)encodeAttachment
{
    NSDictionary *dic = @{CMType : @(self.customMessageType),
                          CMData : self.contentData,
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
