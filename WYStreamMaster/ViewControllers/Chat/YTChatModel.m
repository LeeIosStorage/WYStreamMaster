//
//  YTChatModel.m
//  WYTelevision
//
//  Created by zurich on 2016/9/22.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTChatModel.h"
#import "YTGiftAttachment.h"
#import "WYLoginUserManager.h"
#import "YTMessageNotificationAttachment.h"
#import "NSString+YTChatRoom.h"
#import "WYDataMemoryManager.h"

#define RobotSpeechIndentifier @"robot"
#define RobotSpeechNicknameKey @"nickname"

@interface YTChatModel ()
@property (strong, nonatomic) NIMMessage *message;
@property (copy, nonatomic) YYTextLayout *chatTextLayout;
@end

@implementation YTChatModel

+ (YTChatModel *)createChatModelWithMessage:(NIMMessage *)message
{
    YTChatModel *model = [[YTChatModel alloc] init];
    model.message = message;
    [model chatTextLayout];
    return model;
}

- (YYTextLayout *)chatTextLayout
{
    if (!_chatTextLayout) {
        NSMutableAttributedString *contentAttributedString = [self handleContent];
        
        //设置阴影
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = CGSizeMake(1, 1);
        shadow.shadowColor = [UIColor colorWithHex:0 withAlpha:0.4];
        [contentAttributedString setShadow:shadow range:contentAttributedString.rangeOfAll];
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.lineSpacing = 3;
        [contentAttributedString setParagraphStyle:style range:contentAttributedString.rangeOfAll];
        
        if (contentAttributedString) {
            _chatTextLayout = [self getTextLayotWithAttributedString:contentAttributedString];
        }
    }
    return _chatTextLayout;
}

- (nullable NSMutableAttributedString *)handleContent
{
    if (self.message.text.length <= 0) {
        self.message.text = @"";
    }

    //不同类型的消息，拼装文本不同
    switch (self.message.messageType) {
        case NIMMessageTypeText:
        {
            if (!self.message.senderName && ![self.message.from isSelf]) {
                //认为是机器人进入直播间或者发言
                if (self.message.remoteExt) {
                    //机器人发言
                    //NSString *robotName = [self.message.remoteExt objectForKey:RobotSpeechNicknameKey];
                    return nil;
                   //return  [self renderingContentWithRobotName:robotName];
                } else {
                    //机器人进入
                    return nil;
                   //return  [self renderingRobotEnterWithRobotText:[NSString stringWithFormat:@" %@",self.message.text]];
                }
            }
            return [self renderingWithNomalContent];
        }
            break;
        case NIMMessageTypeCustom:
        {
            id attachment = ((NIMCustomObject *)self.message.messageObject).attachment;
            if ([attachment isKindOfClass:[YTGiftAttachment class]]) {
                NSMutableAttributedString *giftAttributed = [self renderingWithGiftContent];
                return giftAttributed;
            } else if ([attachment isKindOfClass:[YTMessageNotificationAttachment class]]){
                return [self renderingWithLocalNotificationContent];
            }
        }
            break;
            
        case NIMMessageTypeNotification:
        {
            //通知类型
            NIMNotificationObject *notificationObject = (NIMNotificationObject *)self.message.messageObject;
            if (notificationObject.notificationType == NIMNotificationTypeChatroom) {
                NIMChatroomNotificationContent *notificationContent = (NIMChatroomNotificationContent *)notificationObject.content;
                NIMChatroomNotificationMember *member = notificationContent.targets[0];
                if (notificationContent.eventType == NIMChatroomEventTypeEnter) {
                    //进入房间类型,也有可能是游客进入，此时的userid并不能作为判断依据
                    
                    if (![member.userId isSelf]) {
                        if (member.nick.length > 0) {
                            return [self renderingWithRoomNotification:member withContentString:[NSString stringWithFormat:@" %@ %@ %@",[WYCommonUtils acquireCurrentLocalizedText:@"欢迎"],member.nick,[WYCommonUtils acquireCurrentLocalizedText:@"进入房间"]] eventType:notificationContent.eventType];
                        }
                    }
                    
                } else if (notificationContent.eventType == NIMChatroomEventTypeExit) {
                    //离开房间类型
                    
                } else if (notificationContent.eventType == NIMChatroomEventTypeAddMute){
                    //用户被禁言
                    NSLog(@"1231231");
                    
                } else if (notificationContent.eventType == NIMChatroomEventTypeRemoveMute) {
                    
                } else if (notificationContent.eventType == NIMChatroomEventTypeAddManager) {
                    //用户成为管理员
                    if ([member.userId isSelf]) {
                        self.needRefreshJurisdiction = YES;
                    }
                    return [self renderingWithRoomNotification:member withContentString:[NSString stringWithFormat:@" 恭喜 %@ 成为房管,大家热烈祝贺!",member.nick] eventType:notificationContent.eventType];
                } else if (notificationContent.eventType == NIMChatroomEventTypeRemoveManager) {
                    //用户被取消管理员
                    if ([member.userId isSelf]) {
                        self.needRefreshJurisdiction = YES;
                    }
                    return [self renderingWithRoomNotification:member withContentString:[NSString stringWithFormat:@" 真可惜, %@ 被主播撤销房管",member.nick] eventType:notificationContent.eventType];
                } else if (notificationContent.eventType == NIMChatroomEventTypeKicked) {
                    //用户被踢出直播间
//                    return [self renderingWithRoomNotification:member withContentString:[NSString stringWithFormat:@"%@ 被管理员踢出直播间",member.nick]];
                } else if (notificationContent.eventType ==     NIMChatroomEventTypeAddMuteTemporarily) {
                    //用户被解除临时禁言
                    if ([member.userId isSelf]) {
                        self.needRefreshJurisdiction = YES;
                    }
                    return [self renderingWithRoomNotification:member withContentString:[NSString stringWithFormat:@" %@ 被禁言24小时",member.nick] eventType:notificationContent.eventType];
                }
            }
        }
            break;
        case 10:
            NSLog(@"12313");
            
            break;
        default:
            break;
    }

    return nil;
}

/**
 *  普通聊天类型
 */
- (NSMutableAttributedString *)renderingWithNomalContent
{
//    NSInteger userType = 0;
    UIColor *textColor = [UIColor whiteColor];
    UIImage *tagImage = nil;
    if ([self.message.from isEqualToString:[[WYDataMemoryManager sharedInstance] getContributionFirstUserId]]) {
        textColor = [UIColor colorWithHexString:@"ffea00"];
        tagImage = [UIImage imageNamed:@"wy_crown_user_1"];
    }if ([self.message.from isEqualToString:[[WYDataMemoryManager sharedInstance] getContributionSecondUserId]]) {
        textColor = [UIColor colorWithHexString:@"ffea00"];
        tagImage = [UIImage imageNamed:@"wy_crown_user_2"];
    }if ([self.message.from isEqualToString:[[WYDataMemoryManager sharedInstance] getContributionThirdUserId]]) {
        textColor = [UIColor colorWithHexString:@"ffea00"];
        tagImage = [UIImage imageNamed:@"wy_crown_user_3"];
    }
    
    NSString *contentString = [NSString stringWithFormat:@"%@ : %@",[self getUserName] ,self.message.text];
    self.contentString = contentString;
    NSMutableAttributedString *nameAttribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ : ",[self getUserName]]];
    nameAttribute.color = textColor;

    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:self.message.text];
    [contentAttributedString setColor:textColor];
    [contentAttributedString insertAttributedString:nameAttribute atIndex:0];
    
    if (tagImage) {
//        NSAttributedString *tagAttributed = [NSAttributedString attachmentStringWithEmojiImage:tagImage fontSize:20.f];
        NSAttributedString *tagAttributed = [NSAttributedString attachmentStringWithContent:tagImage contentMode:UIViewContentModeLeft width:31 ascent:5 descent:0];
        [contentAttributedString insertAttributedString:tagAttributed atIndex:0];
        self.nameRange = NSMakeRange(1, [self getUserName].length + 2);
    } else {
        self.nameRange = NSMakeRange(0, [self getUserName].length + 2);
    }
    contentAttributedString.font = [UIFont systemFontOfSize:14.f];//boldSystemFontOfSize
    self.chatMessageType = ChatMessageTypeText;
    self.barrageAttributed = [[NSMutableAttributedString alloc] initWithString:self.message.text];
    return contentAttributedString;
}


/**
 *  礼物
 */
- (NSMutableAttributedString *)renderingWithGiftContent
{
    YTGiftAttachment *giftAttachment = ((NIMCustomObject *)self.message.messageObject).attachment;
    NSString *contentString = nil;
    if ([giftAttachment.giftNum integerValue] > 1) {
        contentString = [NSString stringWithFormat:@"%@ : 送给主播1个 %@  %@连击!",[self getUserName],giftAttachment.giftName,giftAttachment.giftNum];
    } else {
        contentString = [NSString stringWithFormat:@"%@ : 送给主播1个 %@  ",[self getUserName],giftAttachment.giftName];
    }
    self.contentString = contentString;

    NSRange nameRane = [contentString rangeOfString:[NSString stringWithFormat:@"%@ :",[self getUserName]]];
    self.nameRange = nameRane;
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
    
    NSRange showRane = [contentString rangeOfString:[NSString stringWithFormat:@"%@ : 送给主播1个 %@",[self getUserName],giftAttachment.giftName]];
    
    if ([giftAttachment.giftNum integerValue] > 0) {
        
    }
    [contentAttributedString setColor:[UIColor whiteColor] range:showRane];
    [contentAttributedString setFont:[UIFont systemFontOfSize:14.f] range:showRane];
    
    //用户名
    [contentAttributedString setColor:[UIColor colorWithHexString:@"ffdd00"] range:nameRane];
    [contentAttributedString setFont:[UIFont systemFontOfSize:14.f] range:nameRane];
    
    NSRange comboRange = [contentString rangeOfString:[NSString stringWithFormat:@"%@连击!",giftAttachment.giftNum]];
    [contentAttributedString setColor:[UIColor colorWithHexString:@"FF6600"] range:comboRange];
    [contentAttributedString setFont:[UIFont fontWithName:@"Georgia-BoldItalic" size:15.f] range:comboRange];//斜体加粗
    
    //插入礼物的图片
//    NSString *imageString = [NSString stringWithFormat:@"%@/%@",IMG_URL,giftAttachment.giftShowImage];
//    UIView *bgView = [UIView new];
//    bgView.backgroundColor = [UIColor clearColor];
//    bgView.frame = CGRectMake(0, 0, 20, 20);
//    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
//    imageView.size = CGSizeMake(20, 20);
//    imageView.center = bgView.center;
//    [bgView addSubview:imageView];
//    [imageView setImageURL:[NSURL URLWithString:imageString]];
//    
//    NSAttributedString *giftAttributed = [NSMutableAttributedString attachmentStringWithContent:bgView contentMode:UIViewContentModeCenter attachmentSize:bgView.frame.size alignToFont:[UIFont systemFontOfSize:20.f] alignment:YYTextVerticalAlignmentCenter];
    
    
    NSMutableAttributedString *barrageAttributed = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ 送给主播1个 %@",[self getUserName],giftAttachment.giftName]];
    
//    if (giftAttributed) {
//        [contentAttributedString insertAttributedString:giftAttributed atIndex:showRane.length];
//        [barrageAttributed insertAttributedString:giftAttributed atIndex:barrageAttributed.length];
//    }
    
    
    self.barrageAttributed = barrageAttributed;
    
    self.chatMessageType = ChatMessageTypeGift;
    
    return contentAttributedString;
}

/**
 *  本地通知消息
 */
- (NSMutableAttributedString *)renderingWithLocalNotificationContent
{
    YTMessageNotificationAttachment *notificationAttachment = ((NIMCustomObject *)self.message.messageObject).attachment;
    NSString *contentString = notificationAttachment.notificationMessage;
    
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
    [contentAttributedString setColor:[UIColor colorWithHexString:@"FF0000"] range:contentString.rangeOfAll];
    if (notificationAttachment.localExtraString) {
        NSRange extraRange = [contentString rangeOfString:notificationAttachment.localExtraString];
        if (!notificationAttachment.extraColor) {
            notificationAttachment.extraColor = [UIColor colorWithHexString:@"33FFFF"];
        }
        [contentAttributedString setColor:notificationAttachment.extraColor range:extraRange];
    }
    
    [contentAttributedString setFont:[UIFont systemFontOfSize:14.f] range:contentString.rangeOfAll];
    return contentAttributedString;
}

/**
 *  成员信息消息
 */
- (NSMutableAttributedString *)renderingWithRoomNotification:(NIMChatroomNotificationMember *)member withContentString:(NSString *)contentString eventType:(NIMChatroomEventType)eventType
{
    
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
    [contentAttributedString setFont:[UIFont systemFontOfSize:14.f] range:contentString.rangeOfAll];//boldSystemFontOfSize
    
    
    NSRange nRange = [contentString rangeOfString:member.nick];
    if (nRange.length > 0) {
//        [contentAttributedString setColor:[UIColor colorWithHexString:@"fc1157"] range:nRange];
//        self.nameRange = nRange;
    }
    
    UIImage *noticeImage = nil;
    UIColor *textColor = [UIColor colorWithHexString:@"fc1157"];
    if (eventType == NIMChatroomEventTypeEnter) {
        noticeImage = [UIImage imageNamed:@"wy_expression_welcome"];
        textColor = [UIColor colorWithHexString:@"78ff00"];
    }else if (eventType == NIMChatroomEventTypeAddManager){
        noticeImage = [UIImage imageNamed:@"wy_expression_congratul"];
        textColor = [UIColor colorWithHexString:@"ff41ba"];
    }else if (eventType == NIMChatroomEventTypeRemoveManager){
        noticeImage = [UIImage imageNamed:@"wy_expression_sad"];
        textColor = [UIColor colorWithHexString:@"9cd4ff"];
    }else if (eventType == NIMChatroomEventTypeAddMuteTemporarily){
        noticeImage = [UIImage imageNamed:@"wy_expression_mute"];
        textColor = [UIColor colorWithHexString:@"ff2121"];
    }
    [contentAttributedString setColor:textColor range:contentString.rangeOfAll];
    
    if (noticeImage) {
        NSAttributedString *noticeAttributed = [NSAttributedString attachmentStringWithEmojiImage:noticeImage fontSize:14.f];
        [contentAttributedString insertAttributedString:noticeAttributed atIndex:0];
        if (eventType == NIMChatroomEventTypeEnter) {
            NSAttributedString *noticeAttributed2 = [NSAttributedString attachmentStringWithEmojiImage:noticeImage fontSize:14.f];
            [contentAttributedString insertAttributedString:noticeAttributed2 atIndex:1];
        }
    }
    
    
    self.contentString = contentString;
    return contentAttributedString;
}

#pragma mark 
#pragma mark - Robot Message

/**
 *  机器人发言
 */
- (NSMutableAttributedString *)renderingContentWithRobotName:(NSString *)robotName
{
    NSString *contentString = [NSString stringWithFormat:@"%@:  %@",robotName ,self.message.text];
    //self.contentString = contentString;
    NSMutableAttributedString *nameAttribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ :  ",robotName]];
    nameAttribute.color = [UIColor colorWithHexString:@"33FFFF"];
    
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:self.message.text];
    [contentAttributedString setColor:[UIColor colorWithHexString:@"9da4ad"]];
    [contentAttributedString insertAttributedString:nameAttribute atIndex:0];
    
    if (self.isAnchor) {
        NSAttributedString *tagAttributed = [NSAttributedString attachmentStringWithEmojiImage:[UIImage imageNamed:@"chat_icon_anchor"] fontSize:13.f];
        [contentAttributedString insertAttributedString:tagAttributed atIndex:0];
        self.nameRange = NSMakeRange(1, robotName.length + 2);
    } else {
        self.nameRange = NSMakeRange(0, robotName.length + 2);
    }
    contentAttributedString.font = [UIFont systemFontOfSize:14.f];
    self.chatMessageType = ChatMessageTypeText;
    self.barrageAttributed = [[NSMutableAttributedString alloc] initWithString:self.message.text];
    return contentAttributedString;
}


/**
 *  机器人系统消息
 */
- (NSMutableAttributedString *)renderingRobotEnterWithRobotText:(NSString *)robotText
{
    //欢迎——————进入直播间
    //未加入通知图片之前的range
    NSRange robotNickRange = NSMakeRange(3, robotText.length - 8);
    
    NSAttributedString *noticeAttributed = [NSAttributedString attachmentStringWithEmojiImage:[UIImage imageNamed:@"chat_notice"] fontSize:13.f];
    
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:robotText];
    [contentAttributedString setFont:[UIFont systemFontOfSize:14.f] range:robotText.rangeOfAll];
    [contentAttributedString setColor:[UIColor colorWithHexString:@"9da4ad"] range:robotText.rangeOfAll];
//    if (robotNickRange.length <= robotText.length) {
//        [contentAttributedString setColor:[UIColor colorWithHexString:@"33FFFF"] range:robotNickRange];
//    }

    [contentAttributedString insertAttributedString:noticeAttributed atIndex:0];
    //self.contentString = robotText;
    return contentAttributedString;
}

#pragma mark 
#pragma mark - Utils

- (NSString *)getUserName
{
    if ([self.message.from isSelf]) {
        return [WYLoginUserManager nickname];
    }
    return self.message.senderName.length ? self.message.senderName : self.message.from;
}

- (YYTextLayout *)getTextLayotWithAttributedString:(NSMutableAttributedString *)attributedString
{
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(SCREEN_WIDTH-kRoomChatViewCustomWidth, HUGE)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:attributedString];    
    return textLayout;
}

@end
