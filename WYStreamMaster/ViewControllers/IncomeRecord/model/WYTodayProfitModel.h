//
//  WYTodayProfitModel.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/7.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYTodayProfitModel : WYBaseModel
@property (strong, nonatomic) NSDictionary *anchor;
@property (strong, nonatomic) NSDictionary *gift_number_value;
@property (strong, nonatomic) NSDictionary *total;
@end
