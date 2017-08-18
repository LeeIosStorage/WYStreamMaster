
//
//  WYGiftAnimationManager.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/5/9.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYGiftAnimationManager.h"
#import "ZegoAVManager.h"

@implementation WYGiftAnimationManager

- (void)startPlaySystemSoundWithVibrate:(YTGiftAttachment *)giftModel{
    
    if (giftModel.isNeedNoticeAnchor == 1) {
        [WYCommonUtils playSystemSoundVibrate];
    }
}

@end
