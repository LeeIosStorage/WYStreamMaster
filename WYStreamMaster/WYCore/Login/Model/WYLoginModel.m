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
    return @{@"userID":@"user_code",
             @"anchorDescription":@"anchor.anchor_description",
             @"anchorTitle":@"anchor.anchor_title",
             @"nickname":@"ext_info.nickname",
             @"roomNumber":@"anchor.room_id_pk",
             @"anchorPushUrl":@"anchor.anchor_push_ur",
             @"icon":@"ext_info.head_icon",
             @"chatRoomId":@"anchor.neteaseChatRoomId",
             @"audit_statu":@"anchor.audit_statu",
             @"zone_img":@"anchor.zone_img"
             };
}

//- (void)setIcon:(NSString *)icon
//{
//    if (![icon hasPrefix:@"http"]) {
//        icon = [NSString stringWithFormat:@"%@%@",[WYAPIGenerate sharedInstance].baseURL,icon];
//    }
//    _icon = icon;
//}

@end
