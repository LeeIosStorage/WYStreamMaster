//
//  WYGiftModel.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/23.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYBaseModel.h"

@interface WYGiftModel : WYBaseModel

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *giftId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, assign) NSInteger clickNumber;
@property (nonatomic, strong) NSString *num;
@property (nonatomic, strong) NSString *isPresentOrYuer; //1 礼物  2 鱼饵
@property (nonatomic, strong) NSString *noFrameIcon;
//optional
@property (strong, nonatomic) NSString *sender;

@end
