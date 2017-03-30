//
//  WYGameModel.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYGameModel.h"

@implementation WYGameModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"gameName":@"game_name",
             @"gameId":@"id_pk"
             };
}

@end
