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
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *create_date;
@property (nonatomic, assign) BOOL is_read;

@property (copy, nonatomic) NSString *obj_id;
@property (assign, nonatomic) SystemMessageType target_type;
@property (copy, nonatomic) NSString *url;

// 参数 type=2 时返回
@property (copy, nonatomic) NSString *bbstitle;
// 5他人对我发布的帖子的评论 6他人对我发布的评论的回复 7他人对我发布的帖子的点赞
@property (nonatomic, strong) NSString *interactType;
// 发布者头像，互动和关注返回
@property (nonatomic, strong) NSString *coverImage;
// 当atype=7时为帖子标题，其余为评论内容
@property (nonatomic, strong) NSString *mcontent;
// 发布者内容,关注消息返回
@property (nonatomic, strong) NSString *ocontent;
// 发布者昵称,互动和关注消息返回
@property (nonatomic, copy) NSString *onickname;
// 发布者性别
@property (copy, nonatomic) NSString *sex;
// 参数type=2时返回 帖子ID 提供跳转到对应帖子的依据
@property (copy, nonatomic) NSString *mSourceId;
// 回复昵称
@property (copy, nonatomic) NSString *replynickname;
// 是否是主播
@property (assign, nonatomic) BOOL isup;
// 回复id
@property (copy, nonatomic) NSString *usrId;
// 被评论ID
@property (copy, nonatomic) NSString *replyId;
// 计算cell的高度
- (CGFloat)getCellHeigt;
@end
