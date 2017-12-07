//
//  WYRewardModel.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/9.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYRewardModel : WYBaseModel
@property (nonatomic, strong) NSDictionary *month;
@property (nonatomic, strong) NSArray *gift_number_value;

@end
