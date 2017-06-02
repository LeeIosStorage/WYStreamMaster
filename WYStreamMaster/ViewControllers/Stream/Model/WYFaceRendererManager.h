//
//  WYFaceRendererManager.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/5/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTGiftAttachment.h"

@interface WYFaceRendererManager : NSObject

+ (instancetype)sharedInstance;

- (CVPixelBufferRef)detectorFace:(CVPixelBufferRef)pixelBuffer;

- (void)loadItem;//加载贴图

- (void)stopTimer;
- (void)startTimer;
- (void)addGiftModel:(YTGiftAttachment *)giftModel;

@end
