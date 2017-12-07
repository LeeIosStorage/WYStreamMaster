//
//  WYContributionInformationModel.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/8.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYContributionInformationModel : WYBaseModel
@property (strong, nonatomic) NSString *head_icon;
@property (strong, nonatomic) NSString *send_user_code;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *gift_value;
@end
