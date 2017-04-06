//
//  WYGiftHistoryModel.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/29.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYGiftHistoryModel.h"

@implementation WYGiftHistoryModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"recordId":@"id_pk",
             @"giftId":@"gift_type_id_fk",
             @"giftNumber":@"gift_number",
             @"giftTime":@"gift_time",
             @"sendNickName":@"nickname",
             @"giftLogo":@"gift_logo"
             };
}

@end
