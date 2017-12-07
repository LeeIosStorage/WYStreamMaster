//
//  WYLoginModel.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/19.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYBaseModel.h"

@interface WYLoginModel : WYBaseModel

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *chatRoomId;//聊天室ID
@property (strong, nonatomic) NSString *roomNumber;
@property (strong, nonatomic) NSString *room_name;
@property (strong, nonatomic) NSString *anchorPushUrl;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *anchorTitle;
@property (strong, nonatomic) NSString *anchorDescription;
// 主播信息
@property (strong, nonatomic) NSDictionary *anchor;

// 是否审核通过 0为未审核，1为审核通过，2为审核不通过
@property (strong, nonatomic) NSString *audit_statu;
// 手机号
@property (strong, nonatomic) NSString *mobile;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *iconMedia;
@property (strong, nonatomic) NSString *iconThumb;
@property (strong, nonatomic) NSString *fans;

@property (strong, nonatomic) NSString *sex;

@property (copy, nonatomic) NSString *shouboAccid;

// 分享地址
@property (copy, nonatomic) NSString *shareUrl;

// 直播时长
@property (copy, nonatomic) NSString    *duration;
@end
