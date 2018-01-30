//
//  YTRoomView.h
//  WYRecordMaster
//
//  Created by zurich on 2016/11/21.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTChatRoomControl1.h"

@interface YTRoomView1 : UIView

@property (strong, nonatomic) NIMChatroomMember *itSelf;

@property (strong, nonatomic) YTChatRoomControl1 *chatroomControl;

- (void)roomViewPrepare;

- (void)sendMessageWithText:(NSString *)text;

@end
