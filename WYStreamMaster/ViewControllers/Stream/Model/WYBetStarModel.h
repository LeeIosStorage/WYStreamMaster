//
//  WYBetStarModel.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2018/1/23.
//  Copyright © 2018年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYBetStarModel : WYBaseModel
@property (copy, nonatomic) NSString *anchorNickName;
@property (copy, nonatomic) NSString *currency;
@property (copy, nonatomic) NSString *profit;
@property (copy, nonatomic) NSString *roomName;
@property (copy, nonatomic) NSString *userNickName;
@end
