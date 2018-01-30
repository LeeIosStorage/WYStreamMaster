//
//  NSString+YTChatRoom.m
//  WYTelevision
//
//  Created by zurich on 2016/9/27.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "NSString+YTChatRoom.h"
#import "WYLoginUserManager.h"
@implementation NSString (YTChatRoom)

- (BOOL)isSelf
{
    return [self isEqualToString:[WYLoginUserManager nimAccountID]];
}

- (NSString *)realUserId
{
//    if ([self hasPrefix:@"dev"]) {
//        return [self stringByReplacingOccurrencesOfString:@"dev_" withString:@""];
//    }
//    
//    if ([self hasPrefix:@"test"]) {
//        return [self stringByReplacingOccurrencesOfString:@"test_" withString:@""];
//    }
    return self;
}

@end
