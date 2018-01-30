//
//  YTClassifyBottomView.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol YTBetRankingViewDelegate <NSObject>
@optional
- (void)clickQuestionMarkButton;
@end
typedef enum : NSUInteger {
    BetRankingPrimaryType,            // 赌神榜
    BetRankingSeniorType,             // 土豪榜
} BetRankingType;
@class YTClassifyBBSDetailModel;

@interface YTBetRankingView : UIView

@property (strong, nonatomic) IBOutlet UILabel *betMostLabel;
@property (nonatomic, assign) BetRankingType betRankingType;
@property (nonatomic, weak) id <YTBetRankingViewDelegate> delegate;

- (void)updateBottomViewWithInfo:(NSMutableArray *)infoArray;
@end

