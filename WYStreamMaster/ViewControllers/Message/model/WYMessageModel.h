//
//  WYMessageModel.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/6.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYMessageModel : WYBaseModel
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *create_date;

@end
