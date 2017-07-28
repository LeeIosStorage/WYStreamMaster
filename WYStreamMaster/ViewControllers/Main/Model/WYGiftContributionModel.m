//
//  WYGiftContributionModel.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/29.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYGiftContributionModel.h"

@implementation WYGiftContributionModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"sendUserId":@"send_user_code",
             @"giftTotalValue":@"gift_value",
             @"nickName":@"nickname",
             @"headIcon":@"head_icon",
             };
}

@end
