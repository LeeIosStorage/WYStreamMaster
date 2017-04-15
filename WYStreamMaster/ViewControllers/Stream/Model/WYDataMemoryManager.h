//
//  WYDataMemoryManager.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/4/12.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYDataMemoryManager : NSObject

+ (WYDataMemoryManager *)sharedInstance;

- (void)login;

- (NSString *)getContributionFirstUserId;
- (NSString *)getContributionSecondUserId;
- (NSString *)getContributionThirdUserId;

@end
