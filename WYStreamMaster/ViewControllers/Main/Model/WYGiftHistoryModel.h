//
//  WYGiftHistoryModel.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/29.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYGiftHistoryModel : WYBaseModel

@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, strong) NSString *giftId;
@property (nonatomic, strong) NSString *giftNumber;
@property (nonatomic, strong) NSString *giftTime;
@property (nonatomic, strong) NSString *sendNickName;
@property (nonatomic, strong) NSString *giftLogo;

@end
