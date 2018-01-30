//
//  WYGiftRecordModel.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/29.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYGiftRecordModel.h"

@implementation WYGiftRecordModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"giftId":@"giftId",
             @"giftName":@"gift_name",
             @"giftNumber":@"gift_number",
             @"giftPrice":@"gift_value",
             };
}

@end
