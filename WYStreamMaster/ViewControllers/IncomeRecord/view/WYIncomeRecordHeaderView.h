//
//  YTClassifyBottomView.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTClassifyBBSDetailModel;
@protocol WYIncomeRecordHeaderViewDelegate <NSObject>
@optional

- (void)clickCurrencyButtonDelegate:(NSString *)currencyString;
@end
@interface WYIncomeRecordHeaderView : UIView
@property (nonatomic, weak) id<WYIncomeRecordHeaderViewDelegate> delegate;
@end
