//
//  WYMessageModel.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/6.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYMessageModel.h"

@implementation WYMessageModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"identity":@"id",
             @"chatRoomId":@"anchor.neteaseChatRoomId"
             };
}
@end
