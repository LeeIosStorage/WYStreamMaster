//
//  WYGiftContributionModel.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/29.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYGiftContributionModel : WYBaseModel

@property (nonatomic, strong) NSString *sendUserId;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *giftTotalValue;

@end
