//
//  YTMessageNotificationAttachment.h
//  WYTelevision
//
//  Created by zurich on 2016/9/24.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTCustomMessageDefines.h"

@interface YTMessageNotificationAttachment : NSObject <NIMCustomAttachment>

@property (copy, nonatomic) NSString    *notificationMessage;
@property (copy, nonatomic) NSString    *localExtraString;
@property (strong, nonatomic) UIColor   *extraColor;

@end
