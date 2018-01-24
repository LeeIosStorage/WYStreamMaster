//
//  YTClassifyBottomView.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol YTPrimaryBetRankingViewDelegate <NSObject>
@optional
- (void)clickQuestionMarkButton;
@end
@class YTClassifyBBSDetailModel;

@interface YTPrimaryBetRankingView : UIView

@property (strong, nonatomic) IBOutlet UILabel *betMostLabel;
@property (nonatomic, weak) id <YTPrimaryBetRankingViewDelegate> delegate;

- (void)updateBottomViewWithInfo:(NSMutableArray *)infoArray;
@end

