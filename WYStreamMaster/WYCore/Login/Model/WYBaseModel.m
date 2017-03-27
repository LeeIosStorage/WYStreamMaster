//
//  WYBaseModel.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/20.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"

@implementation WYBaseModel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self modelInitWithCoder:aDecoder];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    return [self modelEncodeWithCoder:aCoder];
}

@end
