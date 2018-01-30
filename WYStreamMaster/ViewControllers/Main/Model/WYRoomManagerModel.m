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
    return @{@"managerUserName":@"nickname",
             @"managerUserId":@"user_code_fk",
             @"managerAvatar":@"head_icon"
             };
}

@end
