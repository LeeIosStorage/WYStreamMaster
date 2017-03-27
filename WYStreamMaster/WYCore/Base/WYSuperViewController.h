//
//  WYSuperViewController.h
//  WYTelevision
//
//  Created by zurich on 16/8/23.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYNetWorkManager.h"


@interface WYSuperViewController : UIViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic,readonly) UIBarButtonItem  *leftBarButtonItem;
@property (strong, nonatomic,readonly) UIBarButtonItem  *rightBarButtonItem;

@property (strong, nonatomic) UIButton                  *rightButton;
///默认是返回按钮,如果需要可以设置backImage
@property (strong, nonatomic) UIImage                   *backImage;
//禁用侧滑
@property (nonatomic, assign) BOOL                      disablePan;

@property (strong, nonatomic) UIView                    *defualtPageView;


@property (weak, nonatomic) IBOutlet UIImageView    *accountError;
@property (weak, nonatomic) IBOutlet UIImageView    *passwordError;
@property (weak, nonatomic) IBOutlet UIImageView    *verificatCodeError;


- (void)setLoginTips:(NSString *)tips;

- (void)doBack;

- (void)refreshViewWithObject:(id )object;

- (void)setNavgationBackgroundWithColor:(UIColor *)backgroundColor;

/**
 *  如果设置了rightButton则需要在子类中重写此方法
 */
- (void)rightButtonClicked:(id)sender;

//EX: self.networkManager
- (WYNetWorkManager *)networkManager;
/**
 *  在需要禁用手势的地方调用此方法，必须在子类viewWillAppear方法中调用才能生效
 */
- (void)cancelPopGesture;

- (void)usePopGesture;

- (void)customDoBack;

//需要点击消除输入框
- (void)needTapGestureRecognizer;

#pragma mark login error tip

- (void)passwordErrorShowWithString:(NSString *)passwordString;

- (void)accountErrorShowWithString:(NSString *)accountString;

- (void)verificatCodeErrorShowWithString:(NSString *)verificatCode;
- (void)nameErrorShowWithString:(NSString *)accountString;

/**
 *  谨慎使用
 */
- (void)makeItHappy;
@end
