//
//  WYRoomManagerModel.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/28.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYRoomManagerModel.h"

@implementation WYRoomManagerModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"managerUserName":@"room_manager_name",
             @"managerUserId":@"room_manager_user_code"
             };
}

@end
