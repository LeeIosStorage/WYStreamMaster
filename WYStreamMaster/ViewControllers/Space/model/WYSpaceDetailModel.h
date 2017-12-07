//
//  WYSpaceDetailModel.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/24.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseModel.h"
typedef NS_ENUM(NSInteger, SystemMessageType) {
    SystemMessageTypeLive = 1,                         // no button type
    SystemMessageTypeVideo,
    SystemMessageTypeContent,
    SystemMessageTypeWeb
};

@interface WYSpaceDetailModel : WYBaseModel
@property (nonatomic, copy) NSString *commentId;
// 上级评论ID，为空说明为说说评论，否则为回复评论
@property (nonatomic, copy) NSString *parent_id;
// 评论用户CODE
@property (nonatomic, copy) NSString *user_code;
// 上级评论用户CODE，为空说明为说说评论，否则为回复评论
@property (nonatomic, copy) NSString *parent_user_code;
// 评论用户昵称
@property (copy, nonatomic) NSString *nickname;
@property (assign, nonatomic) SystemMessageType target_type;
// 上级评论昵称
@property (copy, nonatomic) NSString *parent_nickname;

// 评论内容
@property (copy, nonatomic) NSString *content;
// 创建时间
@property (nonatomic, strong) NSString *create_date;

// 计算cell的高度
- (CGFloat)getCellHeigt;
@end
