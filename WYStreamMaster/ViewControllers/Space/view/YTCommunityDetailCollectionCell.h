//
//  YTCommunityCollectionCell.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/12.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTClassifyBBSDetailModel;
@class WYSpaceDetailModel;
typedef void(^YTAvatarImageViewViewActionBlock)(UIImageView *avatarImageView);

typedef NS_ENUM(NSUInteger, CommunityCellType) {
    CommunityCellTypeText = 1,
    CommunityCellTypeGraphic,
    CommunityCellTypeVideo,
};

@interface YTCommunityDetailCollectionCell : UICollectionViewCell

@property (assign, nonatomic) CommunityCellType communityCellType;
// 删除按钮
@property (strong, nonatomic) UIButton *deleteButton;

- (void)updateCommunifyCellWithData:(YTClassifyBBSDetailModel *)model;

+ (CGFloat)heightWithEntity:(YTClassifyBBSDetailModel *)model;

@property (copy, nonatomic) YTAvatarImageViewViewActionBlock clickAvatarImageViewBlock;

@end
