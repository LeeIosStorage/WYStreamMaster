//
//  YTClassifyBottomView.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    BetRankingPrimaryType,            //德州扑克
    BetRankingSeniorType,                 //老虎机
} BetRankingType;
@class YTClassifyBBSDetailModel;

@interface YTBetRankingView : UIView

@property (strong, nonatomic) IBOutlet UILabel *betMostLabel;
@property (nonatomic, assign) BetRankingType betRankingType;
- (void)updateBottomViewWithInfo:(YTClassifyBBSDetailModel *)data;
@end
