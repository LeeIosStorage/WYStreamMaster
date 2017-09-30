//
//  YTItemView.h
//  WYTelevision
//
//  Created by zurich on 2016/10/1.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YTItemViewType) {
    YTItemViewTypeNormal,
    YTItemViewTypeBorder,
};

@interface YTItemView : UIView

@property (strong, nonatomic) NSArray *items;

@property (copy, nonatomic) void (^itemSeletedBlock)(NSInteger index);

@property (assign, nonatomic) NSInteger seletedIndex;

- (instancetype)initWithFrame:(CGRect)frame Items:(NSArray *)items;

- (void)initWithItems:(NSArray *)items itemType:(YTItemViewType )itemType;

- (void)toSelectedItemWithIndex:(NSInteger )itemIndex;

@end
