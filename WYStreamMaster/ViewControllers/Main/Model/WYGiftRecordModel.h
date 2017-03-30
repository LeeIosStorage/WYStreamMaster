//
//  WYGiftRecordModel.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/29.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYGiftRecordModel : WYBaseModel

@property (nonatomic, strong) NSString *giftId;
@property (nonatomic, strong) NSString *giftName;
@property (nonatomic, strong) NSString *giftNumber;
@property (nonatomic, strong) NSString *giftPrice;

@end
