//
//  WYLoginModel.m
//  WYRecordMaster
//
//  Created by zurich on 16/8/19.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYLoginModel.h"

@implementation WYLoginModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userID":@"anchor.id_pk",
             @"anchorDescription":@"anchor.anchor_description",
             @"nickname":@"ext_info.nickname",
             @"roomNumber":@"anchor.room_id_pk",
             @"anchorPushUrl":@"anchor.anchor_push_ur",
             @"icon":@"ext_info.head_icon",
             };
}

@end
