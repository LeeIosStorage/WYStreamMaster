//
//  WYCustomAlertView.h
//  WYTelevision
//
//  Created by zurich on 16/9/8.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ShowViewDefualtHeight 140
#define ShowViewDefualtWidth 225

typedef void(^AlertButtonClickedBlock)(NSInteger index);

@interface WYCustomAlertView : UIView

//optional
@property (strong, nonatomic) UIColor *alertBackgroundColor;
@property (strong, nonatomic) UIButton  *closeButton;

/**
 *  @brief Normal Alert Type
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelTitle:( NSString *)cancelTitle otherTitle:(NSString *)otherTitle alertActionBlock:(AlertButtonClickedBlock)alertActionBlock;
/**
 *  @brief Custom Alert Type
 *  @param alertSize 自定义视图的大小
 */
- (instancetype)initWithCustomAlertSize:(CGSize )alertSize;

- (void)showWithView:(UIView *)view;

- (void)showWithHUDView:(UIView *)view;

- (void)closeShowView;

@end
