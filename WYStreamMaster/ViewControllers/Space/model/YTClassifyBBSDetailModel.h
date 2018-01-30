//
//  YTClassifyBBSDetailModel.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/11.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYBaseModel.h"

typedef NS_ENUM(NSUInteger, YTBBSType) {
    YTBBSTypeText = 1,  // 文字
    YTBBSTypeGraphic,   // 图文
    YTBBSTypeVideo,     // 视频
};

@interface YTClassifyBBSDetailModel : WYBaseModel

@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSMutableArray *images;
@property (copy, nonatomic) NSArray *videos;
@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) NSString *create_date;
@property (copy, nonatomic) NSString *upvote_id;
@property (copy, nonatomic) NSString *identity;

@property (copy, nonatomic) NSString *praiseNumber;
@property (assign, nonatomic) NSArray *comment_list;


@property (assign, nonatomic) BOOL isSpaceDetail;
@property (assign, nonatomic) BOOL isAttention;
@property (assign, nonatomic) BOOL isPraise;
@property (assign, nonatomic) BOOL isFemale;

@property (assign, nonatomic) YTBBSType bbsType;

@end
