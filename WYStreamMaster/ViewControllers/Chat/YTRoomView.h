//
//  YTRoomView.h
//  WYRecordMaster
//
//  Created by zurich on 2016/11/21.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTChatRoomControl.h"

@interface YTRoomView : UIView

@property (strong, nonatomic) NIMChatroomMember *itSelf;

@property (strong, nonatomic) YTChatRoomControl *chatroomControl;

- (void)roomViewPrepare;

- (void)sendMessageWithText:(NSString *)text;

@end
