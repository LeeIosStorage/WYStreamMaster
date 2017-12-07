//
//  YTCommunityCollectionCell.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/12.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTClassifyBBSDetailModel;
typedef NS_ENUM(NSUInteger, CommunityCellType) {
    CommunityCellTypeText = 1,
    CommunityCellTypeGraphic,
    CommunityCellTypeVideo,
};

@interface YTCommunityCollectionCell : UICollectionViewCell

@property (assign, nonatomic) CommunityCellType communityCellType;

- (void)updateCommunifyCellWithData:(YTClassifyBBSDetailModel *)model;

+ (CGFloat)heightWithEntity:(YTClassifyBBSDetailModel *)model;

@end
