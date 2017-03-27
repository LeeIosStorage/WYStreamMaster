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
@property (strong, nonatomic) NSString *anchorDescription;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *chatRoomId;//聊天室ID
@property (strong, nonatomic) NSString *roomNumber;
@property (strong, nonatomic) NSString *anchorPushUrl;

// 手机号
@property (strong, nonatomic) NSString *mobile;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *iconMedia;
@property (strong, nonatomic) NSString *iconThumb;
@property (strong, nonatomic) NSString *fans;
// 主播房间号
@property (strong, nonatomic) NSString *sex;

@property (copy, nonatomic) NSString *shouboAccid;

//@property (strong, nonatomic) NSNumber *cityCode;
// 分享地址
@property (copy, nonatomic) NSString *shareUrl;

@property (strong, nonatomic) NSString  *yuerCoin; //娱币
@property (copy, nonatomic) NSString    *bait;//鱼饵

// 直播时长
@property (copy, nonatomic) NSString    *duration;
@end
