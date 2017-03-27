//
//  WYStreamingConfig.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/16.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYStreamingConfig : NSObject

@property (assign, nonatomic) VideoQuality      videoQuality;

+ (instancetype)sharedConfig;
- (CGSize )getResolutionWithQuality;

@end
