//
//  YTGiftAttachment.h
//  WYTelevision
//
//  Created by zurich on 2016/9/23.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTCustomMessageDefines.h"

@interface YTGiftAttachment : NSObject <NIMCustomAttachment>

@property (copy, nonatomic) NSString *giftID;
@property (copy, nonatomic) NSString *giftName;
@property (copy, nonatomic) NSString *giftNum;
@property (copy, nonatomic) NSString *senderName;
@property (copy, nonatomic) NSString *senderID;
@property (copy, nonatomic) NSString *giftShowImage;
@property (assign, nonatomic) int isNeedNoticeAnchor;//加震动

@end
