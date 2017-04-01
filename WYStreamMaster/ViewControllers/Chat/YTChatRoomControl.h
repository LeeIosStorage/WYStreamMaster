//
//  YTChatRoomControl.h
//  WYTelevision
//
//  Created by zurich on 2016/10/24.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YTLiveroomInfo;
@class YTRoomView;
@class WYGiftModel;
@class YTChatModel;

@protocol YTChatControlDelegate <NSObject>

@optional
- (void)addMessageInRowWithMesssage:(NIMMessage *)message;

- (void)receiveMessageWith:(YTChatModel *)chatModel;

@end

@interface YTChatRoomControl : NSObject

@property (nonatomic, strong) YTLiveroomInfo *roomInfo;
@property (nonatomic, strong) YTRoomView *chatRoomView;

@property (weak, nonatomic) id <YTChatControlDelegate> delegate;

- (void)chatPrepare;

- (void)enterRoom;

- (void)exitRoom;

- (void)reEnterRoom;

- (NSError *)sendWithMessage:(NIMMessage *)message extraModel:(WYGiftModel *)extraModel;
- (NSError *)sendWithMessage:(NIMMessage *)message;

- (void)sendMessageWithGift:(WYGiftModel *)model;

- (void)sendLocalMessageWithExtraString:(NSString *)extra content:(NSString *)content extraColor:(UIColor *)color;

- (void)sendMessageWithNotificationText:(NSString  *)text;

- (void )getJurisdiction;

@end
