//
//  YTChatRoomControl.m
//  WYTelevision
//
//  Created by zurich on 2016/10/24.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTChatRoomControl.h"
#import "WYLoginManager.h"
#import "YTEnterExtraModel.h"
#import "YTMessageNotificationAttachment.h"
#import "YTMessageConverter.h"
#import "YTGiftAttachment.h"
#import "YTChatModel.h"
#import "YTRoomView.h"
#import "WYGiftModel.h"
#import "WYServerNoticeAttachment.h"

@interface YTChatRoomControl ()<NIMChatroomManagerDelegate,NIMChatManagerDelegate>

@end

@implementation YTChatRoomControl

- (void)chatPrepare
{
    [self enterRoom];
    
    [[NIMSDK sharedSDK].chatroomManager addDelegate:self];
    //收发消息注册
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
}

- (void)exitRoom
{
    //移除所有的监听
    [[NIMSDK sharedSDK].chatroomManager removeDelegate:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [[NIMSDK sharedSDK].chatroomManager exitChatroom:[WYLoginUserManager chatRoomId] completion:^(NSError * _Nullable error) {
        WYLog(@"--用户离开聊天室--");
    }];
}

- (void)enterRoom
{
    WEAKSELF
    //正在进入
    if (![[NIMSDK sharedSDK].loginManager isLogined]) {
        //如果没有登录云信
        [self toLoginNIMService];
    } else {
        //附加信息
        YTEnterExtraModel *enterExtraModel = [[YTEnterExtraModel alloc] init];
        enterExtraModel.sex = [WYLoginUserManager sex];
        enterExtraModel.isAnchor = @"0";
        NSString *enterExtraString = [enterExtraModel modelToJSONString];
        
        NIMChatroomEnterRequest *enterRequest = [[NIMChatroomEnterRequest alloc] init];
        enterRequest.roomNickname = [WYLoginUserManager nickname];
        enterRequest.roomId = [WYLoginUserManager chatRoomId];
        enterRequest.roomAvatar = [WYLoginUserManager avatar];
        enterRequest.roomExt = enterExtraString;
        
        [[NIMSDK sharedSDK].chatroomManager enterChatroom:enterRequest completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
            if (!error) {
                [weakSelf enterRoomSuccess];
                //获取自己的权限
                [weakSelf getJurisdiction];
                
            } else {
                //此处应做兼容，没有登录上云信，就去等待，登录成功之后，看用户是否还在直播间内，再去重新进入聊天室
                NSLog(@"进入聊天室失败error = %@ 检查是否登录上云信服务器,%d",error,[[NIMSDK sharedSDK].loginManager isLogined]);
                [weakSelf sendMessageWithNotificationText:@"进入聊天服务器失败,请等待重连!"];
                [weakSelf toLoginNIMService];
            }
        }];
    }

}

- (void)toLoginNIMService
{
    //如果断开了连接，会重复进入此处，不断重连，如果在登录的时候就没有连接上云信，也要处理
    //没有登录上云信服务器，尝试主动登录云信服务器,并重新登录聊天室,其中有可能登录token失效
    [[WYLoginManager sharedManager] loginNIMService];
    
}

- (void)reEnterRoom{
    
    [self sendMessageWithNotificationText:@"连接中断，正在重新连接"];
    WEAKSELF
    //正在进入
    if (![[NIMSDK sharedSDK].loginManager isLogined]) {
        //如果没有登录云信
        [self toLoginNIMService];
    } else {
        //附加信息
        YTEnterExtraModel *enterExtraModel = [[YTEnterExtraModel alloc] init];
        enterExtraModel.sex = [WYLoginUserManager sex];
        enterExtraModel.isAnchor = @"0";
        NSString *enterExtraString = [enterExtraModel modelToJSONString];
        
        NIMChatroomEnterRequest *enterRequest = [[NIMChatroomEnterRequest alloc] init];
        enterRequest.roomNickname = [WYLoginUserManager nickname];
        enterRequest.roomId = [WYLoginUserManager chatRoomId];
        enterRequest.roomAvatar = [WYLoginUserManager avatar];
        enterRequest.roomExt = enterExtraString;
        
        [[NIMSDK sharedSDK].chatroomManager enterChatroom:enterRequest completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
            if (!error) {
                [weakSelf sendMessageWithNotificationText:@"重新连接成功"];
                //获取自己的权限
                [weakSelf getJurisdiction];
                
            } else {
                //此处应做兼容，没有登录上云信，就去等待，登录成功之后，看用户是否还在直播间内，再去重新进入聊天室
                NSLog(@"进入聊天室失败error = %@ 检查是否登录上云信服务器,%d",error,[[NIMSDK sharedSDK].loginManager isLogined]);
                [weakSelf sendMessageWithNotificationText:@"进入聊天服务器失败,请等待重连!"];
            }
        }];
    }
    
}

- (void)enterRoomSuccess
{
    [self sendMessageWithNotificationText:@"我们提倡绿色直播，封面和直播内容含吸烟、低俗、引诱、暴露等都将被屏蔽或冻结账号，网警24小时在线巡查！"];
    //[self sendLocalMessageWithExtraString:[WYLoginUserManager nickname] content:[NSString stringWithFormat:@"欢迎来到 %@ 的直播间,喜欢就点击主播信息关注吧!",[WYLoginUserManager nickname]] extraColor:nil];
}


- (void )getJurisdiction
{
    WEAKSELF
    NIMChatroomMembersByIdsRequest *request = [[NIMChatroomMembersByIdsRequest alloc] init];
    request.roomId = [WYLoginUserManager chatRoomId];
    request.userIds = @[[WYLoginUserManager nimAccountID]];
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:request completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        if (!error && members.count > 0) {
            weakSelf.chatRoomView.itSelf = members[0];
            if ([[WYLoginUserManager nimAccountID] isEqualToString:[WYLoginUserManager userID]]) {
                weakSelf.chatRoomView.itSelf.type = NIMChatroomMemberTypeCreator;
            }
        }
    }];
}

#pragma mark
#pragma mark - Send Action

- (void)sendMessageWithNotificationText:(NSString  *)text
{
    YTMessageNotificationAttachment *localAttachment = [[YTMessageNotificationAttachment alloc] init];
    localAttachment.notificationMessage = text;
    NIMMessage *message = [YTMessageConverter messageWithNotificationText:localAttachment];
    //,只是本地的消息，并不发送
    if ([self.delegate respondsToSelector:@selector(addMessageInRowWithMesssage:)]) {
        [self.delegate addMessageInRowWithMesssage:message];
    }
}

- (void)sendLocalMessageWithExtraString:(NSString *)extra content:(NSString *)content extraColor:(UIColor *)color
{
    YTMessageNotificationAttachment *localAttachment = [[YTMessageNotificationAttachment alloc] init];
    localAttachment.notificationMessage = content;
    localAttachment.extraColor = color;
    localAttachment.localExtraString = extra;
    NIMMessage *message = [YTMessageConverter messageWithNotificationText:localAttachment];
    //,只是本地的消息，并不发送
    if ([self.delegate respondsToSelector:@selector(addMessageInRowWithMesssage:)]) {
        [self.delegate addMessageInRowWithMesssage:message];
    }
    //[self.chatRoomView addMessageInRowWithMesssage:message];
}


- (NSError *)sendWithMessage:(NIMMessage *)message
{
    NSError *error = nil;
    NIMSession *session = [NIMSession session:[WYLoginUserManager chatRoomId] type:NIMSessionTypeChatroom];
    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(addMessageInRowWithMesssage:)]) {
            [self.delegate addMessageInRowWithMesssage:message];
        }
        //[self.chatRoomView addMessageInRowWithMesssage:message];
    }
    return error;
}

- (void)sendMessageWithGift:(WYGiftModel *)model
{
    YTGiftAttachment *attachment = [[YTGiftAttachment alloc] init];
    attachment.giftName = model.name;
    attachment.giftID = model.giftId;
    attachment.giftNum = [NSString stringWithFormat:@"%ld",(long)model.clickNumber];
    attachment.senderName = [WYLoginUserManager nickname];
    attachment.senderID = [WYLoginUserManager nimAccountID];
    attachment.giftShowImage = model.noFrameIcon;
    model.sender = [WYLoginUserManager nickname];
    
    NIMMessage *message = [YTMessageConverter messageWithGiftAttachment:attachment];
    
    [self sendWithMessage:message extraModel:model];
}

- (nullable NSError *)sendWithMessage:(NIMMessage *)message extraModel:(WYGiftModel *)extraModel
{
    NSError *error = nil;
    NIMSession *session = [NIMSession session:[WYLoginUserManager chatRoomId] type:NIMSessionTypeChatroom];
    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(addMessageInRowWithMesssage:)]) {
            [self.delegate addMessageInRowWithMesssage:message];
        }
        //[self.chatRoomView addMessageInRowWithMesssage:message];
    }
    
    return error;
}



#pragma mark
#pragma mark Chat Delegate

/**
 *  收到消息回调
 *
 *  @param messages 消息列表,内部为NIMMessage
 */
- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages
{
    NSLog(@"message");
    for (NIMMessage *message in messages) {
        
        YTChatModel *chatModel = [YTChatModel createChatModelWithMessage:message];
        chatModel.isAnchor = YES;
        //对于机器人要获取remoteExt的nickname
        
        if (chatModel.needRefreshJurisdiction) {
            [self getJurisdiction];
            chatModel.needRefreshJurisdiction = NO;
        }
        
        if (chatModel.chatTextLayout) {
            if ([self.delegate respondsToSelector:@selector(receiveMessageWith:)]) {
                [self.delegate receiveMessageWith:chatModel];
            }
        }
        
        if (message.messageType == NIMMessageTypeCustom) {
            id attachment = ((NIMCustomObject *)message.messageObject).attachment;
            if ([attachment isKindOfClass:[WYServerNoticeAttachment class]]) {
                WYServerNoticeAttachment *serverNoticeAttachment = attachment;
                
                WYLog(@"==%@",serverNoticeAttachment.contentData);
                [[NSNotificationCenter defaultCenter] postNotificationName:WYServerNoticeAttachment_Notification object:serverNoticeAttachment userInfo:nil];
            }
        }
    }
}

/**
 *  收到消息回执
 *
 *  @param receipt 消息回执
 *  @discussion 当上层收到此消息时所有的存储和 model 层业务都已经更新，只需要更新 UI 即可。如果对端发送的已读回执时间戳比当前端存储的最后时间戳还小，这个已读回执将被忽略。
 */
- (void)onRecvMessageReceipt:(NIMMessageReceipt *)receipt
{
    
}






@end
