//
//  YTChatModel.h
//  WYTelevision
//
//  Created by zurich on 2016/9/22.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYBaseModel.h"

typedef NS_ENUM(NSInteger, ChatMessageType) {
    ChatMessageTypeNone,
    ChatMessageTypeGift,
    ChatMessageTypeNotification,
    ChatMessageTypeText,
};

@class NIMMessage;

@interface YTChatModel : WYBaseModel

@property (strong, nonatomic,readonly) NIMMessage *message;
@property (copy, nonatomic,readonly) YYTextLayout *chatTextLayout;
@property (copy, nonatomic) NSString *messageColor;
@property (assign, nonatomic) NSRange nameRange;
@property (assign, nonatomic) BOOL isAnchor;
@property (assign, nonatomic) ChatMessageType chatMessageType;
@property (strong, nonatomic) NSMutableAttributedString *barrageAttributed;
@property (copy, nonatomic) NSString *contentString;

//是否需要刷新自己的权限
@property (assign, nonatomic) BOOL needRefreshJurisdiction;

+ (YTChatModel *)createChatModelWithMessage:(NIMMessage *)message;

- (NSMutableAttributedString *)renderingWithGiftContent;

@end
