//
//  LiveGiftShowNumberView.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//  弹幕效果数字变化的视图

#import <UIKit/UIKit.h>

@interface LiveGiftShowNumberView : UIView

@property (nonatomic ,assign) NSInteger number;/**< 初始化数字 */


/**
 改变数字显示

 @param numberStr 显示的数字
 */
- (void)changeNumber:(NSInteger )numberStr;


/**
 获取显示的数字

 @return 显示的数字
 */
- (NSInteger)getLastNumber;

@end

@interface PresentLabel : UILabel

/**
 *  数字描边颜色
 */
@property (strong, nonatomic) UIColor   *borderColor;
/**
 *  字体渐变颜色
 */
@property(nonatomic, strong) NSArray    *colors;
/**
 *  开始连乘动画
 *
 *  @param interval    动画时间
 *  @param completion  动画完成回调
 */
- (void)startAnimationDuration:(NSTimeInterval)interval
                    completion:(void (^)(BOOL finish))completion;

@end
