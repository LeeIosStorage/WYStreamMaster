//
//  WYContributionListModel.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/8.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYContributionListModel : WYBaseModel
@property (strong, nonatomic) NSArray *month;
@property (strong, nonatomic) NSArray *week;
@property (strong, nonatomic) NSArray *total;
@end
