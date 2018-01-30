//
//  YTClassifyBottomView.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTClassifyBBSDetailModel;

@interface YTClassifyBottomView : UIView

@property (nonatomic, strong) IBOutlet UIButton *bottomCommentButton;
@property (nonatomic, strong) IBOutlet UIButton *bottomLikeButton;
@property (nonatomic, strong) IBOutlet UIButton *bottomShareButton;

@property (nonatomic, strong) YTClassifyBBSDetailModel *model;
- (void)updateBottomViewWithInfo:(YTClassifyBBSDetailModel *)data;
@end
