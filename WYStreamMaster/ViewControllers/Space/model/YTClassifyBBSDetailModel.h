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

@property (copy, nonatomic) NSString *commentNumber;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *createDate;
@property (copy, nonatomic) NSString *gameName;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *postsID;
@property (copy, nonatomic) NSString *imgs;
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *praiseNumber;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *videoImage;
@property (copy, nonatomic) NSString *videoID;
@property (copy, nonatomic) NSString *share_url;

@property (assign, nonatomic) BOOL isCertificate;
@property (assign, nonatomic) BOOL isAttention;
@property (assign, nonatomic) BOOL isPraise;
@property (assign, nonatomic) BOOL isFemale;

@property (assign, nonatomic) YTBBSType bbsType;

@property (strong, nonatomic) NSURL *avatarImageURL;
@property (strong, nonatomic) NSURL *coverImageURL;

@property (strong, nonatomic) NSMutableArray *imagesArray;

@end
